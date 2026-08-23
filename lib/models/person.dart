class Person {
  final String id;
  String name;
  String? role;
  String? employeeCode;

  Person({
    required this.id,
    required this.name,
    this.role,
    this.employeeCode,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'role': role,
        'employeeCode': employeeCode,
      };

  factory Person.fromJson(Map<String, dynamic> json) => Person(
        id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: json['name'] as String? ?? '',
        role: json['role'] as String?,
        employeeCode: json['employeeCode'] as String?,
      );

  Person copyWith({
    String? id,
    String? name,
    String? role,
    String? employeeCode,
  }) {
    return Person(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      employeeCode: employeeCode ?? this.employeeCode,
    );
  }
}
