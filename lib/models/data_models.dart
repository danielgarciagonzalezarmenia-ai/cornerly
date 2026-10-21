import '../utils/constants.dart';

class UserProfile {
  final String id;
  final String name;
  final String currency;
  final String currencySymbol;
  double balance;
  final String experience;
  final double riskMaxPct;
  final String reminderTime;
  final bool notificationsEnabled;

  UserProfile({
    required this.id,
    required this.name,
    required this.currency,
    required this.currencySymbol,
    required this.balance,
    required this.experience,
    required this.riskMaxPct,
    required this.reminderTime,
    this.notificationsEnabled = false,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
    id: map['id'] as String,
    name: map['name'] as String,
    currency: map['currency'] as String,
    currencySymbol: map['currency_symbol'] as String,
    balance: (map['balance'] as num).toDouble(),
    experience: map['experience'] as String,
    riskMaxPct: (map['risk_max_pct'] as num).toDouble(),
    reminderTime: map['reminder_time'] as String,
    notificationsEnabled: (map['notifications_enabled'] as int?) == 1,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'currency': currency,
    'currency_symbol': currencySymbol,
    'balance': balance,
    'experience': experience,
    'risk_max_pct': riskMaxPct,
    'reminder_time': reminderTime,
    'notifications_enabled': notificationsEnabled ? 1 : 0,
  };

  UserProfile copyWith({
    String? name, String? currency, String? currencySymbol,
    double? balance, String? experience, double? riskMaxPct,
    String? reminderTime, bool? notificationsEnabled,
  }) => UserProfile(
    id: id,
    name: name ?? this.name,
    currency: currency ?? this.currency,
    currencySymbol: currencySymbol ?? this.currencySymbol,
    balance: balance ?? this.balance,
    experience: experience ?? this.experience,
    riskMaxPct: riskMaxPct ?? this.riskMaxPct,
    reminderTime: reminderTime ?? this.reminderTime,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
  );
}

class DailyAnalysis {
  final String id;
  final String date;
  final DateTime executedAt;
  final int totalMatchesReviewed;
  final int totalMatchesFiltered;

  DailyAnalysis({
    required this.id,
    required this.date,
    required this.executedAt,
    required this.totalMatchesReviewed,
    required this.totalMatchesFiltered,
  });

  factory DailyAnalysis.fromMap(Map<String, dynamic> map) => DailyAnalysis(
    id: map['id'] as String,
    date: map['date'] as String,
    executedAt: DateTime.parse(map['executed_at'] as String),
    totalMatchesReviewed: map['total_matches_reviewed'] as int,
    totalMatchesFiltered: map['total_matches_filtered'] as int,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'date': date,
    'executed_at': executedAt.toIso8601String(),
    'total_matches_reviewed': totalMatchesReviewed,
    'total_matches_filtered': totalMatchesFiltered,
  };
}

class AnalyzedMatch {
  final String id;
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
  final String filter; // 'A' or 'B'
  final String selection; // 'Más de 7.5' or 'Menos de 11.5'
  final double cornersOdds;
  final String status; // 'pending', 'won', 'lost', 'voided'
  final int? totalCorners;
  final int? localCorners;
  final int? visitorCorners;

  AnalyzedMatch({
    required this.id,
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
    required this.filter,
    required this.selection,
    required this.cornersOdds,
    this.status = 'pending',
    this.totalCorners,
    this.localCorners,
    this.visitorCorners,
  });

  factory AnalyzedMatch.fromMap(Map<String, dynamic> map) => AnalyzedMatch(
    id: map['id'] as String,
    eventId: map['event_id'] as String,
    leagueName: map['league_name'] as String,
    leagueLogo: map['league_logo'] as String?,
    localTeam: map['local_team'] as String,
    visitorTeam: map['visitor_team'] as String,
    localShield: map['local_shield'] as String?,
    visitorShield: map['visitor_shield'] as String?,
    startTime: DateTime.parse(map['start_time'] as String),
    oddsLocal: (map['odds_local'] as num).toDouble(),
    oddsDraw: (map['odds_draw'] as num).toDouble(),
    oddsVisitor: (map['odds_visitor'] as num).toDouble(),
    filter: map['filter'] as String,
    selection: map['selection'] as String,
    cornersOdds: (map['corners_odds'] as num).toDouble(),
    status: map['status'] as String? ?? 'pending',
    totalCorners: map['total_corners'] as int?,
    localCorners: map['local_corners'] as int?,
    visitorCorners: map['visitor_corners'] as int?,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'event_id': eventId,
    'league_name': leagueName,
    'league_logo': leagueLogo,
    'local_team': localTeam,
    'visitor_team': visitorTeam,
    'local_shield': localShield,
    'visitor_shield': visitorShield,
    'start_time': startTime.toIso8601String(),
    'odds_local': oddsLocal,
    'odds_draw': oddsDraw,
    'odds_visitor': oddsVisitor,
    'filter': filter,
    'selection': selection,
    'corners_odds': cornersOdds,
    'status': status,
    'total_corners': totalCorners,
    'local_corners': localCorners,
    'visitor_corners': visitorCorners,
  };

  bool get isOver7_5 => selection.contains('Más de 7.5');
  bool get isUnder11_5 => selection.contains('Menos de 11.5');

  bool evaluateResult() {
    if (totalCorners == null) return false;
    if (isOver7_5) return totalCorners! >= AppConstants.minTotalCornersForOver7;
    if (isUnder11_5) return totalCorners! <= AppConstants.maxTotalCornersForUnder11;
    return false;
  }
}

class Parlay {
  final String id;
  final DateTime createdAt;
  final double amount;
  final double totalOdds;
  final double potentialWin;
  String status; // 'pending', 'won', 'lost', 'voided'
  DateTime? resolvedAt;
  final List<String> legEventIds;

  Parlay({
    required this.id,
    required this.createdAt,
    required this.amount,
    required this.totalOdds,
    required this.potentialWin,
    this.status = 'pending',
    this.resolvedAt,
    required this.legEventIds,
  });

  factory Parlay.fromMap(Map<String, dynamic> map) => Parlay(
    id: map['id'] as String,
    createdAt: DateTime.parse(map['created_at'] as String),
    amount: (map['amount'] as num).toDouble(),
    totalOdds: (map['total_odds'] as num).toDouble(),
    potentialWin: (map['potential_win'] as num).toDouble(),
    status: map['status'] as String? ?? 'pending',
    resolvedAt: map['resolved_at'] != null ? DateTime.parse(map['resolved_at']) : null,
    legEventIds: (map['leg_event_ids'] as String).split(','),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'created_at': createdAt.toIso8601String(),
    'amount': amount,
    'total_odds': totalOdds,
    'potential_win': potentialWin,
    'status': status,
    'resolved_at': resolvedAt?.toIso8601String(),
    'leg_event_ids': legEventIds.join(','),
  };

  double get resolvedWin => status == 'won' ? amount * totalOdds : 0.0;
}

class ParlayLeg {
  final String id;
  final String parlayId;
  final String eventId;
  final String selection;
  final double odds;
  final int? realCorners;
  String result; // 'pending', 'hit', 'miss', 'voided'

  ParlayLeg({
    required this.id,
    required this.parlayId,
    required this.eventId,
    required this.selection,
    required this.odds,
    this.realCorners,
    this.result = 'pending',
  });

  factory ParlayLeg.fromMap(Map<String, dynamic> map) => ParlayLeg(
    id: map['id'] as String,
    parlayId: map['parlay_id'] as String,
    eventId: map['event_id'] as String,
    selection: map['selection'] as String,
    odds: (map['odds'] as num).toDouble(),
    realCorners: map['real_corners'] as int?,
    result: map['result'] as String? ?? 'pending',
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'parlay_id': parlayId,
    'event_id': eventId,
    'selection': selection,
    'odds': odds,
    'real_corners': realCorners,
    'result': result,
  };
}

class BalanceMovement {
  final String id;
  final DateTime date;
  final String type; // 'deposit', 'withdrawal', 'bet', 'win', 'adjustment'
  final double amount;
  final double resultingBalance;

  BalanceMovement({
    required this.id,
    required this.date,
    required this.type,
    required this.amount,
    required this.resultingBalance,
  });

  factory BalanceMovement.fromMap(Map<String, dynamic> map) => BalanceMovement(
    id: map['id'] as String,
    date: DateTime.parse(map['date'] as String),
    type: map['type'] as String,
    amount: (map['amount'] as num).toDouble(),
    resultingBalance: (map['resulting_balance'] as num).toDouble(),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'date': date.toIso8601String(),
    'type': type,
    'amount': amount,
    'resulting_balance': resultingBalance,
  };
}
