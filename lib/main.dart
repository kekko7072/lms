import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models/link.dart';

const String kDBPath = 'db';
const String kDBConfigured = 'db_configured';

const int kDBVersion = 1;

void main() {
  sqfliteFfiInit();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  SharedPreferences? prefs;

  Database? db;

  List<Link>? links;

  Future<bool> dbConfigured() async {
    prefs = await SharedPreferences.getInstance();
    return prefs!.getBool(kDBConfigured) ?? false;
  }

  Future<void> openDB() async {
    DatabaseFactory databaseFactory = databaseFactoryFfi;

    databaseFactory.setDatabasesPath(kDBPath);

    db = await databaseFactory.openDatabase(kDBPath);
    if (kDebugMode) {
      print('DB VERSION:');
      print(await db?.getVersion());
    }

    if (await dbConfigured() && await db?.getVersion() == kDBVersion) {
      //    if (db.getVersion()) expect(await db.getVersion(), 0);

    } else {
      sqfliteFfiInit();
      await prefs?.setBool('db_configured', true);

      await db?.setVersion(kDBVersion);

      await db?.execute('''
  CREATE TABLE Links (
      id INTEGER PRIMARY KEY,
      title TEXT,
      description TEXT,
      url TEXT
  )
  ''');
    }
    if (kDebugMode) {
      print('QUERY FROM DATABASE');
      print(await db?.query('Links'));
      print('\n\n');
    }
    links = Link.fromJson(body: await db?.query('Links'));

    if (kDebugMode) {
      print('first read DB');
    }
    setState(() {});
  }

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

  Future<void> deleteLink({required String id}) async {
    await db?.delete('Links', where: 'id = ?', whereArgs: [id]);
    setState(() {});
  }

  Future<void> readDB() async {
    links = Link.fromJson(body: await db?.query('Links'));
    if (kDebugMode) {
      print('read DB');
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    openDB();
  }

  @override
  void dispose() {
    closeDB();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Link Management System'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (links != null && links!.isNotEmpty) ...{
              Wrap(
                children: [
                  for (var link in links!) ...[
                    SizedBox(
                      width: 300,
                      child: Card(
                          child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Text(
                                link.title,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Align(
                                  alignment: Alignment.topRight,
                                  child: IconButton(
                                    onPressed: () async =>
                                        await deleteLink(id: link.id.toString())
                                            .then((value) => readDB()),
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.red,
                                    ),
                                  )),
                            ],
                          ),
                          Text(
                            link.description,
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                          TextButton(
                            child: const Text('Apri link'),
                            onPressed: () async {
                              if (!await launch(link.url.toString())) {
                                throw 'Could not launch ${link.url.toString()}';
                              }
                            },
                          ),
                        ],
                      )),
                    ),
                  ]
                ],
              )
            }
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async => showDialog(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            String title = '';
            String description = '';
            String url = '';

            return AlertDialog(
              title: const Text('Inserisci link'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Titolo',
                      ),
                      onChanged: (value) => title = value,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Descrizione',
                      ),
                      onChanged: (value) => description = value,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Link della videochiamata',
                      ),
                      onChanged: (value) => url = value,
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'Annulla',
                    style: Theme.of(context)
                        .textTheme
                        .button!
                        .copyWith(color: Colors.red),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Salva'),
                  onPressed: () async {
                    await addLink(
                            title: title, description: description, url: url)
                        .then((value) => readDB());
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        ),
        tooltip: 'Aggiungi link',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
