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

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'capacity': capacity,
      'status': status.toString().split('.').last,
    };
  }

  factory TableModel.fromMap(Map<String, dynamic> map) {
    return TableModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      capacity: map['capacity'] ?? 0,
      status: TableStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => TableStatus.available,
      ),
    );
  }
}
