import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Settings"),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: const Text('Common'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: const Icon(Icons.language),
                title: const Text('Language'),
                value: const Text('English'),
              ),
            ],
          ),
          SettingsSection(
            title: const Text("AI Voice"),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: const Icon(Symbols.host),
                title: const Text('Provider'),
                value: const Text('Google'),
              ),
              SettingsTile.navigation(
                leading: const Icon(Symbols.network_node),
                title: const Text('Model'),
                value: const Text('Wavenet'),
              ),
              SettingsTile.navigation(
                leading: const Icon(Symbols.record_voice_over),
                title: const Text('Gender'),
                value: const Text('Female'),
              ),
              SettingsTile.navigation(
                leading: const Icon(Symbols.text_to_speech),
                title: const Text('Language'),
                value: const Text('Deutsch'),
              ),
            ],
          ),
          SettingsSection(
            title: const Text("Layout"),
            tiles: <SettingsTile>[
              SettingsTile.switchTile(
                onToggle: (value) {},
                initialValue: true,
                leading: const Icon(Symbols.send),
                title: const Text('Enable custom text input'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
