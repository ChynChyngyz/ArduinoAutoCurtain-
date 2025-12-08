// screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/bluetooth_provider.dart';
import '../provider/theme_provider.dart';
import './device_list_screen.dart';
import './control_screen.dart';
import '../widgets/custom_app_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bluetoothProvider = Provider.of<BluetoothProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Управление шторами',
        showIndicator: bluetoothProvider.isConnected,
        onStopPressed: () {
          bluetoothProvider.sendCommand('STOP');
        },
      ),
      body: bluetoothProvider.isConnected
          ? const ControlScreen()
          : _buildDisconnectedState(context, bluetoothProvider, themeProvider),
      bottomNavigationBar: _buildBottomBar(context, themeProvider),
    );
  }

  Widget _buildDisconnectedState(
      BuildContext context, BluetoothProvider provider, ThemeProvider themeProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bluetooth_disabled,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              'Bluetooth не подключен',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Подключитесь к устройству для управления шторами',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DeviceListScreen()), // Исправлено
                );
              },
              icon: const Icon(Icons.bluetooth),
              label: const Text('Выбрать устройство'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: provider.initialize,
              icon: const Icon(Icons.refresh),
              label: const Text('Обновить Bluetooth'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, ThemeProvider themeProvider) {
    return BottomAppBar(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Row(
              children: [
                Icon(
                  themeProvider.isDarkMode
                      ? Icons.nightlight_round
                      : Icons.wb_sunny,
                  color:
                  themeProvider.isDarkMode ? Colors.amber : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  themeProvider.isDarkMode ? 'Темная тема' : 'Светлая тема',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: themeProvider.isDarkMode ? Colors.amber : Colors.grey[800],
            ),
            onPressed: () => themeProvider.toggleTheme(),
            tooltip: 'Сменить тему',
          ),
        ],
      ),
    );
  }
}