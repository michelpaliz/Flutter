import 'package:flutter/material.dart';
import 'package:hexora/l10n/app_localizations.dart';
import '../widgets/nav_tile.dart';
import '../widgets/switch_tile.dart';

class PreferencesSection extends StatelessWidget {
  final bool isDark;
  final VoidCallback onToggleDark;
  final String languageName;
  final VoidCallback onChangeLanguage;

  const PreferencesSection({
    super.key,
    required this.isDark,
    required this.onToggleDark,
    required this.languageName,
    required this.onChangeLanguage,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Column(
      children: [
        SwitchTile(
          leading: const Icon(Icons.dark_mode_outlined),
          title: l.darkMode,
          value: isDark,
          onChanged: (_) => onToggleDark(),
        ),
        const Divider(height: 0),
        NavTile(
          leading: const Icon(Icons.language_rounded),
          title: l.language,
          subtitle: languageName,
          onTap: onChangeLanguage,
        ),
      ],
    );
  }
}
