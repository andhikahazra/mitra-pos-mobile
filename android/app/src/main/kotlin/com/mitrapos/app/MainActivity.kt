package com.mitrapos.app

import android.app.Activity
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
	private var enableBluetoothResult: MethodChannel.Result? = null
	private var scanDevicesResult: MethodChannel.Result? = null
	private var pairDeviceResult: MethodChannel.Result? = null
	private var discoveryReceiver: BroadcastReceiver? = null
	private var bondReceiver: BroadcastReceiver? = null
	private var pendingPairAddress: String? = null
	private val discoveredDevices = linkedMapOf<String, Map<String, Any?>>()
	private val discoveryHandler = Handler(Looper.getMainLooper())
	private val discoveryTimeoutRunnable = Runnable { finishDeviceScan() }
	private val pairHandler = Handler(Looper.getMainLooper())
	private val pairTimeoutRunnable = Runnable {
		pairDeviceResult?.error("PAIR_TIMEOUT", "Pairing timeout", null)
		cleanupBondReceiver()
		pairDeviceResult = null
		pendingPairAddress = null
	}

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		MethodChannel(
			flutterEngine.dartExecutor.binaryMessenger,
			"mitrapos/bluetooth_control",
		).setMethodCallHandler { call, result ->
			when (call.method) {
				"requestEnableBluetooth" -> requestEnableBluetooth(result)
				"scanBluetoothDevices" -> scanBluetoothDevices(result)
				"openBluetoothSettings" -> openBluetoothSettings(result)
				"pairBluetoothDevice" -> {
					val address = call.argument<String>("address")
					pairBluetoothDevice(address, result)
				}
				else -> result.notImplemented()
			}
		}
	}

	private fun pairBluetoothDevice(address: String?, result: MethodChannel.Result) {
		if (pairDeviceResult != null) {
			result.error("IN_PROGRESS", "Pairing already in progress", null)
			return
		}

		if (address.isNullOrBlank()) {
			result.error("INVALID_ARGUMENT", "address is required", null)
			return
		}

		val manager = getSystemService(Context.BLUETOOTH_SERVICE) as? BluetoothManager
		val adapter = manager?.adapter

		if (adapter == null) {
			result.error("UNAVAILABLE", "Bluetooth is not available on this device", null)
			return
		}

		if (!adapter.isEnabled) {
			result.error("BLUETOOTH_OFF", "Bluetooth is disabled", null)
			return
		}

		val device = try {
			adapter.getRemoteDevice(address)
		} catch (_: IllegalArgumentException) {
			result.error("INVALID_ADDRESS", "Invalid bluetooth address", null)
			return
		}

		if (device.bondState == BluetoothDevice.BOND_BONDED) {
			result.success(true)
			return
		}

		pairDeviceResult = result
		pendingPairAddress = address

		bondReceiver = object : BroadcastReceiver() {
			override fun onReceive(context: Context?, intent: Intent?) {
				if (intent?.action != BluetoothDevice.ACTION_BOND_STATE_CHANGED) return
				val changedDevice = intent.getParcelableExtra<BluetoothDevice>(BluetoothDevice.EXTRA_DEVICE)
				if (changedDevice?.address != pendingPairAddress) return

				val newState = intent.getIntExtra(BluetoothDevice.EXTRA_BOND_STATE, BluetoothDevice.ERROR)
				if (newState == BluetoothDevice.BOND_BONDED) {
					pairHandler.removeCallbacks(pairTimeoutRunnable)
					pairDeviceResult?.success(true)
					cleanupBondReceiver()
					pairDeviceResult = null
					pendingPairAddress = null
				} else if (newState == BluetoothDevice.BOND_NONE) {
					pairHandler.removeCallbacks(pairTimeoutRunnable)
					pairDeviceResult?.success(false)
					cleanupBondReceiver()
					pairDeviceResult = null
					pendingPairAddress = null
				}
			}
		}

		val filter = IntentFilter(BluetoothDevice.ACTION_BOND_STATE_CHANGED)
		registerReceiver(bondReceiver, filter)

		if (adapter.isDiscovering) {
			adapter.cancelDiscovery()
		}

		val started = try {
			device.createBond()
		} catch (error: SecurityException) {
			cleanupBondReceiver()
			pairDeviceResult = null
			pendingPairAddress = null
			result.error("PERMISSION_DENIED", error.message, null)
			return
		}

		if (!started) {
			cleanupBondReceiver()
			pairDeviceResult = null
			pendingPairAddress = null
			result.success(false)
			return
		}

		pairHandler.postDelayed(pairTimeoutRunnable, 25000)
	}

	private fun openBluetoothSettings(result: MethodChannel.Result) {
		try {
			val intent = Intent(Settings.ACTION_BLUETOOTH_SETTINGS)
			startActivity(intent)
			result.success(true)
		} catch (error: Exception) {
			result.error("OPEN_SETTINGS_FAILED", error.message, null)
		}
	}

	private fun requestEnableBluetooth(result: MethodChannel.Result) {
		if (enableBluetoothResult != null) {
			result.error("IN_PROGRESS", "Bluetooth enable request already in progress", null)
			return
		}

		val manager = getSystemService(Context.BLUETOOTH_SERVICE) as? BluetoothManager
		val adapter = manager?.adapter

		if (adapter == null) {
			result.error("UNAVAILABLE", "Bluetooth is not available on this device", null)
			return
		}

		if (adapter.isEnabled) {
			result.success(true)
			return
		}

		enableBluetoothResult = result
		try {
			val enableIntent = Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE)
			startActivityForResult(enableIntent, REQUEST_ENABLE_BLUETOOTH)
		} catch (error: Exception) {
			enableBluetoothResult = null
			result.error("ENABLE_FAILED", error.message, null)
		}
	}

	private fun scanBluetoothDevices(result: MethodChannel.Result) {
		if (scanDevicesResult != null) {
			result.error("IN_PROGRESS", "Bluetooth scan already in progress", null)
			return
		}

		val manager = getSystemService(Context.BLUETOOTH_SERVICE) as? BluetoothManager
		val adapter = manager?.adapter

		if (adapter == null) {
			result.error("UNAVAILABLE", "Bluetooth is not available on this device", null)
			return
		}

		if (!adapter.isEnabled) {
			result.error("BLUETOOTH_OFF", "Bluetooth is disabled", null)
			return
		}

		scanDevicesResult = result
		discoveredDevices.clear()

		adapter.bondedDevices?.forEach { device ->
			val address = device.address ?: return@forEach
			discoveredDevices[address] = mapOf(
				"name" to device.name,
				"address" to address,
				"bonded" to true,
			)
		}

		discoveryReceiver = object : BroadcastReceiver() {
			override fun onReceive(context: Context?, intent: Intent?) {
				when (intent?.action) {
					BluetoothDevice.ACTION_FOUND -> {
						val device = intent.getParcelableExtra<BluetoothDevice>(BluetoothDevice.EXTRA_DEVICE)
						val address = device?.address ?: return
						discoveredDevices[address] = mapOf(
							"name" to device.name,
							"address" to address,
							"bonded" to (device.bondState == BluetoothDevice.BOND_BONDED),
						)
					}
					BluetoothAdapter.ACTION_DISCOVERY_FINISHED -> finishDeviceScan()
				}
			}
		}

		val filter = IntentFilter().apply {
			addAction(BluetoothDevice.ACTION_FOUND)
			addAction(BluetoothAdapter.ACTION_DISCOVERY_FINISHED)
		}
		registerReceiver(discoveryReceiver, filter)

		if (adapter.isDiscovering) {
			adapter.cancelDiscovery()
		}

		val started = adapter.startDiscovery()
		if (!started) {
			cleanupScanReceiver()
			scanDevicesResult = null
			result.error("SCAN_FAILED", "Failed to start Bluetooth discovery", null)
			return
		}

		discoveryHandler.postDelayed(discoveryTimeoutRunnable, 5000)
	}

	private fun finishDeviceScan() {
		discoveryHandler.removeCallbacks(discoveryTimeoutRunnable)
		val manager = getSystemService(Context.BLUETOOTH_SERVICE) as? BluetoothManager
		val adapter = manager?.adapter
		if (adapter?.isDiscovering == true) {
			adapter.cancelDiscovery()
		}
		cleanupScanReceiver()

		val payload = discoveredDevices.values.toList()
		scanDevicesResult?.success(payload)
		scanDevicesResult = null
	}

	private fun cleanupScanReceiver() {
		val receiver = discoveryReceiver ?: return
		try {
			unregisterReceiver(receiver)
		} catch (_: IllegalArgumentException) {
		}
		discoveryReceiver = null
	}

	private fun cleanupBondReceiver() {
		val receiver = bondReceiver ?: return
		try {
			unregisterReceiver(receiver)
		} catch (_: IllegalArgumentException) {
		}
		bondReceiver = null
	}

	override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
		super.onActivityResult(requestCode, resultCode, data)

		if (requestCode == REQUEST_ENABLE_BLUETOOTH) {
			val accepted = resultCode == Activity.RESULT_OK
			enableBluetoothResult?.success(accepted)
			enableBluetoothResult = null
		}
	}

	override fun onDestroy() {
		discoveryHandler.removeCallbacks(discoveryTimeoutRunnable)
		pairHandler.removeCallbacks(pairTimeoutRunnable)
		cleanupScanReceiver()
		cleanupBondReceiver()
		scanDevicesResult = null
		enableBluetoothResult = null
		pairDeviceResult = null
		pendingPairAddress = null
		super.onDestroy()
	}

	companion object {
		private const val REQUEST_ENABLE_BLUETOOTH = 48091
	}
}
