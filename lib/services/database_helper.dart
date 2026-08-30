// lib/services/database_helper.dart
// Offline SQLite Database helper for storing and retrieving patient records.

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/patient_record.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('osteosense_records.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp TEXT,
        visit_date TEXT,
        patient_id TEXT,
        name TEXT,
        age INTEGER,
        sex TEXT,
        occupation TEXT,
        womac_pain_walking INTEGER,
        womac_pain_stairs INTEGER,
        womac_stiffness INTEGER,
        womac_rising INTEGER,
        womac_squatting INTEGER,
        womac_total INTEGER,
        rom_left REAL,
        rom_right REAL,
        rom_asymmetry REAL,
        peak_flexion_right REAL,
        cadence REAL,
        jerk_left REAL,
        jerk_right REAL,
        sit_to_stand_time REAL,
        input_source TEXT,
        pose_confidence REAL,
        frames_tracked INTEGER,
        gait_score INTEGER,
        symptom_score INTEGER,
        risk_band TEXT,
        risk_score INTEGER
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE records ADD COLUMN sit_to_stand_time REAL DEFAULT 2.4');
      await db.execute('ALTER TABLE records ADD COLUMN input_source TEXT DEFAULT "Camera Pose Analysis"');
    }
  }

  Future<int> insertRecord(PatientRecord record) async {
    final db = await instance.database;
    return await db.insert('records', record.toMap());
  }

  Future<List<PatientRecord>> getRecordsByPatientId(String patientId) async {
    final db = await instance.database;
    final result = await db.query(
      'records',
      where: 'patient_id = ?',
      whereArgs: [patientId],
      orderBy: 'id DESC',
    );
    return result.map((json) => PatientRecord.fromMap(json)).toList();
  }

  Future<List<PatientRecord>> getAllRecords() async {
    final db = await instance.database;
    final result = await db.query('records', orderBy: 'id DESC');
    return result.map((json) => PatientRecord.fromMap(json)).toList();
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
