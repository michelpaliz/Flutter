import 'package:flutter/material.dart';
import 'package:hexora/d-local-stateManagement/local/LocaleProvider.dart';
import 'package:provider/provider.dart';

void showLanguageSheet(BuildContext context) {
  final localeProv = Provider.of<LocaleProvider>(context, listen: false);

  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    builder: (_) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('English'),
            trailing: localeProv.locale.languageCode == 'en'
                ? const Icon(Icons.check_rounded)
                : null,
            onTap: () {
              localeProv.setLocale(const Locale('en'));
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Español'),
            trailing: localeProv.locale.languageCode == 'es'
                ? const Icon(Icons.check_rounded)
                : null,
            onTap: () {
              localeProv.setLocale(const Locale('es'));
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}
