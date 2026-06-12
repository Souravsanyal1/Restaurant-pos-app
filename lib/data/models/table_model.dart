enum TableStatus {
  available,
  reserved,
  occupied,
}

class TableModel {
  final String id;
  final String name;
  final int capacity;
  TableStatus status;

  TableModel({
    required this.id,
    required this.name,
    required this.capacity,
    required this.status,
  });

  TableModel copyWith({
    String? id,
    String? name,
    int? capacity,
    TableStatus? status,
  }) {
    return TableModel(
      id: id ?? this.id,
      name: name ?? this.name,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
    );
  }
}
