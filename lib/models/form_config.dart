class FormConfig {
  int year;
  int month;
  String titleTemplate;
  String organizationName;
  bool showPersianNumbers;
  int personsPerPage;

  FormConfig({
    required this.year,
    required this.month,
    this.titleTemplate = 'لیست ورود و خروج {month} ماه پرسنل {year}',
    this.organizationName = '',
    this.showPersianNumbers = false,
    this.personsPerPage = 3,
  });

  Map<String, dynamic> toJson() => {
        'year': year,
        'month': month,
        'titleTemplate': titleTemplate,
        'organizationName': organizationName,
        'showPersianNumbers': showPersianNumbers,
        'personsPerPage': personsPerPage,
      };

  factory FormConfig.fromJson(Map<String, dynamic> json) => FormConfig(
        year: json['year'] as int? ?? 1404,
        month: json['month'] as int? ?? 1,
        titleTemplate: json['titleTemplate'] as String? ?? 'لیست ورود و خروج {month} ماه پرسنل {year}',
        organizationName: json['organizationName'] as String? ?? '',
        showPersianNumbers: json['showPersianNumbers'] as bool? ?? false,
        personsPerPage: json['personsPerPage'] as int? ?? 3,
      );

  FormConfig copyWith({
    int? year,
    int? month,
    String? titleTemplate,
    String? organizationName,
    bool? showPersianNumbers,
    int? personsPerPage,
  }) {
    return FormConfig(
      year: year ?? this.year,
      month: month ?? this.month,
      titleTemplate: titleTemplate ?? this.titleTemplate,
      organizationName: organizationName ?? this.organizationName,
      showPersianNumbers: showPersianNumbers ?? this.showPersianNumbers,
      personsPerPage: personsPerPage ?? this.personsPerPage,
    );
  }
}
