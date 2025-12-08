// screens/device_list_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/bluetooth_provider.dart';
import '../models/bluetooth_device.dart';
import '../widgets/device_list_item.dart';

class DeviceListScreen extends StatefulWidget {
  const DeviceListScreen({super.key});

  @override
  State<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<BluetoothProvider>(context, listen: false);
      provider.startDiscovery();
    });
  }

  @override
  void dispose() {
    final provider = Provider.of<BluetoothProvider>(context, listen: false);
    provider.stopDiscovery();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BluetoothProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Выберите устройство'),
        actions: [
          IconButton(
            onPressed: provider.startDiscovery,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    provider.isDiscovering
                        ? 'Поиск устройств...'
                        : 'Найдено устройств: ${provider.availableDevices.length}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                if (provider.isDiscovering)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),
          Expanded(
            child: provider.availableDevices.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.devices, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Устройства не найдены',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Убедитесь, что Bluetooth модуль включен',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: provider.availableDevices.length,
              itemBuilder: (context, index) {
                final device = provider.availableDevices[index];
                return DeviceListItem(
                  device: device,
                  isConnecting: provider.isConnecting,
                  onConnect: () => _connectToDevice(provider, device),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _connectToDevice(
      BluetoothProvider provider, DeviceInfo device) async {
    await provider.connectToDevice(device);
    if (provider.isConnected) {
      Navigator.pop(context);
    }
  }
}