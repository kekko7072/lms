import 'package:flutter/foundation.dart';

class Link {
  //Ok null safety ma quando serve, questi valori non devono essere null senno la UX non va bene
  final int id;
  final String title;
  final String description;
  final String url;

  const Link({
    required this.id,
    required this.title,
    required this.description,
    required this.url,
  });

  //Mapping from Json format to map https://docs.flutter.dev/development/data-and-backend/json
  static List<Link> fromJson({required List<Map<String, dynamic>>? body}) {
    //1. Creo una lista vuota da usare per poi riempirla e ritornarla con i valori mappari
    List<Link> list = [];

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
        list.add(Link(
          //Di ogni elemento faccio il cast e metto anche un valore di default se value['key'] mi ritorna nullo
          id: value['id'] ?? 0,
          title: value['title'] ?? '',
          description: value['description'] ?? '',
          url: value['url'] ?? '',
        ));
      }
    }

    return list;
  }
}
