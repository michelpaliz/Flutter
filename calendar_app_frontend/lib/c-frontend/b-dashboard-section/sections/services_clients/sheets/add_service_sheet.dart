import 'package:hexora/a-models/group_model/service/service.dart';
import 'package:hexora/b-backend/api/service/service_api.dart';
import 'package:hexora/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddServiceSheet extends StatefulWidget {
  final String groupId; // used on create
  final ServiceApi api;
  final Service? service; // null = create, non-null = edit

  const AddServiceSheet({
    super.key,
    required this.groupId,
    required this.api,
    this.service,
  });

  @override
  State<AddServiceSheet> createState() => _AddServiceSheetState();
}

class _AddServiceSheetState extends State<AddServiceSheet> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _minutes = TextEditingController();
  bool _active = true;
  bool _saving = false;

  static const _palette = <String>[
    '#3b82f6',
    '#10b981',
    '#f59e0b',
    '#ef4444',
    '#8b5cf6',
    '#06b6d4',
  ];
  late List<String>
      _swatches; // allows injecting current color if not in palette
  late String _color;

  bool get _isEdit => widget.service != null;

  @override
  void initState() {
    super.initState();
    _swatches = List<String>.from(_palette);
    if (_isEdit) {
      final s = widget.service!;
      _name.text = s.name;
      if (s.defaultMinutes != null) _minutes.text = s.defaultMinutes.toString();
      _active = s.isActive;
      _color = s.color ?? _swatches.first;
      if (!_swatches.contains(_color)) _swatches.insert(0, _color);
    } else {
      _color = _swatches.first;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _minutes.dispose();
    super.dispose();
  }

  Color _hexToColor(String hex) {
    final cleaned = hex.replaceAll('#', '');
    final value = int.parse('FF$cleaned', radix: 16);
    return Color(value);
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      if (_isEdit) {
        // ---- EDIT (PATCH) ----
        final minutes = _minutes.text.trim().isEmpty
            ? null
            : int.tryParse(_minutes.text.trim());

        final patch = <String, dynamic>{
          'name': _name.text.trim(),
          'defaultMinutes': minutes,
          'color': _color,
          'isActive': _active,
        };

        final updated =
            await widget.api.updateFields(widget.service!.id, patch);
        if (!mounted) return;
        Navigator.of(context).pop<Service>(updated);
      } else {
        // ---- CREATE ----
        final created = await widget.api.create(
          Service(
            id: '',
            name: _name.text.trim(),
            groupId: widget.groupId,
            defaultMinutes: _minutes.text.trim().isEmpty
                ? null
                : int.tryParse(_minutes.text.trim()),
            color: _color,
            isActive: _active,
            createdAt: DateTime.now(),
          ),
        );
        if (!mounted) return;
        Navigator.of(context).pop<Service>(created);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.failedWithReason(e.toString()))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final pad = MediaQuery.of(context).viewInsets.bottom + 16;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, pad),
      child: Form(
        key: _formKey,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(_isEdit ? l.editService : l.createService,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          TextFormField(
            controller: _name,
            decoration: InputDecoration(
              labelText: '${l.nameLabel} *',
              prefixIcon: const Icon(Icons.design_services_outlined),
            ),
            textInputAction: TextInputAction.next,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? l.nameIsRequired : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _minutes,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: l.defaultMinutesLabel,
              hintText: l.defaultMinutesHint,
              prefixIcon: const Icon(Icons.timer_outlined),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(l.colorLabel,
                style: Theme.of(context).textTheme.labelLarge),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _swatches.map((hex) {
              final selected = _color == hex;
              return GestureDetector(
                onTap: () => setState(() => _color = hex),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _hexToColor(hex),
                    shape: BoxShape.circle,
                    border: Border.all(
                      width: selected ? 3 : 1,
                      color: selected ? Colors.black54 : Colors.black12,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l.active),
            value: _active,
            onChanged: (v) => setState(() => _active = v),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.save_outlined),
              label: Text(_saving
                  ? l.saving
                  : (_isEdit ? l.saveChanges : l.saveService)),
              onPressed: _saving ? null : _save,
            ),
          ),
        ]),
      ),
    );
  }
}
