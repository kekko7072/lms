import 'package:about/about.dart';
import '../services/imports.dart';

Future<void> showAboutApp(BuildContext context) async =>
    await PackageInfo.fromPlatform()
        .then((PackageInfo packageInfo) => showAboutPage(
              context: context,
              values: {
                'version': packageInfo.version,
                'year': DateTime.now().year.toString(),
              },
              applicationLegalese:
                  'Copyright © Simone Porcari | Riccardo Rettore | Francesco Vezzani, {{ year }}',
              applicationDescription: const Text(
                  'Make managing your links quick and easy!\n\nThe Link Management System app makes it easy to store and manage all of your important links. Manage your entire link library with the app’s intuitive organisation system, which allows you to quickly find and open links by description or title.\nYou can also add code snippets and fast copy them and use in the fastest way.'),
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
              ],
              applicationIcon: const SizedBox(
                width: 100,
                height: 100,
                child: Image(
                  image: AssetImage('assets/icon.png'),
                ),
              ),
            ));
