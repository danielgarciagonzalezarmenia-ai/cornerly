import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../models/data_models.dart';

class DatabaseService {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final path = join(docsDir.path, 'cornerly.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_profile(
        id TEXT PRIMARY KEY,
        name TEXT,
        currency TEXT,
        currency_symbol TEXT,
        balance REAL,
        experience TEXT,
        risk_max_pct REAL,
        reminder_time TEXT,
        notifications_enabled INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE daily_analysis(
        id TEXT PRIMARY KEY,
        date TEXT UNIQUE,
        executed_at TEXT,
        total_matches_reviewed INTEGER,
        total_matches_filtered INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE analyzed_match(
        id TEXT PRIMARY KEY,
        event_id TEXT,
        league_name TEXT,
        league_logo TEXT,
        local_team TEXT,
        visitor_team TEXT,
        local_shield TEXT,
        visitor_shield TEXT,
        start_time TEXT,
        odds_local REAL,
        odds_draw REAL,
        odds_visitor REAL,
        filter TEXT,
        selection TEXT,
        corners_odds REAL,
        status TEXT,
        total_corners INTEGER,
        local_corners INTEGER,
        visitor_corners INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE parlay(
        id TEXT PRIMARY KEY,
        created_at TEXT,
        amount REAL,
        total_odds REAL,
        potential_win REAL,
        status TEXT,
        resolved_at TEXT,
        leg_event_ids TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE parlay_leg(
        id TEXT PRIMARY KEY,
        parlay_id TEXT,
        event_id TEXT,
        selection TEXT,
        odds REAL,
        real_corners INTEGER,
        result TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE balance_movement(
        id TEXT PRIMARY KEY,
        date TEXT,
        type TEXT,
        amount REAL,
        resulting_balance REAL
      )
    ''');
  }

  Future<void> close() async {
    final database = _db;
    if (database != null && database.isOpen) {
      await database.close();
      _db = null;
    }
  }

  // UserProfile
  Future<void> saveUserProfile(UserProfile profile) async {
    final database = await db;
    await database.insert(
      'user_profile',
      profile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserProfile?> getUserProfile() async {
    final database = await db;
    final maps = await database.query('user_profile', limit: 1);
    if (maps.isEmpty) return null;
    return UserProfile.fromMap(maps.first);
  }

  // DailyAnalysis
  Future<void> saveDailyAnalysis(DailyAnalysis analysis) async {
    final database = await db;
    await database.insert(
      'daily_analysis',
      analysis.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<DailyAnalysis?> getDailyAnalysisByDate(String date) async {
    final database = await db;
    final maps = await database.query(
      'daily_analysis',
      where: 'date = ?',
      whereArgs: [date],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return DailyAnalysis.fromMap(maps.first);
  }

  // AnalyzedMatch
  Future<void> saveAnalyzedMatch(AnalyzedMatch match) async {
    final database = await db;
    await database.insert(
      'analyzed_match',
      match.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<AnalyzedMatch>> getAnalyzedMatchesByDate(String date) async {
    final database = await db;
    final start = '${date}T00:00:00';
    final end = '${date}T23:59:59';
    final maps = await database.query(
      'analyzed_match',
      where: 'start_time >= ? AND start_time <= ?',
      whereArgs: [start, end],
      orderBy: 'start_time ASC',
    );
    return maps.map((m) => AnalyzedMatch.fromMap(m)).toList();
  }

  Future<List<AnalyzedMatch>> getAllAnalyzedMatches() async {
    final database = await db;
    final maps = await database.query(
      'analyzed_match',
      orderBy: 'start_time DESC',
    );
    return maps.map((m) => AnalyzedMatch.fromMap(m)).toList();
  }

  Future<void> updateMatchResult(String matchId, String status, {int? totalCorners, int? localCorners, int? visitorCorners}) async {
    final database = await db;
    await database.update(
      'analyzed_match',
      {
        'status': status,
        'total_corners': totalCorners,
        'local_corners': localCorners,
        'visitor_corners': visitorCorners,
      },
      where: 'id = ?',
      whereArgs: [matchId],
    );
  }

  // Parlay
  Future<void> saveParlay(Parlay parlay) async {
    final database = await db;
    await database.insert(
      'parlay',
      parlay.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Parlay>> getAllParlays() async {
    final database = await db;
    final maps = await database.query(
      'parlay',
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => Parlay.fromMap(m)).toList();
  }

  Future<void> updateParlayStatus(String parlayId, String status, {DateTime? resolvedAt}) async {
    final database = await db;
    await database.update(
      'parlay',
      {
        'status': status,
        'resolved_at': resolvedAt?.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [parlayId],
    );
  }

  // ParlayLeg
  Future<void> saveParlayLeg(ParlayLeg leg) async {
    final database = await db;
    await database.insert(
      'parlay_leg',
      leg.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ParlayLeg>> getParlayLegsByParlay(String parlayId) async {
    final database = await db;
    final maps = await database.query(
      'parlay_leg',
      where: 'parlay_id = ?',
      whereArgs: [parlayId],
    );
    return maps.map((m) => ParlayLeg.fromMap(m)).toList();
  }

  Future<void> updateParlayLegResult(String legId, String result, {int? realCorners}) async {
    final database = await db;
    await database.update(
      'parlay_leg',
      {'result': result, 'real_corners': realCorners},
      where: 'id = ?',
      whereArgs: [legId],
    );
  }

  // BalanceMovement
  Future<void> saveBalanceMovement(BalanceMovement movement) async {
    final database = await db;
    await database.insert(
      'balance_movement',
      movement.toMap(),
    );
  }

  Future<List<BalanceMovement>> getBalanceMovements() async {
    final database = await db;
    final maps = await database.query(
      'balance_movement',
      orderBy: 'date DESC',
    );
    return maps.map((m) => BalanceMovement.fromMap(m)).toList();
  }

  // Clear all
  Future<void> clearAllData() async {
    final database = await db;
    await database.delete('balance_movement');
    await database.delete('parlay_leg');
    await database.delete('parlay');
    await database.delete('analyzed_match');
    await database.delete('daily_analysis');
    await database.delete('user_profile');
  }
}
