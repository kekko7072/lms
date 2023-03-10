import 'package:lms/services/imports.dart';
import 'package:flutter/cupertino.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await autoUpdater.setFeedURL(kFeedURL);
  await autoUpdater.checkForUpdates();
  await autoUpdater.setScheduledCheckInterval(3600);

  sqfliteFfiInit();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
  Database? db;

  AppData? appData;

  @override
  void initState() {
    super.initState();
    DatabaseLocal.openDB().then((value) {
      db = value;
      DatabaseLocal(value)
          .initDB()
          .then((value) => setState(() => appData = value));
    });
  }

  @override
  void dispose() {
    DatabaseLocal(db).closeDB();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () => showAboutApp(context),
              icon: const Icon(CupertinoIcons.infinite)),
          title: GestureDetector(
            child: const Text('Link Management System'),
            onTap: () => showAboutApp(context),
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (appData != null) ...[
                  if (appData?.groups != null &&
                      appData!.groups.isNotEmpty) ...[
                    Wrap(
                      direction: Axis.vertical,
                      alignment: WrapAlignment.center,
                      children: [
                        for (Group group in appData!.groups) ...[
                          GroupWidget(
                            db: db!,
                            group: group,
                            onDeleted: () async => await DatabaseLocal(db)
                                .readDB()
                                .then(
                                    (value) => setState(() => appData = value)),
                            contents: [
                              for (LMSContent content in appData!.contents
                                  .where((element) =>
                                      element.groupId == group.id)) ...[
                                LMSContentWidget(
                                    db: db!,
                                    lmsContent: content,
                                    onDeleted: () async => await DatabaseLocal(
                                            db)
                                        .readDB()
                                        .then((value) =>
                                            setState(() => appData = value)))
                              ]
                            ],
                          )
                        ]
                      ],
                    )
                  ]
                ]
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async => showDialog(
            context: context,
            barrierDismissible: false, // user must tap button!
            builder: (BuildContext context) {
              return AddWidget(
                  appData: appData!,
                  onPressed:
                      (bool addGroup, Group group, LMSContent content) async {
                    addGroup
                        ? await DatabaseLocal(db)
                            .dbGroupADD(group)
                            .then((value) async {
                            Navigator.of(context).pop();
                            value["success"]
                                ? EasyLoading.showSuccess(value["message"],
                                    duration: const Duration(seconds: 2))
                                : EasyLoading.showError(value["message"],
                                    duration: const Duration(seconds: 5));
                          })
                        : await DatabaseLocal(db)
                            .dbLMSContentADD(content)
                            .then((value) {
                            Navigator.of(context).pop();
                            value["success"]
                                ? EasyLoading.showSuccess(value["message"],
                                    duration: const Duration(seconds: 2))
                                : EasyLoading.showError(value["message"],
                                    duration: const Duration(seconds: 5));
                          });
                    await DatabaseLocal(db)
                        .readDB()
                        .then((value) => setState(() => appData = value));
                  });
            },
          ),
          tooltip: 'Add link',
          child: const Icon(Icons.add),
        ));
  }
}
