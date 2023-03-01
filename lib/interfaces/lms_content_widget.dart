import 'package:lms/services/imports.dart';

class LMSContentWidget extends StatefulWidget {
  const LMSContentWidget(
      {Key? key, required this.lmsContent, required this.onDeleted})
      : super(key: key);
  final LMSContent lmsContent;
  final Function onDeleted;

  @override
  State<LMSContentWidget> createState() => _LMSContentWidgetState();
}

class _LMSContentWidgetState extends State<LMSContentWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250 + widget.lmsContent.title.characters.length * 10,
      child: Card(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: ActionChip(
                    padding: const EdgeInsets.all(5.0),
                    avatar: Icon(
                      widget.lmsContent.linkType == LinkType.url
                          ? Icons.link
                          : Icons.code,
                      color: Colors.white,
                    ),
                    label: Text(
                      widget.lmsContent.linkType == LinkType.url
                          ? "Url"
                          : 'Code',
                      style: const TextStyle(color: Colors.white),
                    ),
                    onPressed: () {},
                    backgroundColor: Colors.pink,
                  ),
                ),
                Text(
                  widget.lmsContent.title,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () async => await widget.onDeleted(),
                      icon: const Icon(
                        Icons.close,
                        color: Colors.red,
                      ),
                    )),
              ],
            ),
            Text(
              widget.lmsContent.description,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (widget.lmsContent.linkType == LinkType.code) ...[
              SelectableText(
                widget.lmsContent.content,
                style: const TextStyle(
                    color: Colors.pink,
                    fontWeight: FontWeight.bold,
                    fontSize: 25),
                textAlign: TextAlign.center,
                onTap: () async {
                  await Clipboard.setData(
                      ClipboardData(text: widget.lmsContent.content));
                  EasyLoading.showSuccess("Code copied");
                },
                contextMenuBuilder: (context, editableTextState) =>
                    const AlertDialog(),
                showCursor: true,
                cursorWidth: 2,
                cursorColor: Colors.red,
                cursorRadius: const Radius.circular(5),
              ),
            ] else if (widget.lmsContent.linkType == LinkType.url) ...[
              ///NEW
            ],
            const SizedBox(height: 5),
            TextButton(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.lmsContent.linkType == LinkType.code) ...[
                    const Icon(Icons.copy),
                    const SizedBox(width: 5),
                    const Text('Copy code'),
                  ] else if (widget.lmsContent.linkType == LinkType.url) ...[
                    const Icon(Icons.link),
                    const SizedBox(width: 5),
                    const Text('Open url'),
                  ],
                ],
              ),
              onPressed: () async {
                if (widget.lmsContent.linkType == LinkType.code) {
                  await Clipboard.setData(
                      ClipboardData(text: widget.lmsContent.content));
                  EasyLoading.showSuccess("Code copied");
                } else if (widget.lmsContent.linkType == LinkType.url) {
                  try {
                    await launchUrlString(widget.lmsContent.content);
                  } catch (e) {
                    EasyLoading.showError("Error launching url");
                  }
                }
              },
            ),
          ],
        ),
      )),
    );
  }
}
