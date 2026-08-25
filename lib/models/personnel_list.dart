import 'person.dart';

class PersonnelList {
  final String id;
  final String name;
  final List<Person> members;

  const PersonnelList({
    required this.id,
    required this.name,
    this.members = const [],
  });

  PersonnelList copyWith({
    String? id,
    String? name,
    List<Person>? members,
  }) {
    return PersonnelList(
      id: id ?? this.id,
      name: name ?? this.name,
      members: members ?? this.members,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'members': members.map((p) => p.toJson()).toList(),
      };

  factory PersonnelList.fromJson(Map<String, dynamic> json) {
    final rawMembers = json['members'] as List<dynamic>? ?? [];
    return PersonnelList(
      id: json['id'] as String? ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['name'] as String? ?? 'لیست پرسنل',
      members: rawMembers
          .map((item) => Person.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
