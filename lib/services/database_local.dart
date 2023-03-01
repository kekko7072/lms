import 'package:lms/services/imports.dart';

class DatabaseLocal {
  late Database? db;
  DatabaseLocal(this.db);

  static Future<bool> configured() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(kDBConfigured) ?? false;
  }

  static Future<Database?> open() async {
    DatabaseFactory databaseFactory = databaseFactoryFfi;
    databaseFactory.setDatabasesPath(kDBPath);

    return await databaseFactory.openDatabase(kDBPath);
  }

  Future<List<LMSContent>?> init() async {
    if (kDebugMode) {
      print('DB VERSION:');
      print(await db?.getVersion());
    }

    if (await configured() && await db?.getVersion() == kDBVersion) {
      debugPrint("Database already created");
    } else {
      debugPrint("Create database");
      sqfliteFfiInit();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(kDBConfigured, true);

      try {
        await db?.setVersion(kDBVersion);

        await db?.execute('''
  CREATE TABLE $kDBTable (
      id INTEGER PRIMARY KEY,
      title TEXT,
      description TEXT,
      content TEXT,
      type TEXT
  )
  ''');
      } catch (e) {
        debugPrint("ERROR DB: $e");
      }
    }
    if (kDebugMode) {
      print('QUERY FROM DATABASE');
      print(await db?.query(kDBTable));
      print('\n\n');
    }
    return LMSContent.listFromJson(body: await db?.query(kDBTable));
  }

  Future<void> closeDB() async {
    if (db != null && db!.isOpen) {
      await db!.close();
    }
  }

  Future<Map<String, dynamic>> addLink(LMSContent lmsContent) async {
    try {
      await db?.insert(kDBTable, LMSContent.toJson(lmsContent));
    } catch (e) {
      debugPrint("ERROR CREATING: $e");
      return {"success": false, "message": "$e"};
    }
    if (await db?.query(kDBTable,
            where: 'content = ?', whereArgs: [lmsContent.content]) !=
        null) {
      return {"success": true, "message": "Created with success"};
    } else {
      debugPrint("Not created");
      return {"success": false, "message": "Error in creation"};
    }
  }

  Future<void> deleteLink({required String id}) async {
    await db?.delete(kDBTable, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<LMSContent>> readDB() async {
    debugPrint('Reading table $kDBTable');
    var body = await db?.query(kDBTable);
    debugPrint("BODY: $body");
    return LMSContent.listFromJson(body: body);
  }
}
