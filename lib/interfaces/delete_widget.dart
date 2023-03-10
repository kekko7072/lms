import 'package:lms/services/imports.dart';

class DeleteWidget extends StatelessWidget {
  const DeleteWidget({Key? key, required this.title, required this.onDeleted})
      : super(key: key);

  final String title;

  final Function() onDeleted;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      actions: <Widget>[
        TextButton(
          child: Text(
            'Cancel',
            style: Theme.of(context)
                .textTheme
                .labelLarge!
                .copyWith(color: Colors.red),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop();
            await onDeleted();
          },
          child: const Text('Delete'),
        )
      ],
    );
  }
}
