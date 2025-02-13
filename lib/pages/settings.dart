import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:simple_icons/simple_icons.dart';
import 'package:text_to_speech_wizard_for_evaluations/util/voice.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.voiceHandler});

  final VoiceHandler voiceHandler;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  //TODO: load from db
  String selectedModel = "wavenet";
  String selectedLanguage = "German";
  String selectedGender = "Female";
  String selectedVoice = "Ava";

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
                enabled: false,
              ),
            ],
          ),
          SettingsSection(
            title: const Text("AI Voice"),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: const Icon(Symbols.network_node),
                title: const Text('Model'),
                value: Text(selectedModel),
                onPressed: (value) {
                  showAdaptiveDialog(context: context, builder: (context) {
                    var models = (widget.voiceHandler.getModels());
                    return SimpleDialog(
                      title: const Row(
                        children: [
                          const Icon(Symbols.network_node),
                          const SizedBox(width: 7,),
                          const Text("Model"),
                        ],
                      ),
                      children: [
                        for (var model in models)
                          ListTile(
                            leading: model == selectedModel ? const Icon(Symbols.check) : const SizedBox(width: 20,),
                            title: Text(model),
                            onTap: () {
                              setState(() {
                                selectedModel = model;
                                if (!widget.voiceHandler.getLanguages(selectedModel).contains(selectedLanguage)) {
                                  selectedLanguage = widget.voiceHandler.getLanguages(selectedModel)[0];
                                }
                                if (!widget.voiceHandler.getGenders(selectedModel, selectedLanguage).contains(selectedGender)) {
                                  selectedGender = widget.voiceHandler.getGenders(selectedModel, selectedLanguage)[0];
                                }
                                if (!widget.voiceHandler.getNames(selectedModel, selectedLanguage, selectedGender).contains(selectedVoice)) {
                                  selectedVoice = widget.voiceHandler.getNames(selectedModel, selectedLanguage, selectedGender)[0];
                                }
                              });
                              // TODO: Implement DB call to save selected model
                              Navigator.of(context).pop();
                            },
                            selected: model == selectedModel,
                          ),
                      ],
                    );
                  });
                },
              ),
              SettingsTile.navigation(
                leading: const Icon(Symbols.text_to_speech),
                title: const Text('Language'),
                value: Text(selectedLanguage),
                onPressed: (value) {
                  showAdaptiveDialog(context: context, builder: (context) {
                    List<String> languages = (widget.voiceHandler.getLanguages(selectedModel.toLowerCase()));
                    return SimpleDialog(
                      title: const Row(
                        children: [
                          const Icon(Symbols.text_to_speech),
                          const SizedBox(width: 7,),
                          const Text("Language"),
                        ],
                      ),
                      children: [
                        for (var lang in languages)
                          ListTile(
                            leading: lang == selectedLanguage ? const Icon(Symbols.check) : const SizedBox(width: 20,),
                            title: Text(lang),
                            onTap: () {
                              setState(() {
                                selectedLanguage = lang;
                                if (!widget.voiceHandler.getGenders(selectedModel, selectedLanguage).contains(selectedGender)) {
                                  selectedGender = widget.voiceHandler.getGenders(selectedModel, selectedLanguage)[0];
                                }
                                if (!widget.voiceHandler.getNames(selectedModel, selectedLanguage, selectedGender).contains(selectedVoice)) {
                                  selectedVoice = widget.voiceHandler.getNames(selectedModel, selectedLanguage, selectedGender)[0];
                                }
                              });
                              // TODO: Implement DB call to save selected language
                              Navigator.of(context).pop();
                            },
                            selected: lang == selectedLanguage,
                          ),
                      ],
                    );
                  });
                },
              ),
              SettingsTile.navigation(
                leading: const Icon(Symbols.record_voice_over),
                title: const Text('Gender'),
                value: Text(selectedGender),
                onPressed: (value) {
                  showAdaptiveDialog(context: context, builder: (context) {
                    var genders = (widget.voiceHandler.getGenders(selectedModel.toLowerCase(), selectedLanguage));
                    return SimpleDialog(
                      title: const Row(
                        children: [
                          const Icon(Symbols.record_voice_over),
                          const SizedBox(width: 7,),
                          const Text("Gender"),
                        ],
                      ),
                      children: [
                        for (var gender in genders)
                          ListTile(
                            leading: gender == selectedGender ? const Icon(Symbols.check) : const SizedBox(width: 20,),
                            title: Text(gender),
                            onTap: () {
                              setState(() {
                                selectedGender = gender;
                                if (!widget.voiceHandler.getNames(selectedModel, selectedLanguage, selectedGender).contains(selectedVoice)) {
                                  selectedVoice = widget.voiceHandler.getNames(selectedModel, selectedLanguage, selectedGender)[0];
                                }
                              });
                              // TODO: Implement DB call to save selected gender
                              Navigator.of(context).pop();
                            },
                            selected: gender == selectedGender,
                          ),
                      ],
                    );
                  });
                },
              ),
              SettingsTile.navigation(
                leading: const Icon(Symbols.voice_selection),
                title: const Text('Voice'),
                value: Text(selectedVoice),
                onPressed: (value) {
                  showAdaptiveDialog(context: context, builder: (context) {
                    var voices = (widget.voiceHandler.getNames(selectedModel.toLowerCase(), selectedLanguage, selectedGender));
                    return SimpleDialog(
                      title: const Row(
                        children: [
                          const Icon(Symbols.voice_selection),
                          const SizedBox(width: 7,),
                          const Text("Voice"),
                        ],
                      ),
                      children: [
                        for (var voice in voices)
                          ListTile(
                            leading: voice == selectedVoice ? const Icon(Symbols.check) : const SizedBox(width: 20,),
                            title: Text(voice),
                            onTap: () {
                              setState(() {
                                selectedVoice = voice;
                              });
                              // TODO: Implement DB call to save selected voice
                              Navigator.of(context).pop();
                            },
                            selected: voice == selectedVoice,
                          ),
                      ],
                    );
                  });
                },
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
          SettingsSection(
            title: const Text("API Keys"),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: const Icon(SimpleIcons.googlecloud),
                title: const Text("Google Cloud TTS API"),
                value: const Text('************'),
                enabled: false,
              ),
              SettingsTile.navigation(
                leading: const Icon(SimpleIcons.microsoftazure),
                title: const Text("Microsoft Azure Cognitive TTS API"),
                value: const Text('not provided'),
                enabled: false,
              ),
              SettingsTile.navigation(
                leading: const Icon(SimpleIcons.amazonaws),
                title: const Text("Amazon Polly API"),
                value: const Text('not provided'),
                enabled: false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
