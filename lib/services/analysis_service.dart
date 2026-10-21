import 'package:intl/intl.dart';
import '../models/data_models.dart';
import '../services/database_service.dart';
import '../services/sofascore_repository.dart';
import '../utils/constants.dart';

class AnalysisResult {
  final List<AnalyzedMatch> matches;
  final int totalReviewed;
  final int totalFiltered;
  final String? error;

  AnalysisResult({
    required this.matches,
    required this.totalReviewed,
    required this.totalFiltered,
    this.error,
  });

  bool get hasError => error != null;
  bool get hasMatches => matches.isNotEmpty;
}

class AnalysisService {
  final DatabaseService _db;
  final SofascoreRepository _api;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  AnalysisService(this._db, this._api);

  Future<AnalysisResult> runDailyAnalysis() async {
    final now = DateTime.now();
    final today = _dateFormat.format(now);

    // Verificar si ya se analizó hoy
    final existing = await _db.getDailyAnalysisByDate(today);
    if (existing != null) {
      final matches = await _db.getAnalyzedMatchesByDate(today);
      return AnalysisResult(
        matches: matches,
        totalReviewed: existing.totalMatchesReviewed,
        totalFiltered: existing.totalMatchesFiltered,
      );
    }

    int totalReviewed = 0;
    int totalFiltered = 0;
    final matches = <AnalyzedMatch>[];
    String? error;

    try {
      final sofascoreMatches = await _api.getScheduledMatches(now);
      totalReviewed = sofascoreMatches.length;

      for (final sm in sofascoreMatches) {
        totalFiltered++;
        final analyzedMatch = AnalyzedMatch(
          id: sm.eventId,
          eventId: sm.eventId,
          leagueName: sm.leagueName,
          leagueLogo: sm.leagueLogo,
          localTeam: sm.localTeam,
          visitorTeam: sm.visitorTeam,
          localShield: sm.localShield,
          visitorShield: sm.visitorShield,
          startTime: sm.startTime,
          oddsLocal: sm.oddsLocal,
          oddsDraw: sm.oddsDraw,
          oddsVisitor: sm.oddsVisitor,
          filter: sm.filter,
          selection: sm.filter == 'A' ? 'Más de 7.5 corners' : 'Menos de 11.5 corners',
          cornersOdds: sm.filter == 'A' ? sm.cornersOverOdds ?? 0.0 : sm.cornersUnderOdds ?? 0.0,
          status: 'pending',
        );
        await _db.saveAnalyzedMatch(analyzedMatch);
        matches.add(analyzedMatch);
      }

      await _db.saveDailyAnalysis(DailyAnalysis(
        id: today,
        date: today,
        executedAt: now,
        totalMatchesReviewed: totalReviewed,
        totalMatchesFiltered: totalFiltered,
      ));
    } on SofascoreException catch (e) {
      error = e.message;
    } catch (e) {
      error = 'Error al ejecutar el análisis diario';
    }

    return AnalysisResult(
      matches: matches,
      totalReviewed: totalReviewed,
      totalFiltered: totalFiltered,
      error: error,
    );
  }

  Future<List<AnalyzedMatch>> getTodaysMatches() async {
    final today = _dateFormat.format(DateTime.now());
    return await _db.getAnalyzedMatchesByDate(today);
  }

  Future<bool> hasAnalysisToday() async {
    final today = _dateFormat.format(DateTime.now());
    final existing = await _db.getDailyAnalysisByDate(today);
    return existing != null;
  }

  Future<List<AnalyzedMatch>> getAllMatches() async {
    return await _db.getAllAnalyzedMatches();
  }

  Future<void> updateMatchResult(String matchId, String status, {int? totalCorners, int? localCorners, int? visitorCorners}) async {
    await _db.updateMatchResult(matchId, status, totalCorners: totalCorners, localCorners: localCorners, visitorCorners: visitorCorners);
  }

  static bool filterA(double localOdds) => localOdds < AppConstants.filterAMaxLocalOdds;
  static bool filterB(double localOdds, double visitorOdds) =>
      localOdds > AppConstants.filterBMinLocalOdds &&
      visitorOdds > localOdds &&
      visitorOdds < AppConstants.filterBMaxVisitorOdds;
}
