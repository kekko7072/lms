import 'package:about/about.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models/link.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io';

const String kDBPath = 'db';
const String kDBConfigured = 'db_configured';

const int kDBVersion = 1;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  LaunchAtStartup.instance.setup(
    appName: packageInfo.appName,
    appPath: Platform.resolvedExecutable,
  );

  sqfliteFfiInit();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
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
  bool _isEnabled = false;
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

  _init() async {
    _isEnabled = await launchAtStartup.isEnabled();
    setState(() {});
  }

  _handleEnable() async {
    await launchAtStartup.enable();
    await _init();
  }

  _handleDisable() async {
    await launchAtStartup.disable();
    await _init();
  }

  @override
  void initState() {
    super.initState();
    _init();
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
        leading: IconButton(
            onPressed: () async {
              PackageInfo packageInfo = await PackageInfo.fromPlatform();

              showAboutPage(
                context: context,
                values: {
                  'version': packageInfo.version,
                  'year': DateTime.now().year.toString(),
                },
                applicationLegalese:
                    'Copyright © Simone Porcari | Riccardo Rettore | Francesco Vezzani, {{ year }}',
                applicationDescription: const Text(
                    'Applicazione per la gestione dei link delle videochiamate.'),
                children: <Widget>[
                  const MarkdownPageListTile(
                    icon: Icon(Icons.list),
                    title: Text('Changelog'),
                    filename: 'CHANGELOG.md',
                  ),
                  const LicensesPageListTile(
                    icon: Icon(Icons.favorite),
                  ),
                  ListTile(
                    leading: Icon(_isEnabled
                        ? CupertinoIcons.check_mark_circled
                        : CupertinoIcons.xmark_circle),
                    title: const Text('Apertura al login'),
                    onTap: _isEnabled ? _handleDisable : _handleEnable,
                  ),
                ],
                applicationIcon: const SizedBox(
                  width: 100,
                  height: 100,
                  child: Image(
                    image: AssetImage('assets/icon.png'),
                  ),
                ),
              );
            },
            icon: const Icon(CupertinoIcons.infinite)),
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
