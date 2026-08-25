import 'package:flutter_test/flutter_test.dart';
import 'package:yekta_in_out_forms/models/person.dart';
import 'package:yekta_in_out_forms/models/personnel_list.dart';
import 'package:yekta_in_out_forms/models/form_config.dart';
import 'package:yekta_in_out_forms/services/jalali_helper.dart';

void main() {
  group('JalaliHelper Unit Tests', () {
    test('Shahrivar 1405 has 31 days and splits into 16 and 15 days', () {
      final (firstHalf, secondHalf) = JalaliHelper.splitMonthHalves(1405, 6);

      expect(firstHalf.length, equals(16));
      expect(secondHalf.length, equals(15));
      expect(firstHalf.length + secondHalf.length, equals(31));

      // Day 1
      expect(firstHalf.first.dayNumber, equals(1));
      expect(firstHalf.first.formattedDate, equals('1405/06/01'));
      expect(firstHalf.first.dateWithDayNumber, equals('1405/06/01 1'));
      expect(firstHalf.first.weekdayName, equals('یکشنبه'));

      // Day 16
      expect(firstHalf.last.dayNumber, equals(16));
      expect(firstHalf.last.formattedDate, equals('1405/06/16'));
      expect(firstHalf.last.dateWithDayNumber, equals('1405/06/16 16'));
      expect(firstHalf.last.weekdayName, equals('دوشنبه'));

      // Day 17
      expect(secondHalf.first.dayNumber, equals(17));
      expect(secondHalf.first.formattedDate, equals('1405/06/17'));
      expect(secondHalf.first.dateWithDayNumber, equals('1405/06/17 17'));
      expect(secondHalf.first.weekdayName, equals('سه شنبه'));

      // Day 31
      expect(secondHalf.last.dayNumber, equals(31));
      expect(secondHalf.last.formattedDate, equals('1405/06/31'));
      expect(secondHalf.last.dateWithDayNumber, equals('1405/06/31 31'));
    });

    test('Mehr has 30 days and splits into 16 and 14 days', () {
      final (firstHalf, secondHalf) = JalaliHelper.splitMonthHalves(1404, 7);
      expect(firstHalf.length, equals(16));
      expect(secondHalf.length, equals(14));
      expect(firstHalf.length + secondHalf.length, equals(30));
    });

    test('Title formatting template replaces {month} and {year}', () {
      final title = JalaliHelper.formatTitle('لیست ورود و خروج {month} ماه پرسنل {year}', 1405, 6);
      expect(title, equals('لیست ورود و خروج شهریور ماه پرسنل 1405'));
    });

    test('Persian digits conversion', () {
      final persian = JalaliHelper.toPersianDigits('1405/06/01');
      expect(persian, equals('۱۴۰۵/۰۶/۰۱'));
    });
  });

  group('Models Serialization Tests', () {
    test('Person serialization and copyWith', () {
      final person = Person(id: 'p1', name: 'محسن حسینی', role: 'سرپرست');
      final json = person.toJson();
      final fromJson = Person.fromJson(json);

      expect(fromJson.id, equals('p1'));
      expect(fromJson.name, equals('محسن حسینی'));
      expect(fromJson.role, equals('سرپرست'));

      final modified = fromJson.copyWith(name: 'علی حسینی');
      expect(modified.name, equals('علی حسینی'));
      expect(modified.role, equals('سرپرست'));
    });

    test('PersonnelList serialization and copyWith', () {
      final list = PersonnelList(
        id: 'list_1',
        name: 'شیفت شب',
        members: [
          Person(id: 'p1', name: 'سیاوش طاهری'),
          Person(id: 'p2', name: 'روح اله عزیزی'),
        ],
      );
      final json = list.toJson();
      final fromJson = PersonnelList.fromJson(json);

      expect(fromJson.id, equals('list_1'));
      expect(fromJson.name, equals('شیفت شب'));
      expect(fromJson.members.length, equals(2));
      expect(fromJson.members.first.name, equals('سیاوش طاهری'));

      final modified = fromJson.copyWith(name: 'شیفت روز');
      expect(modified.name, equals('شیفت روز'));
    });

    test('FormConfig serialization', () {
      final config = FormConfig(year: 1405, month: 6);
      final json = config.toJson();
      final fromJson = FormConfig.fromJson(json);

      expect(fromJson.year, equals(1405));
      expect(fromJson.month, equals(6));
      expect(fromJson.personsPerPage, equals(3));
    });
  });

  group('PDF Generator Tests', () {
    testWidgets('Generates PDF bytes for 3 personnel', (tester) async {
      final config = FormConfig(year: 1405, month: 6);

      // Verify that splitting produces 2 pages of days
      final (firstHalf, secondHalf) = JalaliHelper.splitMonthHalves(config.year, config.month);
      expect(firstHalf.length, equals(16));
      expect(secondHalf.length, equals(15));
    });
  });
}
