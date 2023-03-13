import 'package:flutter/foundation.dart';

enum LinkType { url, code }

class LMSContent {
  final int id;
  final int groupId;
  final String title;
  final String description;
  final String content;
  final LinkType linkType;

  const LMSContent({
    required this.id,
    required this.groupId,
    required this.title,
    required this.description,
    required this.content,
    required this.linkType,
  });

  static Map<String, Object?> toJson(LMSContent content) {
    return <String, Object?>{
      'groupId': content.groupId,
      'title': content.title,
      'description': content.description,
      'content': content.content,
      'type': content.linkType.toString(),
    };
  }

  //Mapping from Json format to map https://docs.flutter.dev/development/data-and-backend/json
  static LMSContent fromJson(Map<String, dynamic> json) {
    String linkTypeString = json['type'] ?? 'LinkType.url';
    LinkType linkType = LinkType.url;

    switch (linkTypeString) {
      case 'LinkType.url':
        linkType = LinkType.url;
        break;
      case 'LinkType.code':
        linkType = LinkType.code;
        break;
    }

    return LMSContent(
      id: json['id'] ?? 0,
      groupId: json['groupId'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      content: json['content'] ?? '',
      linkType: linkType,
    );
  }

  //Mapping from Json format to map https://docs.flutter.dev/development/data-and-backend/json

  static List<LMSContent> listFromJson(
      {required List<Map<String, dynamic>>? body}) {
    //1. Creo una lista vuota da usare per poi riempirla e ritornarla con i valori mappari
    List<LMSContent> list = [];

    //2. Verifico che il body non sia nullo altrimeti potrei avere errori.
    if (body != null) {
      //3. Ciclo for così ottengo i singoli valori dentro la lista di json file
      for (Map<String, dynamic> value in body) {
        if (kDebugMode) {
          print('VALUE ${value['id']}');
          print(value);
          print('\n');
        }

        //4. Aggiungo il singolo link alla lista
        list.add(LMSContent.fromJson(value));
      }
    }

    return list;
  }
}
