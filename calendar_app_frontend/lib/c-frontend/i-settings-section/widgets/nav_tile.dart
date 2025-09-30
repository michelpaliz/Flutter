import 'package:flutter/material.dart';

class NavTile extends StatelessWidget {
  final Widget leading;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool danger;

  const NavTile({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      leading: leading,
      title: Text(
        title,
        style: tt.titleMedium?.copyWith(
          color: danger ? cs.error : cs.onSurface,
          fontWeight: danger ? FontWeight.w700 : null,
        ),
      ),
      subtitle: (subtitle == null || subtitle!.isEmpty)
          ? null
          : Text(subtitle!, style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
      visualDensity: const VisualDensity(vertical: -1),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    );
  }
}
