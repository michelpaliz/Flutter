import 'package:flutter/material.dart';

class SwitchTile extends StatelessWidget {
  final Widget leading;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SwitchTile({
    super.key,
    required this.leading,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return ListTile(
      leading: leading,
      title: Text(title, style: tt.titleMedium),
      trailing: Switch(value: value, onChanged: onChanged),
      onTap: () => onChanged(!value),
      visualDensity: const VisualDensity(vertical: -1),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    );
  }
}
