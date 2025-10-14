import 'package:flutter/material.dart';
import 'package:hexora/a-models/group_model/client/client.dart';
import 'package:hexora/f-themes/app_colors/tools_colors/theme_colors.dart';
import 'package:hexora/l10n/app_localizations.dart';

import '../widgets/common_views.dart';

class ClientsTab extends StatelessWidget {
  final List<Client> items;
  final bool loading;
  final String? error;
  final Future<void> Function() onRefresh;
  final bool showInlineCTA;
  final VoidCallback? onAddTap; // optional
  final void Function(Client client)? onEdit; // tap-to-edit

  const ClientsTab({
    super.key,
    required this.items,
    required this.loading,
    required this.error,
    required this.onRefresh,
    this.showInlineCTA = false,
    this.onAddTap,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    if (loading) return const Center(child: CircularProgressIndicator());
    if (error != null) return ErrorView(message: error!, onRetry: onRefresh);

    if (items.isEmpty) {
      return EmptyView(
        icon: Icons.person_outline,
        title: l.noClientsYet,
        subtitle: l.addYourFirstClient,
        cta: showInlineCTA ? l.addClient : null,
        onPressed: showInlineCTA ? onAddTap : null,
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final c = items[i];
          return Card(
            color: Theme.of(context).colorScheme.surface,
            child: ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(c.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if ((c.phone ?? '').isNotEmpty) Text(c.phone!),
                  if ((c.email ?? '').isNotEmpty) Text(c.email!),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _StatusChip(active: c.isActive),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right),
                ],
              ),
              onTap: onEdit == null ? null : () => onEdit!(c),
            ),
          );
        },
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool active;
  const _StatusChip({required this.active});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final Color bg = active ? const Color(0xFF16A34A) : const Color(0xFFDC2626);
    final Color fg = ThemeColors.getContrastTextColorForBackground(bg);
    final String label = active ? l.active : l.inactive;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
