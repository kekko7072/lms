import 'package:lms/services/imports.dart';
import 'package:flutter/cupertino.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  List<LMSContent>? links;

  @override
  void initState() {
    super.initState();
    DatabaseLocal.open().then((value) {
      db = value;
      DatabaseLocal(value)
          .init()
          .then((value) => setState(() => links = value));
    });
  }

  @override
  void dispose() {
    DatabaseLocal(db).closeDB();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //DatabaseLocal(db).readDB().then((value) => setState(() => links = value));

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
                if (links != null && links!.isNotEmpty) ...{
                  Wrap(
                    children: [
                      for (LMSContent content in links!) ...[
                        LMSContentWidget(
                            lmsContent: content,
                            onDeleted: () async => await DatabaseLocal(db)
                                .deleteLink(id: content.id.toString())
                                .whenComplete(() => DatabaseLocal(db)
                                    .readDB()
                                    .then((value) =>
                                        setState(() => links = value))))
                      ]
                    ],
                  )
                }
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
                  onPressed: (LMSContent content) async =>
                      await DatabaseLocal(db).addLink(content).then((value) {
                        Navigator.of(context).pop();
                        value["success"]
                            ? EasyLoading.showSuccess(value["message"],
                                duration: const Duration(seconds: 2))
                            : EasyLoading.showError(value["message"],
                                duration: const Duration(seconds: 5));
                        DatabaseLocal(db)
                            .readDB()
                            .then((value) => setState(() => links = value));
                      }));
            },
          ),
          tooltip: 'Add link',
          child: const Icon(Icons.add),
        ));
  }
}
