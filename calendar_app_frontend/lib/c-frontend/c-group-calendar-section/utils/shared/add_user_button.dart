import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hexora/b-backend/group_mng_flow/group/view_model/group_view_model.dart';
import 'package:hexora/f-themes/themes/theme_colors.dart';
import 'package:hexora/f-themes/utilities/view-item-styles/button/button_styles.dart';
import 'package:hexora/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../../../a-models/group_model/group/group.dart';
import '../../../../a-models/user_model/user.dart';

class AddUserButtonDialog extends StatelessWidget {
  final User? currentUser;
  final Group? group;
  final GroupViewModel controller;
  final void Function(User)? onUserAdded;

  const AddUserButtonDialog({
    Key? key,
    required this.currentUser,
    required this.group,
    required this.controller,
    this.onUserAdded,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bg = ThemeColors.getButtonBackgroundColor(context);
    final fg = ThemeColors.getContrastTextColorForBackground(bg);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ButtonStyles.buttonWithIcon(
          iconData: Icons.person_add_alt_1,
          label: AppLocalizations.of(context)!.addUser,
          style: ButtonStyles.saucyButtonStyle(
            defaultBackgroundColor: bg,
            pressedBackgroundColor:
                ThemeColors.getContainerBackgroundColor(context),
            textColor: fg,
            borderColor: fg,
          ),
          onPressed: () => _openSheet(context),
        ),
      ],
    );
  }

  void _openSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ChangeNotifierProvider.value(
        value: controller,
        child: _AddPeopleSheet(
          currentUser: currentUser,
          group: group,
          onConfirm: (users) {
            for (final u in users) {
              controller.addMember(u); // must call notifyListeners()
              onUserAdded?.call(u);
            }
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}

class _AddPeopleSheet extends StatefulWidget {
  final User? currentUser;
  final Group? group;
  final void Function(List<User>) onConfirm;
  const _AddPeopleSheet({
    required this.currentUser,
    required this.group,
    required this.onConfirm,
  });

  @override
  State<_AddPeopleSheet> createState() => _AddPeopleSheetState();
}

class _AddPeopleSheetState extends State<_AddPeopleSheet> {
  final TextEditingController _search = TextEditingController();
  final FocusNode _focus = FocusNode();
  Timer? _debounce;
  List<User> _results = [];
  final Set<User> _selected = {};
  bool _loading = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _search.addListener(_onChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onChanged() {
    final q = _search.text.trim();
    if (q == _query) return;
    _query = q;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), _searchUsers);
  }

  Future<void> _searchUsers() async {
    setState(() => _loading = true);
    try {
      // use your controller’s search; provide a method if you don’t have one
      final ctrl = context.read<GroupViewModel>();
      final users = await ctrl.searchUsers(_query); // implement in controller
      setState(() => _results = users);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return DraggableScrollableSheet(
      expand: false,
      minChildSize: 0.45,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      builder: (context, scrollCtrl) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            top: 8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // grab handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                loc.addPplGroup,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),

              // search field (sticky)
              TextField(
                controller: _search,
                focusNode: _focus,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: loc.typeNameOrEmail, // add in l10n if missing
                  prefixIcon: const Icon(Icons.search),
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSubmitted: (_) => _searchUsers(),
              ),
              const SizedBox(height: 8),

              // selected chips
              if (_selected.isNotEmpty)
                _SelectedChips(
                  users: _selected.toList(),
                  onRemove: (u) => setState(() => _selected.remove(u)),
                ),

              // results
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _results.isEmpty
                        ? _EmptyState(
                            query: _query,
                            onInvite: () {
                              // optional: surface invite-by-email flow
                              // context.read<GroupController>().inviteByEmail(_query);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(loc.noMatchesInvite)),
                              );
                            },
                          )
                        : ListView.builder(
                            controller: scrollCtrl,
                            itemCount: _results.length,
                            itemBuilder: (_, i) {
                              final u = _results[i];
                              final selected = _selected.contains(u);
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage:
                                      (u.photoUrl?.isNotEmpty ?? false)
                                          ? NetworkImage(u.photoUrl!)
                                          : null,
                                  child: (u.photoUrl?.isEmpty ?? true)
                                      ? Text(u.name.isNotEmpty
                                          ? u.name[0].toUpperCase()
                                          : '?')
                                      : null,
                                ),
                                title: Text(u.name),
                                subtitle: Text(u.userName),
                                trailing: selected
                                    ? const Icon(Icons.check_circle,
                                        color: Colors.green)
                                    : IconButton(
                                        icon: const Icon(Icons.add),
                                        onPressed: () =>
                                            setState(() => _selected.add(u)),
                                      ),
                                onTap: () {
                                  setState(() {
                                    selected
                                        ? _selected.remove(u)
                                        : _selected.add(u);
                                  });
                                },
                              );
                            },
                          ),
              ),

              const SizedBox(height: 8),

              // primary action
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _selected.isEmpty
                      ? null
                      : () => widget.onConfirm(_selected.toList()),
                  child: Text(_selected.isEmpty
                      ? loc.addPeople
                      : '${loc.add} (${_selected.length})'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SelectedChips extends StatelessWidget {
  final List<User> users;
  final void Function(User) onRemove;
  const _SelectedChips({required this.users, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(vertical: 6),
        itemCount: users.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final u = users[i];
          return InputChip(
            avatar: CircleAvatar(
              backgroundImage: (u.photoUrl?.isNotEmpty ?? false)
                  ? NetworkImage(u.photoUrl!)
                  : null,
              child: (u.photoUrl?.isEmpty ?? true)
                  ? Text(u.name.isNotEmpty ? u.name[0].toUpperCase() : '?')
                  : null,
            ),
            label: Text(u.name),
            onDeleted: () => onRemove(u),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String query;
  final VoidCallback onInvite;
  const _EmptyState({required this.query, required this.onInvite});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off, size: 40),
          const SizedBox(height: 8),
          Text(loc.noMatchesForX(query)),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.mail_outline),
            label: Text(loc.inviteByEmail),
            onPressed: onInvite,
          ),
        ],
      ),
    );
  }
}
