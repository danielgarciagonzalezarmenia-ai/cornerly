import 'package:flutter/cupertino.dart';
import '../../models/data_models.dart';
import '../../theme/app_theme.dart';

class MatchDetailScreen extends StatelessWidget {
  final AnalyzedMatch match;

  const MatchDetailScreen({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF6F7F4),
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Detalle del partido'),
        backgroundColor: const Color(0xFFF6F7F4),
        previousPageTitle: 'Atrás',
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Expanded(child: Column(children: [
                    Text(match.localTeam, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text('Cuota ${match.oddsLocal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ])),
                  const Text('vs', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                  Expanded(child: Column(children: [
                    Text(match.visitorTeam, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text('Cuota ${match.oddsVisitor.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ])),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(24)),
                child: Column(
                  children: [
                    _detailRow('Liga', match.leagueName),
                    _detailRow('Hora', '${match.startTime.hour.toString().padLeft(2, '0')}:${match.startTime.minute.toString().padLeft(2, '0')}'),
                    _detailRow('Filtro aplicado', match.filter == 'A' ? 'Filtro A (Más de 7.5 corners)' : 'Filtro B (Menos de 11.5 corners)'),
                    _detailRow('Selección', match.selection),
                    _detailRow('Cuota corners', match.cornersOdds.toStringAsFixed(2)),
                    _detailRow('Estado', match.status.toUpperCase()),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text('Cuotas 1X2', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _oddsChip('Local', match.oddsLocal)),
                  Expanded(child: _oddsChip('Empate', match.oddsDraw)),
                  Expanded(child: _oddsChip('Visitante', match.oddsVisitor)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _oddsChip(String label, double odds) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.chipGreenBg, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.chipGreenIcon)),
          const SizedBox(height: 4),
          Text(odds.toStringAsFixed(2), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
