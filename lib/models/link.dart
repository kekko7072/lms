class Link {
  final String? title;
  final String? description;
  final String? url;

  const Link({
    this.title,
    this.description,
    this.url,
  });

  //Mapping into Json format
  Map<String, Object?> toJson() => {
        'title': title,
        'description': description,
        'url': url,
      };
}
