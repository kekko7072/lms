import 'package:lms/services/imports.dart';

class GroupWidget extends StatelessWidget {
  const GroupWidget({
    Key? key,
    required this.db,
    required this.group,
    required this.selected,
    required this.onSelected,
    required this.onDeleted,
  }) : super(key: key);

  final Database db;
  final Group group;
  final bool selected;
  final Function(int id) onSelected;
  final Function() onDeleted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20),
      child: ActionChip(
        elevation: 2.0,
        padding: const EdgeInsets.all(5.0),
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              group.title,
              style: TextStyle(color: selected ? Colors.white : Colors.pink),
            ),
            const SizedBox(width: 5),
            /*IconButton(
              icon: Icon(
                Icons.close,
                color: selected ? Colors.white : Colors.pink,
              ),
              onPressed: () => showDialog(
                  context: context,
                  builder: (builder) => DeleteWidget(
                      title: "Delete group ${group.title}",
                      onDeleted: () async => await DatabaseLocal(db)
                          .dbGroupDELETE(id: group.id.toString())
                          .then(
                            (value) => onDeleted(),
                          ))),
            )*/
          ],
        ),
        onPressed: () => onSelected(group.id),
        backgroundColor: selected ? Colors.pink : Colors.white,
      ),
    );
  }
}
