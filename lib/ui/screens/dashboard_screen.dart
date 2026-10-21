import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../widgets/match_card.dart';
import 'analysis_overlay_screen.dart';
import 'slip_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final _dateFormat = DateFormat('EEEE d MMMM', 'es');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().init();
    });
  }

  Future<void> _runAnalysis() async {
    await context.read<AppProvider>().runAnalysis();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final profile = provider.profile;
        final greeting = profile != null ? 'Buenos días, ${profile.name}' : 'Buenos días';
        final now = DateTime.now();
        final dateStr = _dateFormat.format(now);

        return CupertinoPageScaffold(
          backgroundColor: const Color(0xFFF6F7F4),
          navigationBar: CupertinoNavigationBar(
            middle: const Text('Cornerly'),
            backgroundColor: const Color(0xFFF6F7F4),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.primaryGreen,
                        child: Text(
                          (profile?.name.isNotEmpty == true ? profile!.name[0] : 'C').toUpperCase(),
                          style: const TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(greeting, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                            Text(dateStr, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {},
                        child: const Icon(CupertinoIcons.calendar, size: 24, color: AppColors.textPrimary),
                      ),
                      const SizedBox(width: 8),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {},
                        child: const Icon(CupertinoIcons.bell, size: 24, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
                _buildProgressCard(provider),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildSmallCard('Saldo actual', '\$0', AppColors.chipOrangeBg, AppColors.chipOrangeIcon, Icons.attach_money)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildSmallCard('Ganancia del mes', '\$0', AppColors.chipBlueBg, AppColors.chipBlueIcon, CupertinoIcons.graph_square)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildWeekCalendar(),
                const SizedBox(height: 12),
                Expanded(
                  child: provider.isLoading
                      ? const Center(child: CupertinoActivityIndicator())
                      : provider.analysisDoneToday
                          ? _buildAnalysisDone(provider)
                          : _buildAnalyzeButton(provider),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressCard(AppProvider provider) {
    final wins = provider.parlays.where((p) => p.status == 'won').length;
    final total = provider.parlays.where((p) => p.status == 'won' || p.status == 'lost').length;
    final pct = total == 0 ? 0.0 : (wins / total) * 100;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.weeklyProgress, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tu progreso semanal', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF111111))),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: pct / 100,
                      strokeWidth: 8,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation(AppColors.primaryGreen),
                    ),
                    Text('${pct.toInt()}%', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF111111))),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$wins de $total', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF111111))),
                    const SizedBox(height: 4),
                    Text('racha de días con análisis', style: const TextStyle(fontSize: 12, color: Color(0xFF8A8A8A))),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallCard(String title, String value, Color bg, Color iconColor, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(24)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF111111))),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111111))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeekCalendar() {
    final days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    final now = DateTime.now();
    final todayIndex = now.weekday - 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (i) {
          final isToday = i == todayIndex;
          return GestureDetector(
            onTap: () {},
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(days[i], style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isToday ? AppColors.primaryGreen : AppColors.textSecondary)),
                const SizedBox(height: 4),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(color: isToday ? AppColors.intenseGreen : Colors.transparent, shape: BoxShape.circle),
                  child: Center(
                    child: Text(
                      '${now.day + (i - todayIndex)}',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isToday ? Colors.white : AppColors.textPrimary),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAnalyzeButton(AppProvider provider) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Text('Análisis de hoy', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: CupertinoButton.filled(
            onPressed: _runAnalysis,
            child: const Text('Analizar partidos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 16),
        const Center(child: Text('Haz clic para analizar los partidos de hoy', style: TextStyle(fontSize: 13, color: AppColors.textSecondary))),
      ],
    );
  }

  Widget _buildAnalysisDone(AppProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Partidos de hoy', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _runAnalysis,
                child: const Text('Reanalizar', style: TextStyle(fontSize: 13, color: AppColors.primaryGreen)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (provider.todaysMatches.isEmpty)
          const Center(child: Text('Hoy ningún partido cumple tus filtros', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)))
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: provider.todaysMatches.length,
              itemBuilder: (context, i) {
                final match = provider.todaysMatches[i];
                return MatchCard(
                  match: match,
                  onAddToParlay: () {},
                  onTap: () {},
                );
              },
            ),
          ),
      ],
    );
  }
}
