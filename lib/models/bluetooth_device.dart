// models/bluetooth_device.dart

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class DeviceInfo {
  final BluetoothDevice? device;
  final String name;
  final String address;
  bool isConnected;
  int? rssi;

  DeviceInfo({
    this.device,
    required this.name,
    required this.address,
    this.isConnected = false,
    this.rssi,
  });
}