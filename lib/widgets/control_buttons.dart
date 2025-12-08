// widgets/control_buttons.dart

import 'package:flutter/material.dart';

class ControlButtons extends StatelessWidget {
  final VoidCallback onOpenPressed;
  final VoidCallback onClosePressed;
  final VoidCallback onOpenHoldStart;
  final VoidCallback onCloseHoldStart;
  final VoidCallback onHoldEnd;
  final VoidCallback onPausePressed;

  const ControlButtons({
    super.key,
    required this.onOpenPressed,
    required this.onClosePressed,
    required this.onOpenHoldStart,
    required this.onCloseHoldStart,
    required this.onHoldEnd,
    required this.onPausePressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Кнопка полного открытия
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onOpenPressed,
            icon: const Icon(Icons.arrow_upward),
            label: const Text('Полное открытие'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Центральная панель с кнопками удержания и паузы
        Row(
          children: [
            // Кнопка удержания для открытия
            Expanded(
              child: GestureDetector(
                onTapDown: (_) => onOpenHoldStart(),
                onTapUp: (_) => onHoldEnd(),
                onTapCancel: onHoldEnd,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_upward,
                        size: 40,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Открывать',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '(удерживать)',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.green.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Кнопка паузы
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orange.shade50,
                border: Border.all(color: Colors.orange, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: onPausePressed,
                icon: Icon(
                  Icons.pause,
                  size: 40,
                  color: Colors.orange,
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Кнопка удержания для закрытия
            Expanded(
              child: GestureDetector(
                onTapDown: (_) => onCloseHoldStart(),
                onTapUp: (_) => onHoldEnd(),
                onTapCancel: onHoldEnd,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_downward,
                        size: 40,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Закрывать',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '(удерживать)',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.red.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Кнопка полного закрытия
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onClosePressed,
            icon: const Icon(Icons.arrow_downward),
            label: const Text('Полное закрытие'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}