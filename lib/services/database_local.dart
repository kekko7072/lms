import 'package:lms/models/app_data.dart';
import 'package:lms/models/group.dart';
import 'package:lms/services/imports.dart';

class DatabaseLocal {
  late Database? db;
  DatabaseLocal(this.db);

  ///GENERIC OPERATIONS

  static Future<bool> configured() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(kDBConfigured) ?? false;
  }

  static Future<Database?> openDB() async {
    DatabaseFactory databaseFactory = databaseFactoryFfi;
    databaseFactory.setDatabasesPath(kDBPath);

    return await databaseFactory.openDatabase(kDBPath);
  }

  Future<void> closeDB() async {
    if (db != null && db!.isOpen) {
      await db!.close();
    }
  }

  Future<AppData> initDB() async {
    debugPrint('DB VERSION: ${await db?.getVersion()}');

    if (await configured() && (await db?.getVersion())! == kDBVersion) {
      debugPrint("Database already created");
    } else if (await configured() && (await db?.getVersion())! < kDBVersion) {
      try {
        //Command to update
        await db?.execute('ALTER TABLE $kDBTable ADD COLUMN groupId INTEGER');

        await dbGroupINIT();

        await dbGroupADD(const Group(
            id: 0,
            title: "First group",
            description: "This is your first group"));
      } catch (e) {
        debugPrint("Error in update");
      }

      //Update version of DB
      await db?.setVersion(kDBVersion);
    } else {
      debugPrint("Create database");
      sqfliteFfiInit();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(kDBConfigured, true);

      try {
        await db?.setVersion(kDBVersion);

        await dbLMSContentINIT();

        await dbGroupINIT();

        await dbGroupADD(const Group(
            id: 0,
            title: "First group",
            description: "This is your first group"));
      } catch (e) {
        debugPrint("ERROR DB: $e");
      }
    }

    return await readDB();
  }

  Future<AppData> readDB() async {
    debugPrint('DB VERSION: ${await db?.getVersion()}');

    debugPrint('QUERY FROM DATABASE');
    debugPrint('GROUP: ${await db?.query(kDBTableGroups)}');
    debugPrint('\n');
    debugPrint('LMS CONTENT: ${await db?.query(kDBTable)}');
    debugPrint('\n\n');

    return AppData(Group.listFromJson(body: await db?.query(kDBTableGroups)),
        LMSContent.listFromJson(body: await db?.query(kDBTable)));
  }

  ///LMS CONTENT
  Future<void> dbLMSContentINIT() async {
    try {
      await db?.execute('''
          CREATE TABLE $kDBTable (
            id INTEGER PRIMARY KEY,
            groupId INTEGER,
            title TEXT,
            description TEXT,
            content TEXT,
            type TEXT
          )''');
    } catch (e) {
      debugPrint("ERROR DB LMS CONTENT: $e");
    }
  }

  Future<Map<String, dynamic>> dbLMSContentADD(LMSContent lmsContent) async {
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

  Future<void> dbLMSContentDELETE({required String id}) async {
    await db?.delete(kDBTable, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<LMSContent>> dbLMSContentREAD() async {
    debugPrint('Reading table $kDBTable');
    var body = await db?.query(kDBTable);
    debugPrint("BODY: $body");
    return LMSContent.listFromJson(body: body);
  }

  ///

  /// GROUP
  Future<void> dbGroupINIT() async {
    try {
      await db?.execute('''
          CREATE TABLE $kDBTableGroups (
            id INTEGER PRIMARY KEY,
            title TEXT,
            description TEXT
          )''');
    } catch (e) {
      debugPrint("ERROR DB GROUP: $e");
    }
  }

  Future<Map<String, dynamic>> dbGroupADD(Group group) async {
    try {
      await db?.insert(kDBTableGroups, Group.toJson(group));
    } catch (e) {
      debugPrint("ERROR CREATING: $e");
      return {"success": false, "message": "$e"};
    }
    if (await db?.query(kDBTable, where: 'id = ?', whereArgs: [group.id]) !=
        null) {
      return {"success": true, "message": "Created with success"};
    } else {
      debugPrint("Not created");
      return {"success": false, "message": "Error in creation"};
    }
  }

  Future<void> dbGroupDELETE({required String id}) async {
    await db?.delete(kDBTableGroups, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Group>> dbGroupREAD() async {
    debugPrint('Reading table $kDBTableGroups');
    var body = await db?.query(kDBTableGroups);
    debugPrint("BODY: $body");
    return Group.listFromJson(body: body);
  }

  ///
}
