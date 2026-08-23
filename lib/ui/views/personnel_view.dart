import 'package:flutter/material.dart';
import '../../models/person.dart';
import '../../services/storage_service.dart';

class PersonnelView extends StatefulWidget {
  final List<Person> personnel;
  final ValueChanged<List<Person>> onPersonnelChanged;

  const PersonnelView({
    super.key,
    required this.personnel,
    required this.onPersonnelChanged,
  });

  @override
  State<PersonnelView> createState() => _PersonnelViewState();
}

class _PersonnelViewState extends State<PersonnelView> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _addPerson() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final newPerson = Person(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      role: _roleController.text.trim().isEmpty ? null : _roleController.text.trim(),
    );

    final updated = List<Person>.from(widget.personnel)..add(newPerson);
    widget.onPersonnelChanged(updated);
    _nameController.clear();
    _roleController.clear();
  }

  void _removePerson(int index) {
    final updated = List<Person>.from(widget.personnel)..removeAt(index);
    widget.onPersonnelChanged(updated);
  }

  void _editPerson(int index) {
    final person = widget.personnel[index];
    final nameEditController = TextEditingController(text: person.name);
    final roleEditController = TextEditingController(text: person.role ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ویرایش اطلاعات پرسنل'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameEditController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'نام و نام خانوادگی',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: roleEditController,
              decoration: const InputDecoration(
                labelText: 'سمت یا عنوان شغلی (اختیاری)',
                prefixIcon: Icon(Icons.work_outline),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('انصراف'),
          ),
          FilledButton(
            onPressed: () {
              final newName = nameEditController.text.trim();
              if (newName.isNotEmpty) {
                final updatedList = List<Person>.from(widget.personnel);
                updatedList[index] = person.copyWith(
                  name: newName,
                  role: roleEditController.text.trim().isEmpty ? null : roleEditController.text.trim(),
                );
                widget.onPersonnelChanged(updatedList);
              }
              Navigator.pop(context);
            },
            child: const Text('ذخیره'),
          ),
        ],
      ),
    );
  }

  void _showBulkAddDialog() {
    final bulkController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('افزودن دسته‌جمعی اسامی پرسنل'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'اسامی پرسنل را در کادر زیر وارد کنید (هر خط یک نام):',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bulkController,
                maxLines: 10,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: "محسن حسینی\nروح اله عزیزی\nسیاوش طاهری\nعلی کاظمی\n...",
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('انصراف'),
          ),
          FilledButton.icon(
            icon: const Icon(Icons.playlist_add),
            label: const Text('افزودن به لیست'),
            onPressed: () {
              final text = bulkController.text;
              final lines = text.split(RegExp(r'[\r\n]+'));
              final newPersons = <Person>[];
              for (final line in lines) {
                final trimmed = line.trim();
                if (trimmed.isNotEmpty) {
                  newPersons.add(Person(
                    id: DateTime.now().microsecondsSinceEpoch.toString() + trimmed,
                    name: trimmed,
                  ));
                }
              }
              if (newPersons.isNotEmpty) {
                final updated = List<Person>.from(widget.personnel)..addAll(newPersons);
                widget.onPersonnelChanged(updated);
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showClearConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('پاک کردن کل لیست'),
        content: const Text('آیا از حذف تمام اسامی پرسنل مطمئن هستید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('انصراف'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () {
              widget.onPersonnelChanged([]);
              Navigator.pop(context);
            },
            child: const Text('حذف همه'),
          ),
        ],
      ),
    );
  }

  void _loadSampleData() {
    final sample = StorageService.getSamplePersonnel();
    widget.onPersonnelChanged(sample);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredIndices = <int>[];
    for (int i = 0; i < widget.personnel.length; i++) {
      if (_searchQuery.isEmpty ||
          widget.personnel[i].name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (widget.personnel[i].role?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)) {
        filteredIndices.add(i);
      }
    }

    final totalCount = widget.personnel.length;
    final totalGroups = (totalCount / 3).ceil();
    final totalPages = totalGroups * 2;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header stats banner
            Card(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.people_alt, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'مدیریت اسامی پرسنل',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'هر صفحه PDF شامل ۳ نفر است. نفرات به صورت خودکار در گروه‌های ۳ نفره و صفحات نیمه‌ماه صفحه‌بندی می‌شوند.',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Chip(
                      avatar: const Icon(Icons.numbers, size: 18),
                      label: Text('تعداد کل: $totalCount نفر'),
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      avatar: const Icon(Icons.description, size: 18),
                      label: Text('صفحات خروجی: $totalPages صفحه'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Input Bar for Single Add
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: 'نام و نام خانوادگی پرسنل...',
                          prefixIcon: Icon(Icons.person_add_alt_1),
                        ),
                        onSubmitted: (_) => _addPerson(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _roleController,
                        decoration: const InputDecoration(
                          hintText: 'سمت شغلی (اختیاری)',
                          prefixIcon: Icon(Icons.work_outline),
                        ),
                        onSubmitted: (_) => _addPerson(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: _addPerson,
                      icon: const Icon(Icons.add),
                      label: const Text('افزودن فرد'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: _showBulkAddDialog,
                      icon: const Icon(Icons.playlist_add),
                      label: const Text('افزودن دسته‌جمعی'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Toolbar & Search
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'جستجو در اسامی یا سمت‌ها...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      isDense: true,
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _loadSampleData,
                  icon: const Icon(Icons.auto_fix_high),
                  label: const Text('بارگذاری نمونه'),
                ),
                const SizedBox(width: 8),
                if (widget.personnel.isNotEmpty)
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
                    onPressed: _showClearConfirmDialog,
                    icon: const Icon(Icons.delete_sweep),
                    label: const Text('حذف همه'),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Personnel List with Group Dividers and Drag-Drop
            Expanded(
              child: widget.personnel.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.group_outlined,
                            size: 64,
                            color: theme.colorScheme.outline.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'هنوز هیچ پرسنلی اضافه نشده است',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'می‌توانید با دکمه "بارگذاری نمونه" لیست پیش‌فرض را لود کنید یا به صورت تکی/دسته‌جمعی نام‌ها را اضافه کنید.',
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                          const SizedBox(height: 16),
                          FilledButton.tonalIcon(
                            onPressed: _loadSampleData,
                            icon: const Icon(Icons.auto_fix_high),
                            label: const Text('بارگذاری پرسنل نمونه'),
                          ),
                        ],
                      ),
                    )
                  : ReorderableListView.builder(
                      itemCount: widget.personnel.length,
                      onReorderItem: (oldIndex, newIndex) {
                        final updated = List<Person>.from(widget.personnel);
                        final item = updated.removeAt(oldIndex);
                        updated.insert(newIndex, item);
                        widget.onPersonnelChanged(updated);
                      },
                      itemBuilder: (context, index) {
                        final person = widget.personnel[index];
                        final groupNum = (index ~/ 3) + 1;
                        final posInGroup = (index % 3) + 1;
                        final pageRangeStr = 'صفحه ${(groupNum - 1) * 2 + 1} و ${(groupNum - 1) * 2 + 2}';

                        // If search query is active and doesn't match, show subtle or filter
                        final matchesSearch = _searchQuery.isEmpty ||
                            person.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            (person.role?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

                        if (!matchesSearch) {
                          return const SizedBox.shrink(key: ValueKey('empty'));
                        }

                        return Card(
                          key: ValueKey(person.id),
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: theme.colorScheme.primaryContainer,
                              foregroundColor: theme.colorScheme.primary,
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Row(
                              children: [
                                Text(
                                  person.name,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                ),
                                if (person.role != null && person.role!.isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      person.role!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            subtitle: Text(
                              'گروه $groupNum ($pageRangeStr) • ردیف $posInGroup در جدول',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.primary.withValues(alpha: 0.85),
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 20),
                                  tooltip: 'ویرایش',
                                  onPressed: () => _editPerson(index),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete_outline, size: 20, color: Colors.red.shade600),
                                  tooltip: 'حذف',
                                  onPressed: () => _removePerson(index),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.drag_indicator, color: Colors.grey),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
