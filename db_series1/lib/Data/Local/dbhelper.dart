import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  // Singleton pattern
  DBHelper._(); // Private constructor
  static final DBHelper getInstance = DBHelper._();

  // Table and columns
  static const String TABLE_NOTE = "note";
  static const String COLUMN_NOTE_SNO = "s_no";
  static const String COLUMN_NOTE_TITLE = "title";
  static const String COLUMN_NOTE_DESC = "desc";

  Database? _database;

  // Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _openDB();
    return _database!;
  }

  // Open database
  Future<Database> _openDB() async {
    try {
      Directory appDir = await getApplicationDocumentsDirectory();
      String dbPath = join(appDir.path, "noteDB.db");

      return await openDatabase(dbPath, onCreate: (db, version) {
        // Create table
        db.execute("CREATE TABLE $TABLE_NOTE ("
            "$COLUMN_NOTE_SNO INTEGER PRIMARY KEY AUTOINCREMENT, "
            "$COLUMN_NOTE_TITLE TEXT, "
            "$COLUMN_NOTE_DESC TEXT)");
      }, version: 1);
    } catch (e) {
      throw Exception("Error opening database: $e");
    }
  }

  // Insert a note
  Future<bool> addNote({
    required String mTitle,
    required String mDesc,
  }) async {
    try {
      final db = await database;
      int rowsAffected = await db.insert(
        TABLE_NOTE,
        {
          COLUMN_NOTE_TITLE: mTitle,
          COLUMN_NOTE_DESC: mDesc,
        },
      );
      return rowsAffected > 0;
    } catch (e) {
      print("Error inserting note: $e");
      return false;
    }
  }

  // Fetch all notes
  Future<List<Map<String, dynamic>>> getAllNotes() async {
    try {
      final db = await database;
      return await db.query(TABLE_NOTE); // SELECT * FROM note
    } catch (e) {
      print("Error fetching notes: $e");
      return [];
    }
  }

  //update data
  Future<bool> updateNote({
  required String mTitle, 
  required String mDesc, 
  required int sno
}) async {
  try {
    var db = await database;
    int rowsAffected = await db.update(
      TABLE_NOTE,
      {
        COLUMN_NOTE_TITLE: mTitle,
        COLUMN_NOTE_DESC: mDesc,
      },
      where: "$COLUMN_NOTE_SNO = ?", 
      whereArgs: [sno]
    );
    return rowsAffected > 0;
  } catch (e) {
    print("Error updating note: $e");
    return false;
  }
}

  //delete data
  Future<bool> deleteNote({required int sno}) async {
    var db = await database;

    int rowsEffected = await db
        .delete(TABLE_NOTE, where: "$COLUMN_NOTE_SNO = ? ", whereArgs: [sno]);

    return rowsEffected > 0;
  }
}
