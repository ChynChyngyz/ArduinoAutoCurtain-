// provider/bluetooth_provider.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/bluetooth_service.dart';
import '../models/bluetooth_device.dart';

class BluetoothProvider extends ChangeNotifier {
  final BluetoothService _bluetoothService = BluetoothService();

  List<DeviceInfo> _availableDevices = [];
  List<DeviceInfo> _bondedDevices = [];
  DeviceInfo? _connectedDevice;
  bool _isDiscovering = false;
  bool _isConnecting = false;
  bool _isConnected = false;
  String _connectionStatus = 'Not connected';

  // Поток для обновлений устройств
  StreamSubscription? _discoveryStream;

  List<DeviceInfo> get availableDevices => _availableDevices;
  List<DeviceInfo> get bondedDevices => _bondedDevices;
  DeviceInfo? get connectedDevice => _connectedDevice;
  bool get isDiscovering => _isDiscovering;
  bool get isConnecting => _isConnecting;
  bool get isConnected => _isConnected;
  String get connectionStatus => _connectionStatus;

  // Инициализация Bluetooth
  Future<void> initialize() async {
    try {
      final success = await _bluetoothService.initialize();
      if (success) {
        await _loadBondedDevices();
        _setupBluetoothStateListener();
      }
    } catch (e) {
      print('Provider initialization error: $e');
    }
  }

  // Загрузка спаренных устройств
  Future<void> _loadBondedDevices() async {
    try {
      final devices = await _bluetoothService.getBondedDevices();

      _bondedDevices = devices.map((device) {
        final name = device.name ?? 'Unknown';
        return DeviceInfo(
          device: device,
          name: BluetoothUtils.getDisplayName(name, device.address),
          address: device.address,
          isConnected: false,
        );
      }).toList();

      notifyListeners();
    } catch (e) {
      print('Error loading bonded devices: $e');
    }
  }

  // Настройка слушателя состояния Bluetooth
  void _setupBluetoothStateListener() {
    _bluetoothService.onBluetoothStateChanged.listen((state) {
      print('Bluetooth state changed: $state');
    });
  }

  // Поиск устройств
  void startDiscovery() {
    if (_isDiscovering) return;

    _availableDevices.clear();
    _isDiscovering = true;
    notifyListeners();

    _discoveryStream?.cancel();
    _discoveryStream = _bluetoothService.discoverDevices().listen((result) {
      final device = result.device;
      final name = device.name ?? '';

      // Фильтруем только целевые устройства
      if (_bluetoothService.isTargetDevice(name)) {
        final deviceInfo = DeviceInfo(
          device: device,
          name: BluetoothUtils.getDisplayName(name, device.address),
          address: device.address,
          isConnected: false,
          rssi: result.rssi, // Теперь есть поле rssi
        );

        // Проверяем, нет ли уже такого устройства в списке
        final existingIndex = _availableDevices.indexWhere(
                (d) => d.address == device.address
        );

        if (existingIndex >= 0) {
          _availableDevices[existingIndex] = deviceInfo;
        } else {
          _availableDevices.add(deviceInfo);
        }

        notifyListeners();
      }
    }, onError: (error) {
      print('Discovery error: $error');
      _isDiscovering = false;
      notifyListeners();
    }, onDone: () {
      _isDiscovering = false;
      notifyListeners();
    });
  }

  // Остановка поиска
  void stopDiscovery() {
    _bluetoothService.stopDiscovery();
    _discoveryStream?.cancel();
    _isDiscovering = false;
    notifyListeners();
  }

  // Подключение к устройству
  Future<void> connectToDevice(DeviceInfo deviceInfo) async {
    if (_isConnecting || _isConnected) return;

    _isConnecting = true;
    _connectionStatus = 'Connecting...';
    notifyListeners();

    try {
      if (deviceInfo.device != null) {
        final success = await _bluetoothService.connectToDevice(deviceInfo.device!);

        if (success) {
          _connectedDevice = deviceInfo;
          _connectedDevice!.isConnected = true;
          _isConnected = true;
          _isConnecting = false;
          _connectionStatus = 'Connected';

          // Добавляем в список спаренных, если еще нет
          if (!_bondedDevices.any((d) => d.address == deviceInfo.address)) {
            _bondedDevices.add(deviceInfo);
          }
        } else {
          _connectionStatus = 'Connection failed';
        }
      } else {
        _connectionStatus = 'Device information is incomplete';
      }
    } catch (e) {
      print('Connection error: $e');
      _connectionStatus = 'Error: $e';
      _isConnecting = false;
    }

    notifyListeners();
  }

  // Отправка команды
  Future<void> sendCommand(String command) async {
    if (!_isConnected) {
      print('Cannot send command: not connected');
      return;
    }

    try {
      await _bluetoothService.sendCommand(command);
    } catch (e) {
      print('Send command error: $e');
    }
  }

  // Отключение
  Future<void> disconnect() async {
    await _bluetoothService.disconnect();

    if (_connectedDevice != null) {
      _connectedDevice!.isConnected = false;
    }

    _connectedDevice = null;
    _isConnected = false;
    _connectionStatus = 'Disconnected';

    notifyListeners();
  }

  @override
  void dispose() {
    _discoveryStream?.cancel();
    _bluetoothService.dispose();
    super.dispose();
  }
}