import 'package:lms/services/imports.dart';

class AddWidget extends StatefulWidget {
  const AddWidget({Key? key, required this.onPressed}) : super(key: key);
  final Function(LMSContent content) onPressed;

  @override
  State<AddWidget> createState() => _AddWidgetState();
}

class _AddWidgetState extends State<AddWidget> {
  String title = '';
  String description = '';
  String url = '';
  LinkType linkType = LinkType.code;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Insert content'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ActionChip(
                  elevation: 2.0,
                  padding: const EdgeInsets.all(5.0),
                  avatar: Icon(
                    Icons.code,
                    color:
                        linkType == LinkType.code ? Colors.white : Colors.pink,
                  ),
                  label: Text(
                    'Code',
                    style: TextStyle(
                        color: linkType == LinkType.code
                            ? Colors.white
                            : Colors.pink),
                  ),
                  onPressed: () => setState(() => linkType = LinkType.code),
                  backgroundColor:
                      linkType == LinkType.code ? Colors.pink : Colors.white,
                ),
                ActionChip(
                  elevation: 2.0,
                  padding: const EdgeInsets.all(5.0),
                  avatar: Icon(
                    Icons.link,
                    color:
                        linkType == LinkType.url ? Colors.white : Colors.pink,
                  ),
                  label: Text(
                    'Url',
                    style: TextStyle(
                        color: linkType == LinkType.url
                            ? Colors.white
                            : Colors.pink),
                  ),
                  onPressed: () => setState(() => linkType = LinkType.url),
                  backgroundColor:
                      linkType == LinkType.url ? Colors.pink : Colors.white,
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Title (es. Monday meeting)',
              ),
              onChanged: (value) => title = value,
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText:
                    'Description (ex. ${linkType == LinkType.code ? "Create new file" : "Every friday"})',
              ),
              onChanged: (value) => description = value,
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: linkType == LinkType.code
                    ? 'Code (ex. sudo apt install)'
                    : 'Link (ex. site or meeting)',
              ),
              minLines: linkType == LinkType.code ? 2 : 1,
              maxLines: linkType == LinkType.code ? 5 : 2,
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
                .labelLarge!
                .copyWith(color: Colors.red),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          onPressed: () async => await widget.onPressed(LMSContent(
            id: 0,
            title: title,
            description: description,
            content: url,
            linkType: linkType,
          )),
          child: const Text('Save'),
        )
      ],
    );
  }
}
