import 'package:flutter/foundation.dart';

enum UserRole { karyawan }

/// Global role state used by screens that need role-aware behavior.
final ValueNotifier<UserRole> userRoleNotifier = ValueNotifier<UserRole>(UserRole.karyawan);

void setUserRole(UserRole role) {
	userRoleNotifier.value = role;
}
