import 'package:lms/services/imports.dart';

class DatabaseLocal{
  final Database? db;
  DatabaseLocal( this.db);


  Future<void> closeDB() async {
    if (db != null && db!.isOpen) {
      await db!.close();
    }
  }
  Future<bool> addLink(
      {required String title,
        required String description,
        required String url}) async {
    await db?.insert('Links', <String, Object?>{
      'title': title,
      'description': description,
      'url': url
    });
    if (await db?.query('Links', where: 'url = ?', whereArgs: [url]) != null) {
      return true;
    }
    return false;
  }
}