import 'package:flutter/material.dart';
import 'package:calendar_app_frontend/a-models/group_model/service/service.dart';
import '../widgets/common_views.dart';

class ServicesTab extends StatelessWidget {
  final List<Service> items;
  final bool loading;
  final String? error;
  final Future<void> Function() onRefresh;
  final bool showInlineCTA;
  final VoidCallback? onAddTap;
  final void Function(Service service)? onEdit;   // 👈 NEW (optional)

  const ServicesTab({
    super.key,
    required this.items,
    required this.loading,
    required this.error,
    required this.onRefresh,
    this.showInlineCTA = false,
    this.onAddTap,
    this.onEdit,                                   // 👈 NEW
  });

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (error != null) return ErrorView(message: error!, onRetry: onRefresh);

    if (items.isEmpty) {
      return EmptyView(
        icon: Icons.design_services_outlined,
        title: 'No services yet',
        subtitle: 'Create services you can assign to bookings.',
        cta: showInlineCTA ? 'Add Service' : null,
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
                s.defaultMinutes != null ? '${s.defaultMinutes} min' : 'No default duration',
              ),
              trailing: Switch(
                value: s.isActive,
                onChanged: null, // wire to PATCH when ready
              ),
              onTap: onEdit == null ? null : () => onEdit!(s),   // 👈 NEW
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
    final c = _hexToColorOrNull(colorHex)
        ?? Theme.of(context).colorScheme.onSurface.withOpacity(0.2);
    return CircleAvatar(radius: 12, backgroundColor: c);
  }

  Color? _hexToColorOrNull(String? hex) {
    if (hex == null || !hex.startsWith('#')) return null;
    final cleaned = hex.replaceAll('#', '');
    final value = int.tryParse('FF$cleaned', radix: 16);
    if (value == null) return null;
    return Color(value);
  }
}
