import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class SofascoreException implements Exception {
  final String message;
  final int? statusCode;
  SofascoreException(this.message, [this.statusCode]);
}

class SofascoreMatch {
  final String eventId;
  final String leagueName;
  final String? leagueLogo;
  final String localTeam;
  final String visitorTeam;
  final String? localShield;
  final String? visitorShield;
  final DateTime startTime;
  final double oddsLocal;
  final double oddsDraw;
  final double oddsVisitor;
  final double? cornersOverOdds;
  final double? cornersUnderOdds;
  final String filter;

  SofascoreMatch({
    required this.eventId,
    required this.leagueName,
    this.leagueLogo,
    required this.localTeam,
    required this.visitorTeam,
    this.localShield,
    this.visitorShield,
    required this.startTime,
    required this.oddsLocal,
    required this.oddsDraw,
    required this.oddsVisitor,
    this.cornersOverOdds,
    this.cornersUnderOdds,
    required this.filter,
  });
}

class SofascoreRepository {
  static const int _maxConcurrent = 3;
  static const int _maxRetries = 3;
  int _activeRequests = 0;
  final Map<String, dynamic> _cache = {};
  static const Duration _cacheDuration = Duration(minutes: 5);

  final http.Client _client;

  SofascoreRepository({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> get _headers => {
    'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1',
    'Accept': 'application/json',
    'Referer': 'https://www.sofascore.com/',
    'Accept-Language': 'es-ES,es;q=0.9',
  };

  Future<Map<String, dynamic>> _fetchJson(String url) async {
    if (_cache.containsKey(url)) {
      final entry = _cache[url];
      if (DateTime.now().difference(entry['time']) < _cacheDuration) {
        return entry['data'] as Map<String, dynamic>;
      }
    }

    while (_activeRequests >= _maxConcurrent) {
      await Future.delayed(const Duration(milliseconds: 200));
    }
    _activeRequests++;

    try {
      for (int attempt = 0; attempt < _maxRetries; attempt++) {
        try {
          final response = await _client.get(Uri.parse(url), headers: _headers);

          if (response.statusCode == 403 || response.statusCode == 429) {
            await Future.delayed(Duration(seconds: 2 * (attempt + 1)));
            continue;
          }

          if (response.statusCode >= 400) {
            throw SofascoreException('Error ${response.statusCode} al consultar Sofascore', response.statusCode);
          }

          final json = jsonDecode(response.body) as Map<String, dynamic>;
          _cache[url] = {'data': json, 'time': DateTime.now()};
          return json;
        } on SofascoreException {
          rethrow;
        } catch (e) {
          if (attempt == _maxRetries - 1) rethrow;
          await Future.delayed(Duration(seconds: 2 * (attempt + 1)));
        }
      }
      throw SofascoreException('No se pudo conectar con Sofascore tras varios intentos');
    } finally {
      _activeRequests--;
    }
  }

  Future<List<SofascoreMatch>> getScheduledMatches(DateTime date) async {
    final dateStr = '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
    final url = '${AppConstants.sofascoreBaseUrl}/sport/football/scheduled-events/$dateStr';

    final json = await _fetchJson(url);
    final events = json['events'] as List<dynamic>?;
    if (events == null) return [];

    final matches = <SofascoreMatch>[];
    for (final event in events) {
      try {
        final eventId = event['id']?.toString() ?? '';
        if (eventId.isEmpty) continue;

        final tournament = event['tournament'] as Map<String, dynamic>?;
        final leagueName = tournament?['name']?.toString() ?? '';
        final leagueLogo = tournament?['logo']?.toString();

        final homeTeam = event['homeTeam'] as Map<String, dynamic>?;
        final awayTeam = event['awayTeam'] as Map<String, dynamic>?;
        final localTeam = homeTeam?['name']?.toString() ?? '';
        final visitorTeam = awayTeam?['name']?.toString() ?? '';
        final localShield = homeTeam?['logo']?.toString();
        final visitorShield = awayTeam?['logo']?.toString();

        final startTimestamp = event['startTimestamp'] as int?;
        final startTime = startTimestamp != null
            ? DateTime.fromMillisecondsSinceEpoch(startTimestamp * 1000)
            : DateTime.now();

        final odds = await _getOdds(eventId);
        final oddsLocal = odds['1'] ?? 0.0;
        final oddsDraw = odds['X'] ?? 0.0;
        final oddsVisitor = odds['2'] ?? 0.0;

        if (oddsLocal == 0.0) continue;

        String? filter;
        if (oddsLocal < AppConstants.filterAMaxLocalOdds) {
          filter = 'A';
        } else if (oddsLocal > AppConstants.filterBMinLocalOdds &&
            oddsVisitor > oddsLocal &&
            oddsVisitor < AppConstants.filterBMaxVisitorOdds) {
          filter = 'B';
        }

        if (filter == null) continue;

        double? cornersOverOdds;
        double? cornersUnderOdds;
        final cornersOdds = await _getCornersOdds(eventId, filter);
        if (cornersOdds == null) continue;

        if (filter == 'A') {
          cornersOverOdds = cornersOdds;
        } else {
          cornersUnderOdds = cornersOdds;
        }

        matches.add(SofascoreMatch(
          eventId: eventId,
          leagueName: leagueName,
          leagueLogo: leagueLogo,
          localTeam: localTeam,
          visitorTeam: visitorTeam,
          localShield: localShield,
          visitorShield: visitorShield,
          startTime: startTime,
          oddsLocal: oddsLocal,
          oddsDraw: oddsDraw,
          oddsVisitor: oddsVisitor,
          cornersOverOdds: cornersOverOdds,
          cornersUnderOdds: cornersUnderOdds,
          filter: filter,
        ));
      } catch (e) {
        continue;
      }
    }

    matches.sort((a, b) => a.startTime.compareTo(b.startTime));
    return matches;
  }

  Future<Map<String, double>> _getOdds(String eventId) async {
    final url = '${AppConstants.sofascoreBaseUrl}/event/$eventId/odds/1/all';
    final json = await _fetchJson(url);
    final oddsMap = <String, double>{};

    final oddsData = json['odds'] as Map<String, dynamic>?;
    if (oddsData == null) return oddsMap;

    for (final entry in oddsData.entries) {
      final market = entry.value as Map<String, dynamic>?;
      if (market == null) continue;
      final odd1 = market['1'] as num?;
      final oddX = market['X'] as num?;
      final odd2 = market['2'] as num?;
      if (odd1 != null) oddsMap['1'] = odd1.toDouble();
      if (oddX != null) oddsMap['X'] = oddX.toDouble();
      if (odd2 != null) oddsMap['2'] = odd2.toDouble();
    }
    return oddsMap;
  }

  Future<double?> _getCornersOdds(String eventId, String filter) async {
    final line = filter == 'A' ? AppConstants.cornersLineA : AppConstants.cornersLineB;
    final url = '${AppConstants.sofascoreBaseUrl}/event/$eventId/odds/1/all';
    final json = await _fetchJson(url);

    final oddsData = json['odds'] as Map<String, dynamic>?;
    if (oddsData == null) return null;

    for (final entry in oddsData.entries) {
      final market = entry.value as Map<String, dynamic>?;
      if (market == null) continue;
      final marketName = market['name']?.toString() ?? '';
      if (!marketName.toLowerCase().contains('corner')) continue;

      final oddsCategories = market['odds'] as Map<String, dynamic>?;
      if (oddsCategories == null) continue;

      for (final catEntry in oddsCategories.entries) {
        final category = catEntry.value as Map<String, dynamic>?;
        if (category == null) continue;
        final lineValue = (category['line'] as num?)?.toDouble();
        if (lineValue == null || (lineValue - line).abs() > 0.001) continue;

        final oddKey = filter == 'A' ? 'over' : 'under';
        final oddValue = category[oddKey] as num?;
        if (oddValue != null) return oddValue.toDouble();

        for (final valEntry in category.entries) {
          if (valEntry.key.toLowerCase().contains(oddKey)) {
            final v = valEntry.value as num?;
            if (v != null) return v.toDouble();
          }
        }
      }
    }
    return null;
  }

  static double parseFractionalOdds(String fractional) {
    final parts = fractional.split('/');
    if (parts.length == 2) {
      final num = double.tryParse(parts[0].trim()) ?? 0.0;
      final den = double.tryParse(parts[1].trim()) ?? 1.0;
      return 1.0 + (num / den);
    }
    return double.tryParse(fractional) ?? 0.0;
  }

  void dispose() {
    _client.close();
  }
}
