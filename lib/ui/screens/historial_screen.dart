import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/data_models.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';

class HistorialScreen extends StatelessWidget {
  const HistorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final parlays = provider.parlays;

        return CupertinoPageScaffold(
          backgroundColor: const Color(0xFFF6F7F4),
          navigationBar: CupertinoNavigationBar(
            middle: const Text('Historial'),
            backgroundColor: const Color(0xFFF6F7F4),
            previousPageTitle: 'Atrás',
          ),
          child: SafeArea(
            child: parlays.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.clock, size: 64, color: Color(0xFFE6E6E6)),
                        SizedBox(height: 16),
                        Text('No hay combinadas aún', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: parlays.length,
                    itemBuilder: (context, i) {
                      final p = parlays[i];
                      return _ParlayItem(parlay: p);
                    },
                  ),
          ),
        );
      },
    );
  }
}

class _ParlayItem extends StatelessWidget {
  final Parlay parlay;

  const _ParlayItem({required this.parlay});

  Color _statusColor(String status) {
    switch (status) {
      case 'won': return AppColors.greenWin;
      case 'lost': return AppColors.redLoss;
      case 'pending': return AppColors.pendingAmber;
      default: return AppColors.textSecondary;
    }
  }

  String _statusText(String status) {
    switch (status) {
      case 'won': return 'Ganada';
      case 'lost': return 'Perdida';
      case 'pending': return 'Pendiente';
      default: return 'Anulada';
    }
  }

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat.currency(locale: 'es', symbol: '\$', decimalDigits: 0);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('dd/MM/yyyy HH:mm', 'es').format(parlay.createdAt),
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(parlay.status).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _statusText(parlay.status),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _statusColor(parlay.status)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${parlay.legEventIds.length} selecciones', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    Text('Cuota ${parlay.totalOdds.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  ],
                ),
              ),
              Text(format.format(parlay.amount), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            ],
          ),
        ],
      ),
    );
  }
}
