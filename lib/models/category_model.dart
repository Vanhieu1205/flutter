class Category {
  final String id;
  final String name;
  final String type; // 'income' or 'expense'
  final String icon;
  final String color;

  Category({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'type': type, 'icon': icon, 'color': color};
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      icon: map['icon'] ?? '',
      color: map['color'] ?? '',
    );
  }
}
