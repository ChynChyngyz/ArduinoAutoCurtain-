// utils/bluetooth_service.dart

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothService {
  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  BluetoothConnection? _connection;
  StreamSubscription<BluetoothDiscoveryResult>? _discoverySubscription;

  // Состояния
  bool get isConnected => _connection?.isConnected == true;
  bool _isDiscovering = false;

  // Инициализация Bluetooth
  Future<bool> initialize() async {
    try {
      // Проверяем включен ли Bluetooth
      final bool? isEnabled = await _bluetooth.isEnabled;
      if (isEnabled == null || !isEnabled) {
        await _bluetooth.requestEnable();
      }
      return true;
    } catch (e) {
      print('Bluetooth initialization error: $e');
      return false;
    }
  }

  // Получение списка спаренных устройств
  Future<List<BluetoothDevice>> getBondedDevices() async {
    try {
      return await _bluetooth.getBondedDevices();
    } catch (e) {
      print('Error getting bonded devices: $e');
      return [];
    }
  }

  // Поиск устройств
  Stream<BluetoothDiscoveryResult> discoverDevices({
    Duration timeout = const Duration(seconds: 10),
  }) {
    _isDiscovering = true;

    final streamController = StreamController<BluetoothDiscoveryResult>();

    _discoverySubscription?.cancel();
    _discoverySubscription = _bluetooth.startDiscovery().listen(
          (result) {
        streamController.add(result);
      },
      onError: (error) {
        streamController.addError(error);
      },
      onDone: () {
        _isDiscovering = false;
        streamController.close();
      },
    );

    // Автоматическая остановка через timeout
    Timer(timeout, () {
      if (_isDiscovering) {
        stopDiscovery();
        streamController.close();
      }
    });

    return streamController.stream;
  }

  // Остановка поиска
  void stopDiscovery() {
    _discoverySubscription?.cancel();
    _discoverySubscription = null;
    _isDiscovering = false;
  }

  // Фильтрация устройств по имени
  bool isTargetDevice(String deviceName) {
    if (deviceName.isEmpty) return false;

    final lowerName = deviceName.toLowerCase();
    return lowerName.contains('hc-06') ||
        lowerName.contains('hc-05') ||
        lowerName.contains('ew27') ||
        lowerName.contains('bt05') ||
        lowerName.contains('bluetooth') &&
            (lowerName.contains('serial') || lowerName.contains('spp'));
  }

  // Подключение к устройству
  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      // Закрываем существующее соединение
      await disconnect();

      // Устанавливаем соединение
      _connection = await BluetoothConnection.toAddress(device.address);

      // Настройка обработки данных
      _setupConnectionListeners();

      return true;
    } catch (e) {
      print('Connection error: $e');
      _connection = null;
      return false;
    }
  }

  // Настройка слушателей соединения
  void _setupConnectionListeners() {
    if (_connection == null) return;

    // Обработка входящих данных
    _connection!.input?.listen((Uint8List data) {
      final message = String.fromCharCodes(data);
      _onDataReceived(message);
    }).onDone(() {
      _onConnectionClosed();
    });
  }

  // Обработка полученных данных
  void _onDataReceived(String data) {
    print('Received data: $data');
  }

  // Обработка закрытия соединения
  void _onConnectionClosed() {
    print('Connection closed');
    _connection = null;
  }

  // Отправка команды
  Future<bool> sendCommand(String command) async {
    if (_connection == null || !isConnected) {
      print('Not connected to device');
      return false;
    }

    try {
      // Добавляем перевод строки для HC-06
      final data = '$command\n';
      _connection!.output.add(Uint8List.fromList(data.codeUnits));
      await _connection!.output.allSent;

      print('Command sent: $command');
      return true;
    } catch (e) {
      print('Send command error: $e');
      return false;
    }
  }

  // Отключение
  Future<void> disconnect() async {
    try {
      await _connection?.close();
      _connection = null;
      print('Disconnected successfully');
    } catch (e) {
      print('Disconnection error: $e');
    }
  }

  // Проверка состояния Bluetooth
  Future<BluetoothState> getBluetoothState() async {
    return await _bluetooth.state;
  }

  // Получение потока изменений состояния Bluetooth
  Stream<BluetoothState> get onBluetoothStateChanged {
    return _bluetooth.onStateChanged();
  }

  // Очистка ресурсов
  void dispose() {
    _discoverySubscription?.cancel();
    disconnect();
  }
}

// Утилиты для работы с Bluetooth
class BluetoothUtils {
  // Проверка валидности MAC-адреса
  static bool isValidMacAddress(String address) {
    final regex = RegExp(r'^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$');
    return regex.hasMatch(address);
  }

  // Форматирование MAC-адреса
  static String formatMacAddress(String address) {
    // Убираем все разделители и приводим к верхнему регистру
    final cleanAddress = address.replaceAll(RegExp(r'[:-]'), '').toUpperCase();

    if (cleanAddress.length != 12) {
      return address;
    }

    // Форматируем с двоеточиями
    final buffer = StringBuffer();
    for (int i = 0; i < 12; i += 2) {
      if (i > 0) buffer.write(':');
      buffer.write(cleanAddress.substring(i, i + 2));
    }

    return buffer.toString();
  }

  // Получение имени устройства для отображения
  static String getDisplayName(String? deviceName, String address) {
    if (deviceName != null && deviceName.isNotEmpty) {
      return deviceName;
    }

    // Пытаемся определить тип по MAC-адресу
    final oui = address.substring(0, 8).toUpperCase();
    final knownDevices = {
      '00:13:AA': 'BT05 Module',
      '20:16:12': 'HC-06 Module',
      '98:D3:31': 'HC-05 Module',
    };

    return knownDevices[oui] ?? 'Bluetooth Device';
  }
}