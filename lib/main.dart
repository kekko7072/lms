import 'package:lms/services/database_local.dart';
import 'package:lms/services/imports.dart';
import 'package:about/about.dart';
import 'package:flutter/cupertino.dart';
import 'package:lms/models/link.dart';
import 'package:url_launcher/url_launcher_string.dart';

const int kDBVersion = 1;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  /*LaunchAtStartup.instance.setup(
    appName: packageInfo.appName,
    appPath: Platform.resolvedExecutable,
  );*/

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
      builder: EasyLoading.init(),
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

  /*_init() async {
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
  }*/

  /* void _showMaterialDialog() async {
    await dbConfigured().then((value) {
      if (!_isEnabled && !value) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Open at login'),
                content: const Text('Do you want LMS open at login?'),
                actions: <Widget>[
                  TextButton(
                      onPressed: () async {
                        await _handleDisable();
                        Navigator.of(context).pop();
                      },
                      child: const Text('No')),
                  TextButton(
                    onPressed: () async {
                      await _handleEnable();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Si'),
                  )
                ],
              );
            });
      }
    });
  }
*/
  @override
  void initState() {
    super.initState();
    //_init();
    openDB();
  }

  @override
  void dispose() {
    DatabaseLocal(db).closeDB();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //_showMaterialDialog();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => showAboutApp(),
            icon: const Icon(CupertinoIcons.infinite)),
        title: GestureDetector(
          child: const Text('Link Management System'),
          onTap: () => showAboutApp(),
        ),
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
                            child: const Text('Open link'),
                            onPressed: () async {
                              if (!await launchUrlString(link.url.toString())) {
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
              title: const Text('Insert link'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Title (es. Monday meeting)',
                      ),
                      onChanged: (value) => title = value,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Description (es. Every friday)',
                      ),
                      onChanged: (value) => description = value,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Link (ex. site or meeting)',
                      ),
                      onChanged: (value) => url = value,
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'Cancel',
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
                  child: const Text('Save'),
                  onPressed: () async => await DatabaseLocal(db)
                      .addLink(title: title, description: description, url: url)
                      .then((value) => readDB())
                      .whenComplete(() => Navigator.of(context).pop()),
                ),
              ],
            );
          },
        ),
        tooltip: 'Add link',
        child: const Icon(Icons.add),
      ),
    );
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

  Future<void> showAboutApp() async => await PackageInfo.fromPlatform()
      .then((PackageInfo packageInfo) => showAboutPage(
            context: context,
            values: {
              'version': packageInfo.version,
              'year': DateTime.now().year.toString(),
            },
            applicationLegalese:
                'Copyright © Simone Porcari | Riccardo Rettore | Francesco Vezzani, {{ year }}',
            applicationDescription:
                const Text('Desktop application for links management.'),
            children: <Widget>[
              const MarkdownPageListTile(
                icon: Icon(Icons.list),
                title: Text('Changelog'),
                filename: 'CHANGELOG.md',
              ),
              const MarkdownPageListTile(
                icon: Icon(Icons.logo_dev),
                title: Text('Contributing'),
                filename: 'CONTRIBUTING.md',
              ),
              const LicensesPageListTile(
                icon: Icon(Icons.favorite),
              ),
              /* StatefulBuilder(
                builder: (context, setState) => ListTile(
                    leading: Icon(_isEnabled
                        ? CupertinoIcons.check_mark_circled
                        : CupertinoIcons.xmark_circle),
                    title: const Text('Launch at startup'),
                    onTap: () async {
                      if (_isEnabled) {
                        EasyLoading.showInfo('Disabled launch at startup');
                        await launchAtStartup.disable();
                      } else {
                        EasyLoading.showInfo('Enabled launch at startup');
                        await launchAtStartup.enable();
                      }
                      setState(() => _isEnabled = !_isEnabled);
                    }),
              ),
            */
            ],
            applicationIcon: const SizedBox(
              width: 100,
              height: 100,
              child: Image(
                image: AssetImage('assets/icon.png'),
              ),
            ),
          ));
}
