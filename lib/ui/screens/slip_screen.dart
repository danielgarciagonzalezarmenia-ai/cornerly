import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/data_models.dart';

class SlipScreen extends StatelessWidget {
  final List<AnalyzedMatch> selectedMatches;

  const SlipScreen({super.key, required this.selectedMatches});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final totalOdds = selectedMatches.fold(1.0, (p, m) => p * m.cornersOdds);

        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          decoration: const BoxDecoration(
            color: Color(0xFFFFFFFF),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: const Color(0xFFE6E6E6), borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text('Combinada', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  const Spacer(),
                  Text('${selectedMatches.length} selecciones', style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F7F4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Cuota total', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                        Text(totalOdds.toStringAsFixed(2), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('Monto a apostar', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    CupertinoTextField(
                      placeholder: 'Monto',
                      keyboardType: TextInputType.number,
                      padding: const EdgeInsets.all(14),
                      style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _quickAmountButton('5%', provider.profile?.balance ?? 0, 0.05),
                        const SizedBox(width: 8),
                        _quickAmountButton('10%', provider.profile?.balance ?? 0, 0.10),
                        const SizedBox(width: 8),
                        _quickAmountButton('25%', provider.profile?.balance ?? 0, 0.25),
                        const SizedBox(width: 8),
                        _quickAmountButton('50%', provider.profile?.balance ?? 0, 0.50),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Ganancia potencial', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                        Text('\$0', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primaryGreen)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: CupertinoButton.filled(
                  onPressed: () {},
                  child: const Text('Confirmar combinada', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _quickAmountButton(String label, double balance, double pct) {
    final amount = (balance * pct).toStringAsFixed(0);
    return Expanded(
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F7F4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text('$label\n$amount', textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: AppColors.textPrimary)),
          ),
        ),
      ),
    );
  }
}

void showSlip(BuildContext context, List<AnalyzedMatch> matches) {
  showModalBottomSheet(
    context: context,
    builder: (_) => SlipScreen(selectedMatches: matches),
  );
}
