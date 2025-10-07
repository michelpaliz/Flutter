// lib/c-frontend/shared/widgets/category_picker.dart
import 'package:hexora/a-models/group_model/category/event_category.dart';
import 'package:hexora/b-backend/core/category/category_api_client.dart';
import 'package:flutter/material.dart';

class CategoryPicker extends StatefulWidget {
  final CategoryApi api;
  final String? initialCategoryId;
  final String? initialSubcategoryId;
  final ValueChanged<({String? categoryId, String? subcategoryId})> onChanged;
  final String? label;

  const CategoryPicker({
    super.key,
    required this.api,
    required this.onChanged,
    this.initialCategoryId,
    this.initialSubcategoryId,
    this.label,
  });

  @override
  State<CategoryPicker> createState() => _CategoryPickerState();
}

class _CategoryPickerState extends State<CategoryPicker> {
  bool _loading = true;
  String? _error;

  List<EventCategory> _all = [];
  String? _catId;
  String? _subId;

  @override
  void initState() {
    super.initState();
    _catId = widget.initialCategoryId;
    _subId = widget.initialSubcategoryId;
    _load();
  }

  Future<void> _load() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });
      final cats = await widget.api.list();
      setState(() {
        _all = cats;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  List<EventCategory> get _parents =>
      _all.where((c) => c.parentId == null).toList()
        ..sort((a, b) => a.name.compareTo(b.name));

  List<EventCategory> _childrenOf(String parentId) =>
      _all.where((c) => c.parentId == parentId).toList()
        ..sort((a, b) => a.name.compareTo(b.name));

  Future<void> _createCategory({String? parentId}) async {
    final controller = TextEditingController();
    final res = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(parentId == null ? 'New Category' : 'New Subcategory'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, null),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: const Text('Add')),
        ],
      ),
    );
    if (res == null || res.isEmpty) return;

    try {
      final created = await widget.api.create(EventCategory(
        id: 'tmp', // ignored server-side
        name: res,
        parentId: parentId,
      ));
      setState(() {
        _all = [..._all, created];
        if (parentId == null) {
          _catId = created.id;
          _subId = null;
        } else {
          _catId = parentId;
          _subId = created.id;
        }
      });
      widget.onChanged((categoryId: _catId, subcategoryId: _subId));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: LinearProgressIndicator(),
      );
    }

    if (_error != null) {
      return Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(child: Text(_error!, maxLines: 2)),
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      );
    }

    // Empty state (no categories yet)
    if (_all.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(widget.label!,
                  style: Theme.of(context).textTheme.titleSmall),
            ),
          Row(
            children: [
              Expanded(
                child: Text(
                  'No categories yet',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              IconButton(
                tooltip: 'Add category',
                onPressed: () => _createCategory(),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ],
      );
    }

    final parents = _parents;

    // Ensure dropdown values are valid without mutating state in build
    final String? selectedCatId =
        parents.any((p) => p.id == _catId) ? _catId : null;

    final children =
        selectedCatId == null ? <EventCategory>[] : _childrenOf(selectedCatId);

    final String? selectedSubId =
        children.any((c) => c.id == _subId) ? _subId : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(widget.label!,
                style: Theme.of(context).textTheme.titleSmall),
          ),

        // Parent category
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: selectedCatId,
                decoration: const InputDecoration(labelText: 'Category'),
                items: parents
                    .map((c) =>
                        DropdownMenuItem(value: c.id, child: Text(c.name)))
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    _catId = v;
                    _subId = null; // reset subs when parent changes
                  });
                  widget.onChanged((categoryId: _catId, subcategoryId: _subId));
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Add category',
              onPressed: () => _createCategory(),
              icon: const Icon(Icons.add),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Subcategory
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: selectedSubId,
                decoration: const InputDecoration(labelText: 'Subcategory'),
                items: children
                    .map((c) =>
                        DropdownMenuItem(value: c.id, child: Text(c.name)))
                    .toList(),
                onChanged: selectedCatId == null
                    ? null
                    : (v) {
                        setState(() => _subId = v);
                        widget.onChanged(
                            (categoryId: _catId, subcategoryId: _subId));
                      },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Add subcategory',
              onPressed: selectedCatId == null
                  ? null
                  : () => _createCategory(parentId: selectedCatId),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }
}
