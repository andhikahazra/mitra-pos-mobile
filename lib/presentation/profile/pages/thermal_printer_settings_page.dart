import 'dart:async';

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mitrapos/core/theme/app_colors.dart';
import 'package:mitrapos/core/theme/app_type_pairing.dart';
import 'package:mitrapos/core/theme/app_text_styles.dart';

class ThermalPrinterSettingsPage extends StatefulWidget {
  const ThermalPrinterSettingsPage({super.key});

  @override
  State<ThermalPrinterSettingsPage> createState() =>
      _ThermalPrinterSettingsPageState();
}

class _ThermalPrinterSettingsPageState
  extends State<ThermalPrinterSettingsPage> with WidgetsBindingObserver {
  static const MethodChannel _bluetoothControlChannel = MethodChannel(
    'mitrapos/bluetooth_control',
  );

  final BlueThermalPrinter _bluetooth = BlueThermalPrinter.instance;

  final List<BluetoothDevice> _pairedDevices = [];
  final List<_ScannedPrinterDevice> _scannedDevices = [];
  StreamSubscription<int?>? _stateSubscription;

  BluetoothDevice? _connectedDevice;
  bool _isLoading = false;
  bool _isBluetoothEnabled = true;
  bool _isConnected = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_initBluetoothStateListener());
    unawaited(_refreshDevices());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_refreshDevices());
    }
  }

  Future<void> _initBluetoothStateListener() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    try {
      _stateSubscription = _bluetooth.onStateChanged().listen(
        _onBluetoothStateChanged,
        onError: (Object _) => _handleBluetoothPluginUnavailable(),
      );
    } on MissingPluginException {
      _handleBluetoothPluginUnavailable();
    } on PlatformException {
      _handleBluetoothPluginUnavailable();
    }
  }

  void _onBluetoothStateChanged(int? state) {
      if (!mounted) return;
      final bluetoothOn =
          state == BlueThermalPrinter.STATE_ON ||
          state == BlueThermalPrinter.STATE_TURNING_ON ||
          state == BlueThermalPrinter.CONNECTED;

      setState(() {
        _isBluetoothEnabled = bluetoothOn;
        _isConnected = state == BlueThermalPrinter.CONNECTED;
      });
  }

  void _handleBluetoothPluginUnavailable() {
    if (!mounted) return;
    setState(() {
      _isBluetoothEnabled = false;
      _isConnected = false;
      _isLoading = false;
      _errorMessage =
          'Fitur printer bluetooth belum tersedia di perangkat ini. Coba reinstall aplikasi lalu jalankan ulang.';
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stateSubscription?.cancel();
    super.dispose();
  }

  Future<void> _refreshDevices({bool showLoading = false}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final connected = (await _bluetooth.isConnected) ?? false;
      final devices = await _bluetooth.getBondedDevices();
      BluetoothDevice? connectedDevice;

      if (connected) {
        final currentAddress = _connectedDevice?.address;
        if (currentAddress != null && currentAddress.isNotEmpty) {
          for (final device in devices) {
            if (device.address == currentAddress) {
              connectedDevice = device;
              break;
            }
          }
        }

        connectedDevice ??= await _findConnectedDevice(devices);
      }

      if (!mounted) return;
      setState(() {
        _pairedDevices
          ..clear()
          ..addAll(devices);
        _isConnected = connected;
        _connectedDevice = connected ? connectedDevice : null;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Gagal memuat perangkat bluetooth. Pastikan izin bluetooth aktif.';
      });
    }
  }

  List<_ScannedPrinterDevice> _buildDeviceList() {
    final byAddress = <String, _ScannedPrinterDevice>{};

    for (final device in _pairedDevices) {
      final address = device.address;
      if (address == null || address.isEmpty) continue;
      byAddress[address] = _ScannedPrinterDevice(device: device, isPaired: true);
    }

    for (final device in _scannedDevices) {
      final address = device.device.address;
      if (address == null || address.isEmpty) continue;
      byAddress[address] = device;
    }

    return byAddress.values.toList();
  }

  List<_ScannedPrinterDevice> _visibleDeviceList() {
    final devices = _buildDeviceList().where((item) => item.isPaired).toList();
    if (!_isConnected) {
      return devices;
    }

    final connectedAddress = _connectedDevice?.address;
    if (connectedAddress != null && connectedAddress.isNotEmpty) {
      return devices
          .where((item) => item.device.address == connectedAddress)
          .toList();
    }

    return devices.where((item) => item.isPaired).toList();
  }

  Future<void> _scanAndRefreshDevices({bool showLoading = false}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
        final connected = (await _bluetooth.isConnected) ?? false;
      final paired = await _bluetooth.getBondedDevices();
        final connectedDevice = connected
          ? await _findConnectedDevice(paired)
          : null;

      List<_ScannedPrinterDevice> discovered = [];
      if (defaultTargetPlatform == TargetPlatform.android && !kIsWeb) {
        discovered = await _scanNearbyDevices();
      }

      if (!mounted) return;
      setState(() {
        _pairedDevices
          ..clear()
          ..addAll(paired);
        _scannedDevices
          ..clear()
          ..addAll(discovered);
        _isConnected = connected;
        _connectedDevice = connectedDevice;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Gagal memindai perangkat bluetooth. Pastikan izin bluetooth aktif.';
      });
    }
  }

  Future<BluetoothDevice?> _findConnectedDevice(
    List<BluetoothDevice> paired,
  ) async {
    for (final device in paired) {
      try {
        final isConnected = await _bluetooth.isDeviceConnected(device) ?? false;
        if (isConnected) {
          return device;
        }
      } catch (_) {
        // Ignore per-device check failures and continue trying others.
      }
    }

    return null;
  }

  Future<List<_ScannedPrinterDevice>> _scanNearbyDevices() async {
    try {
      final rawDevices =
          await _bluetoothControlChannel.invokeMethod<List<dynamic>>(
            'scanBluetoothDevices',
          ) ??
          const <dynamic>[];

      return rawDevices
          .whereType<Map<dynamic, dynamic>>()
          .map((item) {
            final name = item['name'] as String?;
            final address = item['address'] as String?;
            final bonded = (item['bonded'] as bool?) ?? false;
            return _ScannedPrinterDevice(
              device: BluetoothDevice(name, address),
              isPaired: bonded,
            );
          })
          .where((item) {
            final address = item.device.address;
            return address != null && address.isNotEmpty;
          })
          .toList();
    } on PlatformException {
      return const [];
    } on MissingPluginException {
      return const [];
    }
  }

  Future<void> _scanOrEnableBluetooth() async {
    if (!_isBluetoothEnabled) {
      final enableResult = await _requestEnableBluetooth();
      if (!mounted) return;

      if (enableResult == true) {
        setState(() {
          _isBluetoothEnabled = true;
        });
        await _scanAndRefreshDevices(showLoading: true);
      } else if (enableResult == false) {
        _showInfo('Menyalakan Bluetooth dibatalkan.');
      } else {
        _showInfo('Tidak bisa memicu menyalakan Bluetooth. Coba lagi.');
      }
      return;
    }
    await _scanAndRefreshDevices(showLoading: true);
  }

  Future<void> _pairAndConnectPrinter(BluetoothDevice device) async {
    final address = device.address;
    if (address == null || address.isEmpty) {
      _showInfo('Alamat perangkat tidak valid.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final paired =
          await _bluetoothControlChannel.invokeMethod<bool>(
            'pairBluetoothDevice',
            {'address': address},
          ) ??
          false;

      if (!mounted) return;

      if (paired) {
        _showInfo('Pairing berhasil. Menghubungkan ke printer...');
        await _scanAndRefreshDevices(showLoading: false);
        await _connectToPrinter(device);
      } else {
        setState(() {
          _isLoading = false;
        });
        _showInfo('Pairing dibatalkan atau gagal.');
      }
    } on PlatformException catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      if (error.code == 'PERMISSION_DENIED') {
        _showInfo('Izin Bluetooth ditolak. Izinkan akses Bluetooth lalu coba lagi.');
      } else if (error.code == 'BLUETOOTH_OFF') {
        _showInfo('Bluetooth masih mati. Aktifkan dulu lalu Pair lagi.');
      } else {
        _showInfo('Pairing gagal. Coba ulangi.');
      }
    } on MissingPluginException {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      _showInfo('Fitur pairing belum tersedia pada build ini.');
    }
  }

  Future<bool?> _requestEnableBluetooth() async {
    try {
      final enabled =
          await _bluetoothControlChannel.invokeMethod<bool>(
            'requestEnableBluetooth',
          ) ??
          false;
      return enabled;
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  Future<void> _connectToPrinter(BluetoothDevice device) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isConnected) {
        await _bluetooth.disconnect();
      }
      await _bluetooth.connect(device);
      final connected = (await _bluetooth.isConnected) ?? false;

      if (!mounted) return;
      setState(() {
        _isConnected = connected;
        _connectedDevice = connected ? device : null;
        _isLoading = false;
      });

      if (connected) {
        _showInfo('Printer ${device.name ?? 'Tanpa Nama'} berhasil terhubung');
      } else {
        _showInfo('Gagal menghubungkan printer');
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Koneksi gagal. Pastikan printer menyala dan sudah dipasangkan.';
      });
    }
  }

  Future<void> _disconnectPrinter() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _bluetooth.disconnect();
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isConnected = false;
        _connectedDevice = null;
      });
      _showInfo('Printer diputuskan');
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal memutuskan koneksi printer.';
      });
    }
  }

  Future<void> _printTest() async {
    if (!_isConnected) {
      _showInfo('Hubungkan printer terlebih dahulu.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final now = DateTime.now();
      final dateText = DateFormat('dd-MM-yyyy').format(now);
      final timeText = DateFormat('HH:mm:ss').format(now);
      const divider = '--------------------------------';

      await _bluetooth.printNewLine();
      await _bluetooth.printCustom('MITRAPOS', 0, 1);
      await _bluetooth.printCustom('TEST PRINT', 0, 1);
      await _bluetooth.printCustom(divider, 0, 1);
      await _bluetooth.printLeftRight('Tanggal', dateText, 0);
      await _bluetooth.printLeftRight('Jam', timeText, 0);
      await _bluetooth.printCustom('Kasir   : Demo User', 0, 0);
      await _bluetooth.printCustom(
        'Printer : ${_connectedDevice?.name ?? 'Bluetooth Printer'}',
        0,
        0,
      );
      await _bluetooth.printCustom(divider, 0, 1);

      await _bluetooth.printCustom('Item Uji Cetak', 0, 0);
      await _bluetooth.printLeftRight('1x Kopi Susu', '18.000', 0);
      await _bluetooth.printLeftRight('2x Roti Bakar', '24.000', 0);
      await _bluetooth.printLeftRight('1x Air Mineral', '5.000', 0);
      await _bluetooth.printCustom(divider, 0, 1);
      await _bluetooth.printLeftRight('Subtotal', '47.000', 0);
      await _bluetooth.printLeftRight('Pajak 10%', '4.700', 0);
      await _bluetooth.printLeftRight('TOTAL', '51.700', 0);
      await _bluetooth.printLeftRight('Bayar Tunai', '60.000', 0);
      await _bluetooth.printLeftRight('Kembalian', '8.300', 0);

      await _bluetooth.printCustom(divider, 0, 1);
      await _bluetooth.printCustom('Status  : TEST BERHASIL', 0, 0);
      await _bluetooth.printCustom('Catatan : Alignment dan feed normal.', 0, 0);
      await _bluetooth.printCustom('Silakan sobek struk ini.', 0, 1);
      await _bluetooth.printNewLine();
      await _bluetooth.printNewLine();

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      _showInfo('Test print berhasil dikirim ke printer.');
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal melakukan test print. Cek koneksi printer.';
      });
    }
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final visibleDevices = _visibleDeviceList();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text('Pengaturan Printer', style: AppTypePairing.headlineLg()),
      ),
      body: RefreshIndicator(
        onRefresh: _scanOrEnableBluetooth,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _StatusCard(
              isBluetoothEnabled: _isBluetoothEnabled,
              isConnected: _isConnected,
              connectedDeviceName: _connectedDevice?.name,
            ),
            const SizedBox(height: 12),
            _ActionRow(
              isLoading: _isLoading,
              isConnected: _isConnected,
              onScan: _scanOrEnableBluetooth,
              onDisconnect: _disconnectPrinter,
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 44,
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: (_isLoading || !_isConnected) ? null : _printTest,
                icon: const Icon(Icons.print_rounded, size: 18),
                label: const Text('Test Print'),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.22),
                  ),
                ),
                child: Text(
                  _errorMessage!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 14),
            Text('Perangkat', style: AppTypePairing.headlineLg()),
            const SizedBox(height: 8),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (visibleDevices.isEmpty)
              _EmptyDeviceState(
                onScan: _scanOrEnableBluetooth,
              )
            else
              ...visibleDevices.map((item) {
                final device = item.device;
                final isActive =
                    _isConnected && _connectedDevice?.address == device.address;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _DeviceTile(
                    device: device,
                    isActive: isActive,
                    isPaired: item.isPaired,
                    onConnect: () {
                      if (item.isPaired) {
                        _connectToPrinter(device);
                      } else {
                        unawaited(_pairAndConnectPrinter(device));
                      }
                    },
                  ),
                );
              }),
            const SizedBox(height: 8),
            Text(
              _isConnected
                  ? 'Printer sudah terhubung. Putuskan dulu jika ingin memilih perangkat lain.'
                  : 'Tekan Bluetooth Scan untuk memuat ulang daftar perangkat paired.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final bool isBluetoothEnabled;
  final bool isConnected;
  final String? connectedDeviceName;

  const _StatusCard({
    required this.isBluetoothEnabled,
    required this.isConnected,
    required this.connectedDeviceName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.indigoSurfaceTint.withValues(alpha: 0.14),
        ),
      ),
      child: Column(
        children: [
          _StatusLine(
            label: 'Bluetooth',
            value: isBluetoothEnabled ? 'Aktif' : 'Nonaktif',
            valueColor: isBluetoothEnabled
                ? AppColors.success
                : AppColors.error,
          ),
          const SizedBox(height: 8),
          _StatusLine(
            label: 'Status Printer',
            value: isConnected ? 'Terhubung' : 'Belum Terhubung',
            valueColor: isConnected ? AppColors.success : AppColors.warning,
          ),
          const SizedBox(height: 8),
          _StatusLine(
            label: 'Nama Printer',
            value: connectedDeviceName ?? '-',
            valueColor: connectedDeviceName != null
                ? AppColors.indigoPrimary
                : AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _StatusLine({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: AppTypePairing.bodySm())),
        Text(
          value,
          style: AppTypePairing.bodySm(
            color: valueColor,
            weight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  final bool isLoading;
  final bool isConnected;
  final VoidCallback onScan;
  final VoidCallback onDisconnect;

  const _ActionRow({
    required this.isLoading,
    required this.isConnected,
    required this.onScan,
    required this.onDisconnect,
  });

  @override
  Widget build(BuildContext context) {
    final sharedShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 44,
            child: FilledButton.icon(
              onPressed: isLoading ? null : onScan,
              style: FilledButton.styleFrom(
                shape: sharedShape,
                minimumSize: const Size(double.infinity, 44),
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
              icon: const Icon(Icons.bluetooth_searching_rounded, size: 18),
              label: const Text('Bluetooth Scan'),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 44,
            child: OutlinedButton.icon(
              onPressed: (isLoading || !isConnected) ? null : onDisconnect,
              style: OutlinedButton.styleFrom(
                shape: sharedShape,
                minimumSize: const Size(double.infinity, 44),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                side: BorderSide(
                  color: AppColors.indigoSurfaceTint.withValues(alpha: 0.35),
                  width: 1.2,
                ),
              ),
              icon: const Icon(Icons.link_off_rounded, size: 18),
              label: const Text('Putuskan'),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyDeviceState extends StatelessWidget {
  final VoidCallback onScan;

  const _EmptyDeviceState({required this.onScan});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.indigoSurfaceTint.withValues(alpha: 0.14),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.print_disabled_outlined,
            size: 32,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 8),
          Text(
            'Belum ada printer paired',
            style: AppTypePairing.bodySm(weight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Pair printer dari pengaturan Bluetooth perangkat lalu tekan Scan.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: onScan,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Muat Ulang'),
          ),
        ],
      ),
    );
  }
}

class _DeviceTile extends StatelessWidget {
  final BluetoothDevice device;
  final bool isActive;
  final bool isPaired;
  final VoidCallback onConnect;

  const _DeviceTile({
    required this.device,
    required this.isActive,
    required this.isPaired,
    required this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive
              ? AppColors.success.withValues(alpha: 0.35)
              : AppColors.indigoSurfaceTint.withValues(alpha: 0.14),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.indigoSurfaceTint.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.print_rounded,
              color: AppColors.indigoPrimary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name ?? 'Tanpa Nama',
                  style: AppTypePairing.bodySm(weight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  device.address ?? '-',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isPaired ? 'Paired' : 'Belum Paired',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isPaired ? AppColors.success : AppColors.warning,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: isActive ? null : onConnect,
            style: FilledButton.styleFrom(
              backgroundColor: isActive ? AppColors.success : AppColors.primary,
              foregroundColor: AppColors.white,
              minimumSize: const Size(82, 36),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: Text(isActive ? 'Aktif' : (isPaired ? 'Connect' : 'Pair')),
          ),
        ],
      ),
    );
  }
}

class _ScannedPrinterDevice {
  final BluetoothDevice device;
  final bool isPaired;

  const _ScannedPrinterDevice({required this.device, required this.isPaired});
}
