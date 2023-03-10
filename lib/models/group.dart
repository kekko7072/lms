import 'package:flutter/foundation.dart';

class Group {
  final int id;
  final String title;
  final String description;

  const Group({
    required this.id,
    required this.title,
    required this.description,
  });

  static Map<String, Object?> toJson(Group content) {
    return <String, Object?>{
      'title': content.title,
      'description': content.description,
    };
  }

  //Mapping from Json format to map https://docs.flutter.dev/development/data-and-backend/json
  static Group fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
    );
  }

  //Mapping from Json format to map https://docs.flutter.dev/development/data-and-backend/json

  static List<Group> listFromJson({required List<Map<String, dynamic>>? body}) {
    List<Group> list = [];

    if (body != null) {
      for (Map<String, dynamic> value in body) {
        debugPrint('ID ${value['id']}');
        debugPrint('VALUE: $value');
        debugPrint('\n');

        list.add(Group.fromJson(value));
      }
    }

    return list;
  }
}
