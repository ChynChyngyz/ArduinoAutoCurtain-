// widgets/custom_app_bar.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/theme_provider.dart';
import '../provider/curtain_provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showIndicator;
  final VoidCallback? onStopPressed;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showIndicator = false,
    this.onStopPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(140);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return AppBar(
      toolbarHeight: 140,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Переключатель темы
              IconButton(
                icon: Icon(
                  themeProvider.isDarkMode
                      ? Icons.light_mode
                      : Icons.dark_mode,
                  color: themeProvider.isDarkMode
                      ? Colors.amber
                      : Colors.grey[800],
                ),
                onPressed: () => themeProvider.toggleTheme(),
                tooltip: themeProvider.isDarkMode
                    ? 'Переключить на светлую тему'
                    : 'Переключить на темную тему',
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (showIndicator) _buildIndicator(context),
        ],
      ),
      actions: [
        if (showIndicator && onStopPressed != null)
          IconButton(
            icon: const Icon(Icons.stop, color: Colors.red),
            onPressed: onStopPressed,
            tooltip: 'Остановить',
          ),
      ],
    );
  }

  Widget _buildIndicator(BuildContext context) {
    return Consumer<CurtainProvider>(
      builder: (context, curtainProvider, child) {
        return Column(
          children: [
            // Полоса прогресса
            Container(
              height: 20,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                children: [
                  // Заполненная часть
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: MediaQuery.of(context).size.width * curtainProvider.state.position,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.shade400,
                          Colors.blue.shade600,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  // Текст процентов
                  Center(
                    child: Text(
                      '${(curtainProvider.state.position * 100).toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            // Статус
            Row(
              children: [
                Icon(
                  curtainProvider.state.isMoving ? Icons.sync : Icons.check_circle,
                  size: 12,
                  color: curtainProvider.state.isMoving
                      ? Colors.orange
                      : Colors.green,
                ),
                const SizedBox(width: 4),
                Text(
                  curtainProvider.state.isMoving ? 'Движение...' : 'Готово',
                  style: TextStyle(
                    fontSize: 12,
                    color: curtainProvider.state.isMoving
                        ? Colors.orange
                        : Colors.green,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}