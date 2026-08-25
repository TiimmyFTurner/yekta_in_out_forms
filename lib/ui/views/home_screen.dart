import 'package:flutter/material.dart';
import '../../models/person.dart';
import '../../models/personnel_list.dart';
import '../../models/form_config.dart';
import '../../services/storage_service.dart';
import '../../services/jalali_helper.dart';
import 'personnel_view.dart';
import 'form_settings_view.dart';
import 'pdf_preview_view.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ThemeMode currentThemeMode;

  const HomeScreen({
    super.key,
    required this.onThemeModeChanged,
    required this.currentThemeMode,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  List<PersonnelList> _personnelLists = [];
  String _activeListId = '';
  late FormConfig _formConfig;

  @override
  void initState() {
    super.initState();
    _formConfig = FormConfig(
      year: JalaliHelper.currentYear(),
      month: JalaliHelper.currentMonth(),
    );
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final loadedLists = await StorageService.loadAllPersonnelLists();
    final savedActiveId = await StorageService.loadActiveListId();
    final loadedConfig = await StorageService.loadFormConfig();

    String activeId = savedActiveId ?? '';
    if (activeId.isEmpty || !loadedLists.any((l) => l.id == activeId)) {
      activeId = loadedLists.isNotEmpty ? loadedLists.first.id : 'default';
    }

    setState(() {
      _personnelLists = loadedLists;
      _activeListId = activeId;
      _formConfig = loadedConfig;
      _isLoading = false;
    });
  }

  PersonnelList get _activeList {
    if (_personnelLists.isEmpty) {
      return const PersonnelList(id: 'default', name: 'لیست اصلی');
    }
    return _personnelLists.firstWhere(
      (l) => l.id == _activeListId,
      orElse: () => _personnelLists.first,
    );
  }

  List<Person> get _currentPersonnel => _activeList.members;

  void _onPersonnelListsChanged(List<PersonnelList> updatedLists) {
    setState(() {
      _personnelLists = updatedLists;
      if (!updatedLists.any((l) => l.id == _activeListId)) {
        _activeListId = updatedLists.isNotEmpty ? updatedLists.first.id : '';
      }
    });
    StorageService.saveAllPersonnelLists(updatedLists);
    StorageService.saveActiveListId(_activeListId);
  }

  void _onActiveListChanged(String newId) {
    setState(() {
      _activeListId = newId;
    });
    StorageService.saveActiveListId(newId);
  }

  void _onConfigChanged(FormConfig updated) {
    setState(() {
      _formConfig = updated;
    });
    StorageService.saveFormConfig(updated);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final monthName = JalaliHelper.getMonthName(_formConfig.month);

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final totalPersonnel = _currentPersonnel.length;
    final totalPages =
        (totalPersonnel == 0 ? 1 : (totalPersonnel / 3).ceil()) * 2;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/logo.png',
                  height: 38,
                  width: 38,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.table_chart_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'سازنده فرم ورود و خروج پرسنل',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    'تولید فرم‌های چاپی استاندارد نیمه‌ماه (هر صفحه ۳ نفر)',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            // Status Chip showing active list and total
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 16, color: Color(0xFF1E3A8A)),
                  const SizedBox(width: 6),
                  Text(
                    '$monthName ${_formConfig.year} • ${_activeList.name} ($totalPersonnel نفر - $totalPages صفحه)',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Theme toggle
            IconButton(
              icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
              tooltip: isDark ? 'حالت روشن' : 'حالت تیره',
              onPressed: () {
                widget.onThemeModeChanged(
                    isDark ? ThemeMode.light : ThemeMode.dark);
              },
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: Row(
          children: [
            // Side Navigation Rail (Material 3 Expressive)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() => _selectedIndex = index);
              },
              labelType: NavigationRailLabelType.all,
              leading: const SizedBox(height: 8),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.people_outline),
                  selectedIcon: Icon(Icons.people),
                  label: Text('اسامی پرسنل'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.calendar_month_outlined),
                  selectedIcon: Icon(Icons.calendar_month),
                  label: Text('تنظیمات تاریخ'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.picture_as_pdf_outlined),
                  selectedIcon: Icon(Icons.picture_as_pdf),
                  label: Text('پیش‌نمایش و چاپ'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),

            // Main Content Area
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  PersonnelView(
                    personnelLists: _personnelLists,
                    activeListId: _activeListId,
                    onPersonnelListsChanged: _onPersonnelListsChanged,
                    onActiveListChanged: _onActiveListChanged,
                  ),
                  FormSettingsView(
                    config: _formConfig,
                    personnel: _currentPersonnel,
                    onConfigChanged: _onConfigChanged,
                    onPreviewRequested: () {
                      setState(() => _selectedIndex = 2);
                    },
                  ),
                  PdfPreviewView(
                    personnel: _currentPersonnel,
                    config: _formConfig,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
