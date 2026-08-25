import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/person.dart';
import '../models/form_config.dart';
import 'jalali_helper.dart';

class PdfGeneratorService {
  static Future<Uint8List> generateAttendancePdf({
    required List<Person> personnel,
    required FormConfig config,
  }) async {
    final pdf = pw.Document();

    // Load Persian font assets
    final regularFontData = await rootBundle.load(
      'assets/fonts/Vazirmatn-Regular.ttf',
    );
    final boldFontData = await rootBundle.load(
      'assets/fonts/Vazirmatn-Bold.ttf',
    );
    final ttfRegular = pw.Font.ttf(regularFontData);
    final ttfBold = pw.Font.ttf(boldFontData);

    final theme = pw.ThemeData.withFont(base: ttfRegular, bold: ttfBold);

    // Calculate month days
    final (firstHalfDays, secondHalfDays) = JalaliHelper.splitMonthHalves(
      config.year,
      config.month,
      firstHalfLimit: 16,
      usePersianDigits: config.showPersianNumbers,
    );

    // If personnel list is empty, provide at least one 3-person blank slot
    final effectivePersonnel = List<Person>.from(personnel);
    if (effectivePersonnel.isEmpty) {
      effectivePersonnel.add(Person(id: 'blank1', name: ''));
      effectivePersonnel.add(Person(id: 'blank2', name: ''));
      effectivePersonnel.add(Person(id: 'blank3', name: ''));
    }

    final int personsPerPage = config.personsPerPage > 0
        ? config.personsPerPage
        : 3;

    // Group personnel into chunks of personsPerPage (e.g. 3)
    final List<List<Person>> chunks = [];
    for (int i = 0; i < effectivePersonnel.length; i += personsPerPage) {
      final chunk = effectivePersonnel.sublist(
        i,
        min(i + personsPerPage, effectivePersonnel.length),
      );
      while (chunk.length < personsPerPage) {
        chunk.add(Person(id: 'blank_${chunk.length}', name: ''));
      }
      chunks.add(chunk);
    }

    final titleText = JalaliHelper.formatTitle(
      config.titleTemplate,
      config.year,
      config.month,
      usePersianDigits: config.showPersianNumbers,
    );

    for (int chunkIndex = 0; chunkIndex < chunks.length; chunkIndex++) {
      final chunk = chunks[chunkIndex];

      // Page 1: First Half (Days 1 to 16)
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.only(
            top:
                50, // Extra generous top margin for binder hole punch clearance
            bottom: 24,
            left: 30,
            right: 28,
          ),
          theme: theme,
          build: (pw.Context context) {
            return _buildFormGrid(
              title: titleText,
              personnelChunk: chunk,
              days: firstHalfDays,
              isSecondHalf: false,
              config: config,
              ttfRegular: ttfRegular,
              ttfBold: ttfBold,
            );
          },
        ),
      );

      // Page 2: Second Half (Days 17 to end of month)
      if (secondHalfDays.isNotEmpty) {
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4.landscape,
            margin: const pw.EdgeInsets.only(
              top: 50, // Extra generous top margin for binder hole punch clearance
              bottom: 24,
              left: 30,
              right: 28,
            ),
            theme: theme,
            build: (pw.Context context) {
              return _buildFormGrid(
                title: titleText,
                personnelChunk: chunk,
                days: secondHalfDays,
                isSecondHalf: true,
                config: config,
                ttfRegular: ttfRegular,
                ttfBold: ttfBold,
              );
            },
          ),
        );
      }
    }

    return pdf.save();
  }

  static pw.Widget _buildFormGrid({
    required String title,
    required List<Person> personnelChunk,
    required List<DayInfo> days,
    required bool isSecondHalf,
    required FormConfig config,
    required pw.Font ttfRegular,
    required pw.Font ttfBold,
  }) {
    const double borderWidth = 1.0;
    const borderColor = PdfColors.black;

    // Dimensions calibrated for binder margins on A4 Landscape
    const double headerDateHeight = 60.0;
    const double headerDayHeight = 40.0;
    const double dataRowHeight = 69.0;
    const int personCount = 3;
    const double personSpanHeight = dataRowHeight * 2; // 138.0
    const double allPersonsHeight = dataRowHeight * 6; // 414.0
    const double totalTableHeight =
        headerDateHeight + headerDayHeight + allPersonsHeight; // 514.0

    const double titleColWidth = 34.0;
    const double nameColWidth = 56.0;
    const double inOutColWidth = 28.0;
    const int totalDayColumns = 16;
    const double dayColWidth = 41.0;

    pw.BoxBorder cellBorder({
      bool top = true,
      bool bottom = true,
      bool left = true,
      bool right = true,
    }) {
      return pw.Border(
        top: top
            ? const pw.BorderSide(color: borderColor, width: borderWidth)
            : pw.BorderSide.none,
        bottom: bottom
            ? const pw.BorderSide(color: borderColor, width: borderWidth)
            : pw.BorderSide.none,
        left: left
            ? const pw.BorderSide(color: borderColor, width: borderWidth)
            : pw.BorderSide.none,
        right: right
            ? const pw.BorderSide(color: borderColor, width: borderWidth)
            : pw.BorderSide.none,
      );
    }

    return pw.Center(
      child: pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // ================= COLUMN 0: MAIN TITLE COLUMN (MERGED FULL HEIGHT) =================
          pw.Container(
            width: titleColWidth,
            height: totalTableHeight,
            alignment: pw.Alignment.center,
            decoration: pw.BoxDecoration(
              border: cellBorder(
                top: true,
                bottom: true,
                left: true,
                right: true,
              ),
            ),
            child: pw.Transform.rotateBox(
              angle: pi / 2,
              child: pw.Text(
                title,
                style: pw.TextStyle(font: ttfBold, fontSize: 11.0),
                textAlign: pw.TextAlign.center,
                textDirection: pw.TextDirection.rtl,
                softWrap: false,
              ),
            ),
          ),

          // ================= COLUMN 1: PERSONNEL NAMES COLUMN =================
          pw.Column(
            children: [
              // Row 0 header with dot '.' matching template
              pw.Container(
                width: nameColWidth,
                height: headerDateHeight,
                alignment: pw.Alignment.center,
                decoration: pw.BoxDecoration(
                  border: cellBorder(
                    top: true,
                    bottom: true,
                    left: false,
                    right: true,
                  ),
                ),
                child: pw.Text(
                  '',
                  style: pw.TextStyle(font: ttfBold, fontSize: 12.0),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              // Row 1 header spacer
              pw.Container(
                width: nameColWidth,
                height: headerDayHeight,
                decoration: pw.BoxDecoration(
                  border: cellBorder(
                    top: false,
                    bottom: true,
                    left: false,
                    right: true,
                  ),
                ),
              ),
              // 3 merged cells (each spanning 2 rows: ورود & خروج)
              for (int i = 0; i < personCount; i++)
                pw.Container(
                  width: nameColWidth,
                  height: personSpanHeight,
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.symmetric(horizontal: 2),
                  decoration: pw.BoxDecoration(
                    border: cellBorder(
                      top: false,
                      bottom: true,
                      left: false,
                      right: true,
                    ),
                  ),
                  child:
                      (i < personnelChunk.length &&
                          personnelChunk[i].name.isNotEmpty)
                      ? pw.Transform.rotateBox(
                          angle: pi / 2,
                          child: pw.Text(
                            personnelChunk[i].name,
                            style: pw.TextStyle(font: ttfBold, fontSize: 10.0),
                            textAlign: pw.TextAlign.center,
                            textDirection: pw.TextDirection.rtl,
                            softWrap: false,
                          ),
                        )
                      : pw.SizedBox(),
                ),
            ],
          ),

          // ================= COLUMN 2: IN / OUT LABEL COLUMN =================
          pw.Column(
            children: [
              // Header Row 1: تاریخ
              pw.Container(
                width: inOutColWidth,
                height: headerDateHeight,
                alignment: pw.Alignment.center,
                decoration: pw.BoxDecoration(
                  border: cellBorder(
                    top: true,
                    bottom: true,
                    left: false,
                    right: true,
                  ),
                ),
                child: pw.Transform.rotateBox(
                  angle: pi / 2,
                  child: pw.Text(
                    'تاریخ',
                    style: pw.TextStyle(font: ttfBold, fontSize: 9.5),
                    textAlign: pw.TextAlign.center,
                    textDirection: pw.TextDirection.rtl,
                    softWrap: false,
                  ),
                ),
              ),
              // Header Row 2: ایام
              pw.Container(
                width: inOutColWidth,
                height: headerDayHeight,
                alignment: pw.Alignment.center,
                decoration: pw.BoxDecoration(
                  border: cellBorder(
                    top: false,
                    bottom: true,
                    left: false,
                    right: true,
                  ),
                ),
                child: pw.Transform.rotateBox(
                  angle: pi / 2,
                  child: pw.Text(
                    'ایام',
                    style: pw.TextStyle(font: ttfBold, fontSize: 9.5),
                    textAlign: pw.TextAlign.center,
                    textDirection: pw.TextDirection.rtl,
                    softWrap: false,
                  ),
                ),
              ),
              // 6 Data Rows (ورود / خروج alternating)
              for (int i = 0; i < personCount; i++) ...[
                // ورود
                pw.Container(
                  width: inOutColWidth,
                  height: dataRowHeight,
                  alignment: pw.Alignment.center,
                  decoration: pw.BoxDecoration(
                    border: cellBorder(
                      top: false,
                      bottom: true,
                      left: false,
                      right: true,
                    ),
                  ),
                  child: pw.Transform.rotateBox(
                    angle: pi / 2,
                    child: pw.Text(
                      'ورود',
                      style: pw.TextStyle(font: ttfBold, fontSize: 8.5),
                      textAlign: pw.TextAlign.center,
                      textDirection: pw.TextDirection.rtl,
                      softWrap: false,
                    ),
                  ),
                ),
                // خروج
                pw.Container(
                  width: inOutColWidth,
                  height: dataRowHeight,
                  alignment: pw.Alignment.center,
                  decoration: pw.BoxDecoration(
                    border: cellBorder(
                      top: false,
                      bottom: true,
                      left: false,
                      right: true,
                    ),
                  ),
                  child: pw.Transform.rotateBox(
                    angle: pi / 2,
                    child: pw.Text(
                      'خروج',
                      style: pw.TextStyle(font: ttfBold, fontSize: 8.5),
                      textAlign: pw.TextAlign.center,
                      textDirection: pw.TextDirection.rtl,
                      softWrap: false,
                    ),
                  ),
                ),
              ],
            ],
          ),

          // ================= COLUMNS 3..18: 16 DAY COLUMNS =================
          for (int col = 0; col < totalDayColumns; col++)
            pw.Column(
              children: [
                // Row 0: Date Header (e.g. 1405/06/01  1)
                pw.Container(
                  width: dayColWidth,
                  height: headerDateHeight,
                  alignment: pw.Alignment.center,
                  decoration: pw.BoxDecoration(
                    border: cellBorder(
                      top: true,
                      bottom: true,
                      left: false,
                      right: true,
                    ),
                  ),
                  child: col < days.length
                      ? pw.Transform.rotateBox(
                          angle: pi / 2,
                          child: pw.Text(
                            days[col].formattedDate,
                            style: pw.TextStyle(
                              font: ttfRegular,
                              fontSize: 8.0,
                            ),
                            textAlign: pw.TextAlign.center,
                            textDirection: pw.TextDirection.rtl,
                            softWrap: false,
                          ),
                        )
                      : pw.SizedBox(),
                ),
                // Row 1: Weekday Header (e.g. یکشنبه)
                pw.Container(
                  width: dayColWidth,
                  height: headerDayHeight,
                  alignment: pw.Alignment.center,
                  decoration: pw.BoxDecoration(
                    border: cellBorder(
                      top: false,
                      bottom: true,
                      left: false,
                      right: true,
                    ),
                  ),
                  child: col < days.length
                      ? pw.Transform.rotateBox(
                          angle: pi / 2,
                          child: pw.Text(
                            days[col].weekdayName,
                            style: pw.TextStyle(
                              font: days[col].isFriday ? ttfBold : ttfRegular,
                              fontSize: 8.0,
                            ),
                            textAlign: pw.TextAlign.center,
                            textDirection: pw.TextDirection.rtl,
                            softWrap: false,
                          ),
                        )
                      : pw.SizedBox(),
                ),
                // 6 Data Cells (for In & Out times/signatures)
                for (int r = 0; r < personCount * 2; r++)
                  pw.Container(
                    width: dayColWidth,
                    height: dataRowHeight,
                    alignment: pw.Alignment.center,
                    decoration: pw.BoxDecoration(
                      border: cellBorder(
                        top: false,
                        bottom: true,
                        left: false,
                        right: true,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
