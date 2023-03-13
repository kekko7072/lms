import 'package:lms/models/lms_content.dart';

import 'group.dart';

class AppData {
  late List<Group> groups;
  late List<LMSContent> contents;

  AppData(this.groups, this.contents);
}
