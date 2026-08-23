import 'package:shamsi_date/shamsi_date.dart';

class DayInfo {
  final int dayNumber;
  final String formattedDate; // e.g. "1405/06/01"
  final String dateWithDayNumber; // e.g. "1405/06/01 1"
  final String weekdayName; // e.g. "یکشنبه"
  final bool isFriday;
  final Jalali jalali;

  DayInfo({
    required this.dayNumber,
    required this.formattedDate,
    required this.dateWithDayNumber,
    required this.weekdayName,
    required this.isFriday,
    required this.jalali,
  });
}

class JalaliHelper {
  static const List<String> persianMonthNames = [
    'فروردین',
    'اردیبهشت',
    'خرداد',
    'تیر',
    'مرداد',
    'شهریور',
    'مهر',
    'آبان',
    'آذر',
    'دی',
    'بهمن',
    'اسفند',
  ];

  static const List<String> persianWeekdays = [
    'شنبه',
    'یکشنبه',
    'دوشنبه',
    'سه شنبه',
    'چهارشنبه',
    'پنج شنبه',
    'جمعه',
  ];

  static int currentYear() {
    return Jalali.now().year;
  }

  static int currentMonth() {
    return Jalali.now().month;
  }

  static String getMonthName(int month) {
    if (month >= 1 && month <= 12) {
      return persianMonthNames[month - 1];
    }
    return '';
  }

  static String toPersianDigits(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    var result = input;
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], persian[i]);
    }
    return result;
  }

  static List<DayInfo> getMonthDays(int year, int month, {bool usePersianDigits = false}) {
    final firstDay = Jalali(year, month, 1);
    final int monthLength = firstDay.monthLength;
    final List<DayInfo> days = [];

    for (int day = 1; day <= monthLength; day++) {
      final current = Jalali(year, month, day);
      final monthStr = month.toString().padLeft(2, '0');
      final dayStr = day.toString().padLeft(2, '0');
      final rawDate = '$year/$monthStr/$dayStr';
      final rawDateWithDay = '$rawDate $day';
      var weekday = current.formatter.wN; // e.g. یک شنبه -> یکشنبه
      if (weekday == 'یک شنبه') weekday = 'یکشنبه';
      if (weekday == 'دو شنبه') weekday = 'دوشنبه';
      if (weekday == 'چهار شنبه') weekday = 'چهارشنبه';
      final isFriday = current.weekDay == 7; // Friday in shamsi_date is 7

      days.add(DayInfo(
        dayNumber: day,
        formattedDate: usePersianDigits ? toPersianDigits(rawDate) : rawDate,
        dateWithDayNumber: usePersianDigits ? toPersianDigits(rawDateWithDay) : rawDateWithDay,
        weekdayName: weekday,
        isFriday: isFriday,
        jalali: current,
      ));
    }

    return days;
  }

  static (List<DayInfo>, List<DayInfo>) splitMonthHalves(
    int year,
    int month, {
    int firstHalfLimit = 16,
    bool usePersianDigits = false,
  }) {
    final allDays = getMonthDays(year, month, usePersianDigits: usePersianDigits);
    final limit = allDays.length >= firstHalfLimit ? firstHalfLimit : allDays.length;
    final firstHalf = allDays.sublist(0, limit);
    final secondHalf = allDays.length > limit ? allDays.sublist(limit) : <DayInfo>[];
    return (firstHalf, secondHalf);
  }

  static String formatTitle(String template, int year, int month, {bool usePersianDigits = false}) {
    final monthName = getMonthName(month);
    final yearStr = usePersianDigits ? toPersianDigits(year.toString()) : year.toString();
    var result = template
        .replaceAll('{month}', monthName)
        .replaceAll('{year}', yearStr);
    return result;
  }
}
