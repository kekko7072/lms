import 'package:lms/services/imports.dart';

class GroupWidget extends StatefulWidget {
  const GroupWidget(
      {Key? key,
      required this.db,
      required this.group,
      required this.onDeleted,
      required this.contents})
      : super(key: key);

  final Database db;
  final Group group;
  final Function() onDeleted;
  final List<Widget> contents;
  @override
  State<GroupWidget> createState() => _GroupWidgetState();
}

class _GroupWidgetState extends State<GroupWidget> {
  bool expand = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
        child: Column(
          children: [
            ActionChip(
              elevation: 2.0,
              padding: const EdgeInsets.all(5.0),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.group.title,
                    style:
                        TextStyle(color: expand ? Colors.white : Colors.pink),
                  ),
                  const SizedBox(width: 5),
                  Icon(
                    expand ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    color: expand ? Colors.white : Colors.pink,
                  )
                ],
              ),
              onPressed: () => setState(() => expand = !expand),
              backgroundColor: expand ? Colors.pink : Colors.white,
            ),
            const SizedBox(height: 10),
            Visibility(
                visible: expand,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: widget.contents,
                ))
          ],
        ),
      ),
      onLongPress: () => showDialog(
          context: context,
          builder: (builder) => DeleteWidget(
              title: "Delete group ${widget.group.title}",
              onDeleted: () async => await DatabaseLocal(widget.db)
                  .dbGroupDELETE(id: widget.group.id.toString())
                  .then(
                    (value) => widget.onDeleted(),
                  ))),
    );
  }
}
