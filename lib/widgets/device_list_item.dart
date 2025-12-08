// widgets/device_list_item.dart

import 'package:flutter/material.dart';
import '../models/bluetooth_device.dart';

class DeviceListItem extends StatelessWidget {
  final DeviceInfo device;
  final bool isConnecting;
  final VoidCallback onConnect;

  const DeviceListItem({
    super.key,
    required this.device,
    required this.isConnecting,
    required this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.bluetooth, color: Colors.blue),
        title: Text(
          device.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          device.address,
          style: const TextStyle(fontFamily: 'monospace'),
        ),
        trailing: isConnecting
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
            : ElevatedButton(
          onPressed: device.isConnected ? null : onConnect,
          child: Text(device.isConnected ? 'Подключено' : 'Подключить'),
        ),
      ),
    );
  }
}