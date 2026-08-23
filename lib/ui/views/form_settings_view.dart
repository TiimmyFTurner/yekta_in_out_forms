import 'package:flutter/material.dart';
import '../../models/form_config.dart';
import '../../models/person.dart';
import '../../services/jalali_helper.dart';

class FormSettingsView extends StatefulWidget {
  final FormConfig config;
  final List<Person> personnel;
  final ValueChanged<FormConfig> onConfigChanged;
  final VoidCallback onPreviewRequested;

  const FormSettingsView({
    super.key,
    required this.config,
    required this.personnel,
    required this.onConfigChanged,
    required this.onPreviewRequested,
  });

  @override
  State<FormSettingsView> createState() => _FormSettingsViewState();
}

class _FormSettingsViewState extends State<FormSettingsView> {
  late TextEditingController _titleController;
  late TextEditingController _yearController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.config.titleTemplate);
    _yearController = TextEditingController(text: widget.config.year.toString());
  }

  @override
  void didUpdateWidget(covariant FormSettingsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config.titleTemplate != widget.config.titleTemplate) {
      _titleController.text = widget.config.titleTemplate;
    }
    if (oldWidget.config.year != widget.config.year) {
      _yearController.text = widget.config.year.toString();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _updateYear(int year) {
    if (year < 1300 || year > 1500) return;
    final updated = widget.config.copyWith(year: year);
    _yearController.text = year.toString();
    widget.onConfigChanged(updated);
  }

  void _updateMonth(int month) {
    final updated = widget.config.copyWith(month: month);
    widget.onConfigChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (firstHalf, secondHalf) = JalaliHelper.splitMonthHalves(
      widget.config.year,
      widget.config.month,
      usePersianDigits: widget.config.showPersianNumbers,
    );

    final totalDays = firstHalf.length + secondHalf.length;
    final totalPersonnel = widget.personnel.length;
    final totalGroups = totalPersonnel == 0 ? 1 : (totalPersonnel / 3).ceil();
    final totalPages = totalGroups * 2;

    final liveTitle = JalaliHelper.formatTitle(
      widget.config.titleTemplate,
      widget.config.year,
      widget.config.month,
      usePersianDigits: widget.config.showPersianNumbers,
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Section: Year & Live Title Banner
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.tune, color: Color(0xFF1E3A8A)),
                        const SizedBox(width: 8),
                        Text(
                          'تنظیمات سال و عنوان فرم',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        // Year Stepper / Selector
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('سال خورشیدی:', style: TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  IconButton.filledTonal(
                                    icon: const Icon(Icons.remove),
                                    onPressed: () => _updateYear(widget.config.year - 1),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: _yearController,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(isDense: true),
                                      onSubmitted: (val) {
                                        final y = int.tryParse(val);
                                        if (y != null) _updateYear(y);
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton.filledTonal(
                                    icon: const Icon(Icons.add),
                                    onPressed: () => _updateYear(widget.config.year + 1),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        // Title Template
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('الگوی عنوان سربرگ:', style: TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _titleController,
                                decoration: const InputDecoration(
                                  hintText: 'لیست ورود و خروج {month} ماه پرسنل {year}',
                                  helperText: 'از {month} برای نام ماه و {year} برای سال استفاده کنید',
                                  isDense: true,
                                ),
                                onChanged: (val) {
                                  widget.onConfigChanged(widget.config.copyWith(titleTemplate: val));
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Live title preview badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.visibility, size: 20, color: Color(0xFF1E3A8A)),
                          const SizedBox(width: 8),
                          const Text('پیش‌نمایش عنوان در جدول: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Expanded(
                            child: Text(
                              liveTitle,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.primary,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Month Selector Grid (12 Months)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_month, color: Color(0xFF0F766E)),
                            const SizedBox(width: 8),
                            Text(
                              'انتخاب ماه (تقویم شمسی)',
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'ماه انتخابی: ${JalaliHelper.getMonthName(widget.config.month)} ($totalDays روز)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 1.6,
                      ),
                      itemCount: 12,
                      itemBuilder: (context, index) {
                        final monthNum = index + 1;
                        final isSelected = widget.config.month == monthNum;
                        final name = JalaliHelper.getMonthName(monthNum);
                        final daysInMonth = monthNum <= 6 ? 31 : (monthNum <= 11 ? 30 : 29);

                        return Material(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(12),
                          elevation: isSelected ? 2 : 0,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _updateMonth(monthNum),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$daysInMonth روز',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isSelected
                                          ? Colors.white.withValues(alpha: 0.85)
                                          : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Half-Month Calculation Summary & Total Pages
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Half-month details card
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.splitscreen, color: Color(0xFFC2410C)),
                              const SizedBox(width: 8),
                              Text(
                                'تفکیک دو نیمه ماه برای فرم‌ها',
                                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('• نیمه اول (صفحه اول هر گروه):'),
                                    Text(
                                      'روز ۱ تا ${firstHalf.length} (${firstHalf.length} روز)',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const Divider(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('• نیمه دوم (صفحه دوم هر گروه):'),
                                    Text(
                                      'روز ۱۷ تا $totalDays (${secondHalf.length} روز)',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('استفاده از اعداد فارسی در تاریخ‌ها', style: TextStyle(fontSize: 13.5)),
                            subtitle: const Text('مانند ۱۴۰۵/۰۶/۰۱ به جای 1405/06/01', style: TextStyle(fontSize: 12)),
                            value: widget.config.showPersianNumbers,
                            onChanged: (val) {
                              widget.onConfigChanged(widget.config.copyWith(showPersianNumbers: val));
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Summary & Print CTA card
                Expanded(
                  child: Card(
                    color: theme.colorScheme.primary.withValues(alpha: 0.04),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.summarize, color: Color(0xFF1E3A8A)),
                              const SizedBox(width: 8),
                              Text(
                                'خلاصه مشخصات چاپ خروجی',
                                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('قطع و جهت کاغذ:'),
                              const Text('A4 افقی (Landscape)', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('ظرفیت هر صفحه:'),
                              const Text('۳ نفر پرسنل', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('تعداد کل صفحات سند:'),
                              Text(
                                '$totalPages صفحه ($totalGroups گروه ۳ نفره)',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: widget.onPreviewRequested,
                              icon: const Icon(Icons.picture_as_pdf),
                              label: const Text('مشاهده و چاپ فرم PDF'),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
