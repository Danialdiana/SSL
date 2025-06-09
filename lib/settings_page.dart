//settings_page.dart
import 'package:flutter/material.dart'; // обязательно!
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'settings_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsController>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'settings'.tr(),
          style: TextStyle(color: Theme.of(context).appBarTheme.titleTextStyle?.color ?? Colors.white),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Язык
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr('language'),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<Locale>(
                    isExpanded: true,
                    value: context.locale,
                    items: const [
                      DropdownMenuItem(value: Locale('en'), child: Text('English')),
                      DropdownMenuItem(value: Locale('ru'), child: Text('Русский')),
                      DropdownMenuItem(value: Locale('kk'), child: Text('Қазақша')),
                    ],
                    onChanged: (Locale? newLocale) {
                      if (newLocale != null) context.setLocale(newLocale);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Тема
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr('theme'),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<ThemeMode>(
                    isExpanded: true,
                    value: settings.themeMode,
                    onChanged: (ThemeMode? mode) {
                      if (mode != null) settings.setThemeMode(mode);
                    },
                    items: [
                      DropdownMenuItem(value: ThemeMode.light, child: Text(tr('light'))),
                      DropdownMenuItem(value: ThemeMode.dark, child: Text(tr('dark'))),
                      DropdownMenuItem(value: ThemeMode.system, child: Text(tr('system'))),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Размер шрифта
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${tr('font_size')}: ${settings.fontScale.toStringAsFixed(1)}x',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Slider(
                    value: settings.fontScale,
                    min: 0.8,
                    max: 1.5,
                    divisions: 7,
                    label: '${settings.fontScale.toStringAsFixed(1)}x',
                    onChanged: settings.setFontScale,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
