import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import '../../models/person.dart';
import '../../models/form_config.dart';
import '../../services/pdf_generator_service.dart';
import '../../services/jalali_helper.dart';

class PdfPreviewView extends StatefulWidget {
  final List<Person> personnel;
  final FormConfig config;

  const PdfPreviewView({
    super.key,
    required this.personnel,
    required this.config,
  });

  @override
  State<PdfPreviewView> createState() => _PdfPreviewViewState();
}

class _PdfPreviewViewState extends State<PdfPreviewView> {
  int _refreshKey = 0;

  void _refresh() {
    setState(() {
      _refreshKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monthName = JalaliHelper.getMonthName(widget.config.month);
    final fileName = 'فرم_ورود_خروج_${monthName}_${widget.config.year}.pdf';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          // Action Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.picture_as_pdf, color: Color(0xFF1E3A8A), size: 24),
                const SizedBox(width: 10),
                Text(
                  'پیش‌نمایش سند PDF: $fileName',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: _refresh,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('به‌روزرسانی پیش‌نمایش'),
                ),
              ],
            ),
          ),

          // Interactive PDF Previewer
          Expanded(
            child: KeyedSubtree(
              key: ValueKey(_refreshKey),
              child: PdfPreview(
                maxPageWidth: 840,
                build: (format) => PdfGeneratorService.generateAttendancePdf(
                  personnel: widget.personnel,
                  config: widget.config,
                ),
                pdfFileName: fileName,
                canChangePageFormat: false,
                canChangeOrientation: false,
                canDebug: false,
                initialPageFormat: PdfPageFormat.a4.landscape,
                allowPrinting: true,
                allowSharing: true,
                loadingWidget: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        'در حال تولید صفحات PDF با قلم فارسی...',
                        style: TextStyle(
                          fontFamily: 'Vazirmatn',
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
