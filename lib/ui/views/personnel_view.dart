import 'package:flutter/material.dart';
import '../../models/person.dart';
import '../../models/personnel_list.dart';

class PersonnelView extends StatefulWidget {
  final List<PersonnelList> personnelLists;
  final String activeListId;
  final ValueChanged<List<PersonnelList>> onPersonnelListsChanged;
  final ValueChanged<String> onActiveListChanged;

  const PersonnelView({
    super.key,
    required this.personnelLists,
    required this.activeListId,
    required this.onPersonnelListsChanged,
    required this.onActiveListChanged,
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

  PersonnelList get _activeList {
    if (widget.personnelLists.isEmpty) {
      return const PersonnelList(id: 'default', name: 'لیست اصلی');
    }
    return widget.personnelLists.firstWhere(
      (l) => l.id == widget.activeListId,
      orElse: () => widget.personnelLists.first,
    );
  }

  List<Person> get _currentPersonnel => _activeList.members;

  void _updateActivePersonnel(List<Person> updatedMembers) {
    final updatedLists = widget.personnelLists.map((l) {
      if (l.id == _activeList.id) {
        return l.copyWith(members: updatedMembers);
      }
      return l;
    }).toList();
    widget.onPersonnelListsChanged(updatedLists);
  }

  void _addPerson() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final newPerson = Person(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      role: _roleController.text.trim().isEmpty
          ? null
          : _roleController.text.trim(),
    );

    final updated = List<Person>.from(_currentPersonnel)..add(newPerson);
    _updateActivePersonnel(updated);
    _nameController.clear();
    _roleController.clear();
  }

  void _removePerson(int index) {
    final updated = List<Person>.from(_currentPersonnel)..removeAt(index);
    _updateActivePersonnel(updated);
  }

  void _editPerson(int index) {
    final person = _currentPersonnel[index];
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
                final updatedList = List<Person>.from(_currentPersonnel);
                updatedList[index] = person.copyWith(
                  name: newName,
                  role: roleEditController.text.trim().isEmpty
                      ? null
                      : roleEditController.text.trim(),
                );
                _updateActivePersonnel(updatedList);
              }
              Navigator.pop(context);
            },
            child: const Text('ذخیره'),
          ),
        ],
      ),
    );
  }

  void _showCreateListDialog() {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ایجاد لیست پرسنل جدید'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'نام لیست جدید را وارد کنید (مثال: شیفت روز، پرسنل کارگاه ۲):',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'نام لیست',
                prefixIcon: Icon(Icons.format_list_bulleted_add),
                hintText: 'شیفت شب / واحد اداری',
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
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                final newList = PersonnelList(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: name,
                  members: [],
                );
                final updatedLists =
                    List<PersonnelList>.from(widget.personnelLists)
                      ..add(newList);
                widget.onPersonnelListsChanged(updatedLists);
                widget.onActiveListChanged(newList.id);
              }
              Navigator.pop(context);
            },
            child: const Text('ایجاد لیست'),
          ),
        ],
      ),
    );
  }

  void _showRenameListDialog() {
    final current = _activeList;
    final nameController = TextEditingController(text: current.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تغییر نام لیست پرسنل'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'نام جدید لیست',
            prefixIcon: Icon(Icons.edit),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('انصراف'),
          ),
          FilledButton(
            onPressed: () {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty) {
                final updatedLists = widget.personnelLists.map((l) {
                  if (l.id == current.id) {
                    return l.copyWith(name: newName);
                  }
                  return l;
                }).toList();
                widget.onPersonnelListsChanged(updatedLists);
              }
              Navigator.pop(context);
            },
            child: const Text('ذخیره تغییرات'),
          ),
        ],
      ),
    );
  }

  void _showDeleteListDialog() {
    if (widget.personnelLists.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حداقل یک لیست پرسنل باید در برنامه وجود داشته باشد.'),
        ),
      );
      return;
    }

    final current = _activeList;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف لیست پرسنل'),
        content: Text(
          'آیا از حذف کامل لیست «${current.name}» با ${current.members.length} نفر عضو اطمینان دارید؟ این عملیات قابل برگشت نیست.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('انصراف'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () {
              final updatedLists = List<PersonnelList>.from(widget.personnelLists)
                ..removeWhere((l) => l.id == current.id);
              final newActiveId = updatedLists.first.id;
              widget.onPersonnelListsChanged(updatedLists);
              widget.onActiveListChanged(newActiveId);
              Navigator.pop(context);
            },
            child: const Text('حذف کامل'),
          ),
        ],
      ),
    );
  }

  void _showDuplicateListDialog() {
    final current = _activeList;
    final nameController = TextEditingController(text: '${current.name} (کپی)');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ایجاد کپی از این لیست'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'نام لیست کپی',
            prefixIcon: Icon(Icons.copy),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('انصراف'),
          ),
          FilledButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                final copiedMembers = current.members
                    .map((p) => p.copyWith(
                        id: '${DateTime.now().millisecondsSinceEpoch}_${p.id}'))
                    .toList();
                final newList = PersonnelList(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: name,
                  members: copiedMembers,
                );
                final updatedLists =
                    List<PersonnelList>.from(widget.personnelLists)
                      ..add(newList);
                widget.onPersonnelListsChanged(updatedLists);
                widget.onActiveListChanged(newList.id);
              }
              Navigator.pop(context);
            },
            child: const Text('ایجاد کپی'),
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
                  hintText:
                      "محسن حسینی\nروح اله عزیزی\nسیاوش طاهری\nعلی کاظمی\n...",
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
                    id: '${DateTime.now().millisecondsSinceEpoch}_${newPersons.length}',
                    name: trimmed,
                  ));
                }
              }
              if (newPersons.isNotEmpty) {
                final updated = List<Person>.from(_currentPersonnel)
                  ..addAll(newPersons);
                _updateActivePersonnel(updated);
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _clearPersonnel() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('پاک کردن تمام اسامی'),
        content: Text(
          'آیا از حذف تمام اسامی در لیست «${_activeList.name}» اطمینان دارید؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('انصراف'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () {
              _updateActivePersonnel([]);
              Navigator.pop(context);
            },
            child: const Text('پاک کردن'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _searchQuery.isEmpty
        ? _currentPersonnel
        : _currentPersonnel
            .where((p) =>
                p.name.contains(_searchQuery) ||
                (p.role?.contains(_searchQuery) ?? false))
            .toList();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= MULTI-LIST SELECTOR & MANAGEMENT BAR =================
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.7),
              ),
            ),
            color: theme.colorScheme.surfaceContainerLow,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.folder_shared_outlined,
                      color: theme.colorScheme.onPrimaryContainer,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Dropdown to switch active list
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'لیست فعال پرسنل:',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _activeList.id,
                            isDense: true,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                            items: widget.personnelLists.map((list) {
                              return DropdownMenuItem<String>(
                                value: list.id,
                                child: Text(
                                  '${list.name} (${list.members.length} نفر)',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              );
                            }).toList(),
                            onChanged: (newId) {
                              if (newId != null) {
                                widget.onActiveListChanged(newId);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // List action buttons
                  FilledButton.icon(
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('لیست جدید'),
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _showCreateListDialog,
                  ),
                  const SizedBox(width: 8),

                  OutlinedButton.icon(
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('تغییر نام'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _showRenameListDialog,
                  ),
                  const SizedBox(width: 8),

                  OutlinedButton.icon(
                    icon: const Icon(Icons.copy_outlined, size: 16),
                    label: const Text('کپی'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _showDuplicateListDialog,
                  ),
                  const SizedBox(width: 8),

                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    tooltip: 'حذف این لیست',
                    onPressed: widget.personnelLists.length > 1
                        ? _showDeleteListDialog
                        : null,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header with count & bulk actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مدیریت افراد «${_activeList.name}»',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'مجموع افراد: ${_currentPersonnel.length} نفر (هر صفحه ۳ نفر در فرم قرار می‌گیرند)',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.playlist_add),
                    label: const Text('افزودن دسته‌جمعی'),
                    onPressed: _showBulkAddDialog,
                  ),
                  const SizedBox(width: 8),
                  if (_currentPersonnel.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.delete_sweep_outlined,
                          color: Colors.redAccent),
                      tooltip: 'پاک کردن تمام افراد این لیست',
                      onPressed: _clearPersonnel,
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Add person card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'نام و نام خانوادگی',
                        hintText: 'مثال: علی احمدی',
                        prefixIcon: Icon(Icons.person_add_outlined),
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
                        labelText: 'سمت یا واحد (اختیاری)',
                        hintText: 'مثال: انبار / شیفت الف',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      onSubmitted: (_) => _addPerson(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _addPerson,
                    icon: const Icon(Icons.add),
                    label: const Text('افزودن شخص'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Search bar
          if (_currentPersonnel.length > 4)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'جستجو در اسامی این لیست...',
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
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
              ),
            ),

          // Personnel List Table / Reorderable List
          Expanded(
            child: _currentPersonnel.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'هنوز شخصی به لیست «${_activeList.name}» اضافه نشده است',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'از کادر بالا یا دکمه «افزودن دسته‌جمعی» برای وارد کردن اسامی استفاده کنید.',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: theme.colorScheme.outlineVariant
                            .withValues(alpha: 0.5),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: ReorderableListView.builder(
                        buildDefaultDragHandles: _searchQuery.isEmpty,
                        itemCount: filtered.length,
                        // ignore: deprecated_member_use
                        onReorder: (oldIndex, newIndex) {
                          if (_searchQuery.isNotEmpty) return;
                          if (oldIndex < newIndex) {
                            newIndex -= 1;
                          }
                          final updated =
                              List<Person>.from(_currentPersonnel);
                          final item = updated.removeAt(oldIndex);
                          updated.insert(newIndex, item);
                          _updateActivePersonnel(updated);
                        },
                        itemBuilder: (context, index) {
                          final person = filtered[index];
                          final originalIndex = _currentPersonnel.indexOf(person);
                          final groupIndex = (originalIndex / 3).floor() + 1;
                          final slotInGroup = (originalIndex % 3) + 1;

                          return ListTile(
                            key: ValueKey(person.id),
                            leading: CircleAvatar(
                              backgroundColor: theme.colorScheme.primaryContainer,
                              foregroundColor:
                                  theme.colorScheme.onPrimaryContainer,
                              child: Text(
                                '${originalIndex + 1}',
                                style:
                                    const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(
                              person.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              person.role != null && person.role!.isNotEmpty
                                  ? person.role!
                                  : 'صفحه $groupIndex • ردیف $slotInGroup',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Group badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.secondaryContainer
                                        .withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'صفحه $groupIndex (ردیف $slotInGroup)',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: theme.colorScheme.onSecondaryContainer,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 20),
                                  tooltip: 'ویرایش',
                                  onPressed: () => _editPerson(originalIndex),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      size: 20, color: Colors.redAccent),
                                  tooltip: 'حذف',
                                  onPressed: () => _removePerson(originalIndex),
                                ),
                                if (_searchQuery.isEmpty)
                                  const Icon(Icons.drag_handle,
                                      color: Colors.grey),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
