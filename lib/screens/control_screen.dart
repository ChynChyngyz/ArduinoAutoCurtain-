// screens/control_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/bluetooth_provider.dart';
import '../provider/curtain_provider.dart';
import '../widgets/control_buttons.dart';
import '../widgets/curtain_indicator.dart';

class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  Timer? _holdTimer;
  bool _isOpening = false;
  bool _isClosing = false;

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }

  void _startHoldAction(bool isOpening) {
    if (isOpening) {
      _isOpening = true;
    } else {
      _isClosing = true;
    }

    final bluetoothProvider = Provider.of<BluetoothProvider>(context, listen: false);
    final curtainProvider = Provider.of<CurtainProvider>(context, listen: false);

    bluetoothProvider.sendCommand(isOpening ? 'START_OPEN' : 'START_CLOSE');

    curtainProvider.setMoving(true);

    _holdTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final currentPosition = curtainProvider.state.position;
      final newPosition = currentPosition + (isOpening ? 0.01 : -0.01);

      if (newPosition >= 0 && newPosition <= 1) {
        curtainProvider.updatePosition(newPosition);
      }

      // Периодически отправляем команду (если нужно)
      if (timer.tick % 10 == 0) {
        bluetoothProvider.sendCommand(isOpening ? 'HOLD_OPEN' : 'HOLD_CLOSE');
      }
    });
  }

  void _stopHoldAction() {
    _holdTimer?.cancel();
    _holdTimer = null;

    final bluetoothProvider = Provider.of<BluetoothProvider>(context, listen: false);
    final curtainProvider = Provider.of<CurtainProvider>(context, listen: false);

    // Отправляем команду остановки
    bluetoothProvider.sendCommand('STOP');
    curtainProvider.stopMoving();

    _isOpening = false;
    _isClosing = false;
  }

  void _sendCommand(String command) {
    final bluetoothProvider = Provider.of<BluetoothProvider>(context, listen: false);
    final curtainProvider = Provider.of<CurtainProvider>(context, listen: false);

    bluetoothProvider.sendCommand(command);

    // Обновляем состояние
    switch (command) {
      case 'OPEN_FULL':
        curtainProvider.updatePosition(1.0);
        break;
      case 'CLOSE_FULL':
        curtainProvider.updatePosition(0.0);
        break;
      case 'PAUSE':
        curtainProvider.stopMoving();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothProvider = Provider.of<BluetoothProvider>(context);
    final curtainProvider = Provider.of<CurtainProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Информация о подключенном устройстве
          Card(
            child: ListTile(
              leading: const Icon(Icons.bluetooth_connected, color: Colors.green),
              title: Text(bluetoothProvider.connectedDevice?.name ?? 'Устройство'),
              subtitle: Text(bluetoothProvider.connectedDevice?.address ?? ''),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => bluetoothProvider.disconnect(),
                tooltip: 'Отключиться',
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Индикатор положения шторы
          CurtainIndicator(
            position: curtainProvider.state.position,
            isMoving: curtainProvider.state.isMoving,
          ),

          const SizedBox(height: 40),

          // Кнопки управления
          ControlButtons(
            onOpenPressed: () => _sendCommand('OPEN_FULL'),
            onClosePressed: () => _sendCommand('CLOSE_FULL'),
            onOpenHoldStart: () => _startHoldAction(true),
            onCloseHoldStart: () => _startHoldAction(false),
            onHoldEnd: _stopHoldAction,
            onPausePressed: () => _sendCommand('PAUSE'),
          ),

          const SizedBox(height: 20),

          // Кнопка экстренной остановки
          ElevatedButton.icon(
            onPressed: _stopHoldAction,
            icon: const Icon(Icons.stop),
            label: const Text('Экстренная остановка'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ],
      ),
    );
  }
}