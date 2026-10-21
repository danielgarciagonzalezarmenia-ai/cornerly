import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final format = NumberFormat.currency(locale: 'es', symbol: '\$', decimalDigits: 0);

        return CupertinoPageScaffold(
          backgroundColor: const Color(0xFFF6F7F4),
          navigationBar: CupertinoNavigationBar(
            middle: const Text('Estadísticas'),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {},
              child: const Icon(CupertinoIcons.ellipsis, size: 22),
            ),
            backgroundColor: const Color(0xFFF6F7F4),
            previousPageTitle: 'Atrás',
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Ganancia/Pérdida neta', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        Text(
                          format.format(provider.totalWinnings - provider.totalLosses),
                          style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text('Meta del usuario', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            const Spacer(),
                            Text(format.format(provider.profile?.balance ?? 0), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Acierto semanal', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 140,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(7, (i) {
                              final active = i == 3;
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    width: 24,
                                    height: active ? 80 : 40,
                                    decoration: BoxDecoration(
                                      color: active ? AppColors.intenseGreen : const Color(0xFFE6E6E6),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text('D${i + 1}', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                  if (active)
                                    Container(
                                      margin: const EdgeInsets.only(top: 2),
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryGreen,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text('85%', style: TextStyle(fontSize: 9, color: Colors.white)),
                                    ),
                                ],
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _miniCard('Acierto %', '${provider.accuracyRate.toInt()}%', CupertinoIcons.checkmark_seal, AppColors.chipOrangeBg, AppColors.chipOrangeIcon),
                      _miniCard('Combinadas', '${provider.parlays.where((p) => p.status == 'won').length}/${provider.parlays.length}', CupertinoIcons.star, AppColors.chipBlueBg, AppColors.chipBlueIcon),
                      _miniCard('Cuota promedio', '1.85', CupertinoIcons.percent, AppColors.chipAmberBg, AppColors.chipAmberIcon),
                      _miniCard('Saldo', format.format(provider.profile?.balance ?? 0), CupertinoIcons.graph_square, AppColors.chipGreenBg, AppColors.chipGreenIcon),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Selector de rango', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _rangeButton('Semana', true),
                      const SizedBox(width: 8),
                      _rangeButton('Mes', false),
                      const SizedBox(width: 8),
                      _rangeButton('Todo', false),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _miniCard(String title, String value, IconData icon, Color bg, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF111111))),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF111111))),
        ],
      ),
    );
  }

  Widget _rangeButton(String title, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: active ? AppColors.primaryGreen : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: active ? Colors.white : AppColors.textSecondary,
        ),
      ),
    );
  }
}
