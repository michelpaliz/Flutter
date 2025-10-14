import 'package:hexora/a-models/group_model/service/service.dart';
import 'package:hexora/f-themes/app_colors/tools_colors/theme_colors.dart';
import 'package:hexora/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../widgets/common_views.dart';

class ServicesTab extends StatelessWidget {
  final List<Service> items;
  final bool loading;
  final String? error;
  final Future<void> Function() onRefresh;
  final bool showInlineCTA;
  final VoidCallback? onAddTap;
  final void Function(Service service)? onEdit; // optional

  const ServicesTab({
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
        icon: Icons.design_services_outlined,
        title: l.noServicesYet,
        subtitle: l.createServicesSubtitle,
        cta: showInlineCTA ? l.addService : null,
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
          final s = items[i];
          return Card(
            color: Theme.of(context).colorScheme.surface,
            child: ListTile(
              leading: _ServiceDot(colorHex: s.color),
              title: Text(s.name),
              subtitle: Text(
                s.defaultMinutes != null
                    ? '${s.defaultMinutes} ${l.minutesAbbrev}' // e.g. "45 min"
                    : l.noDefaultDuration,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _StatusChip(active: s.isActive), // ← same look as Clients
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right),
                ],
              ),
              onTap: onEdit == null ? null : () => onEdit!(s),
            ),
          );
        },
      ),
    );
  }
}

class _ServiceDot extends StatelessWidget {
  final String? colorHex;
  const _ServiceDot({this.colorHex});

  @override
  Widget build(BuildContext context) {
    final c = _hexToColorOrNull(colorHex) ??
        Theme.of(context).colorScheme.onSurface.withOpacity(0.2);
    return CircleAvatar(radius: 12, backgroundColor: c);
  }

  // Supports #rgb and #rrggbb
  Color? _hexToColorOrNull(String? hex) {
    if (hex == null || !hex.startsWith('#')) return null;
    var cleaned = hex.substring(1);
    if (cleaned.length == 3) {
      cleaned = cleaned.split('').map((ch) => '$ch$ch').join();
    }
    if (cleaned.length != 6) return null;
    final value = int.tryParse('FF$cleaned', radix: 16);
    return value == null ? null : Color(value);
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
