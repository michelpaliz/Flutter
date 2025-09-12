import 'package:calendar_app_frontend/a-models/group_model/client/client.dart';
import 'package:calendar_app_frontend/b-backend/api/client/client_api.dart';
import 'package:flutter/material.dart';

class AddClientSheet extends StatefulWidget {
  final String groupId; // used on create
  final ClientsApi api;
  final Client? client; // null = create, non-null = edit

  const AddClientSheet({
    super.key,
    required this.groupId,
    required this.api,
    this.client,
  });

  @override
  State<AddClientSheet> createState() => _AddClientSheetState();
}

class _AddClientSheetState extends State<AddClientSheet> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  bool _active = true;
  bool _saving = false;

  bool get _isEdit => widget.client != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final c = widget.client!;
      _name.text = c.name;
      _phone.text = c.phone ?? '';
      _email.text = c.email ?? '';
      _active = c.isActive;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      if (_isEdit) {
        // ---- EDIT (PATCH) ----
        final patch = <String, dynamic>{
          'name': _name.text.trim(),
          'isActive': _active,
          'contact': {
            'phone': _phone.text.trim().isEmpty ? null : _phone.text.trim(),
            'email': _email.text.trim().isEmpty ? null : _email.text.trim(),
          },
        };
        final updated = await widget.api.updateFields(widget.client!.id, patch);
        if (!mounted) return;
        Navigator.of(context).pop<Client>(updated);
      } else {
        // ---- CREATE ----
        final created = await widget.api.create(
          Client(
            id: '',
            name: _name.text.trim(),
            groupId: widget.groupId,
            phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
            email: _email.text.trim().isEmpty ? null : _email.text.trim(),
            isActive: _active,
            createdAt: DateTime.now(),
          ),
        );
        if (!mounted) return;
        Navigator.of(context).pop<Client>(created);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).viewInsets.bottom + 16;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, pad),
      child: Form(
        key: _formKey,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(_isEdit ? 'Edit Client' : 'Create Client',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          TextFormField(
            controller: _name,
            decoration: const InputDecoration(
              labelText: 'Name *',
              prefixIcon: Icon(Icons.person_outline),
            ),
            textInputAction: TextInputAction.next,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Name is required' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.alternate_email),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return null;
              final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v);
              return ok ? null : 'Invalid email';
            },
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Active'),
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
                  ? 'Saving...'
                  : (_isEdit ? 'Save Changes' : 'Save Client')),
              onPressed: _saving ? null : _save,
            ),
          ),
        ]),
      ),
    );
  }
}
