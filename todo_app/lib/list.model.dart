class Todo {
  final String? name;
  final bool? check;

  Todo({
    this.name,
    this.check,
  });

  /// Map型に変換
  Map toJson() => {
        'name': name,
        'check': check,
      };

  /// JSONオブジェクトを代入
  Todo.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        check = json['check'];
}
