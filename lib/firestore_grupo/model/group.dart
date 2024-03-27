class Grupo {
  String id;
  String name;
  String date;

  Grupo({required this.id, required this.name, required this.date});

  Grupo.fromMap(Map<String, dynamic> map)
      : id = map["id"],
        name = map["name"],
        date = map['date'];

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "date": date,
    };
  }
}
