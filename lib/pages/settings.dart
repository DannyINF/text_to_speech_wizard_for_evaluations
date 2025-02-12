import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:simple_icons/simple_icons.dart';

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
                enabled: false,
              ),
            ],
          ),
          SettingsSection(
            title: const Text("AI Voice"),
            tiles: <SettingsTile>[
              /*

              {google, amazon, microsoft}

               */
              SettingsTile.navigation(
                leading: const Icon(Symbols.host),
                title: const Text('Provider'),
                value: const Text('Google'),
                enabled: false,
              ),
              /*

              {standard, wavenet, neural2, polyglot, chirp, news, studio, casual}

               */
              SettingsTile.navigation(
                leading: const Icon(Symbols.network_node),
                title: const Text('Model'),
                value: const Text('Wavenet'),
                onPressed: (value) {
                  showAdaptiveDialog(context: context, builder: (context) {
                    var models = {"Standard", "Wavenet", "Neural2", "Polyglot", "Chirp", "News", "Studio", "Casual"};
                    return SimpleDialog(
                      title: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Symbols.network_node),
                          SizedBox(width: 10,),
                          Text("Model"),
                        ],
                      ),
                      children: [
                        for (var model in models)
                          ListTile(
                            leading: model == "Wavenet" ? const Icon(Symbols.check) : const SizedBox(width: 20,),
                            title: Text(model),
                            onTap: () {print(model);},
                            selected: model == "Wavenet",
                          ),
                      ],
                    );
                  });
                },
              ),
              /*

              {Female, Male}

               */
              SettingsTile.navigation(
                leading: const Icon(Symbols.record_voice_over),
                title: const Text('Gender'),
                value: const Text('Female'),
                onPressed: (value) {
                  showAdaptiveDialog(context: context, builder: (context) {
                    var genders = {"Female", "Male"};
                    return SimpleDialog(
                      title: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Symbols.record_voice_over),
                          SizedBox(width: 10,),
                          Text("Gender"),
                        ],
                      ),
                      children: [
                        for (var gender in genders)
                          ListTile(
                            leading: gender == "Female" ? const Icon(Symbols.check) : const SizedBox(width: 20,),
                            title: Text(gender),
                            onTap: () {print(gender);},
                            selected: gender == "Female",
                          ),
                      ],
                    );
                  });
                },
              ),
              /*

              {Abigail, Jacob, Jackson, Ella, Sofia, Benjamin, Michael, Sebastian, Henry, Isabella, Gianna, Avery, Evelyn, Noah, Emma, Sophia, Harper,
              James, Amelia, Mia, Ava, Liam, Mason, Olivia, Camila, Levi, William, Ethan, Emily, Charlotte, Luna, Elijah, Alexander, Oliver, Lucas,
              Logan, Mateo, Elizabeth, Mila, Daniel}

               */
              SettingsTile.navigation(
                leading: const Icon(Symbols.voice_selection),
                title: const Text('Voice'),
                value: const Text('Abigail'),
                onPressed: (value) {
                  showAdaptiveDialog(context: context, builder: (context) {
                    var voices =  {"Abigail", "Jacob", "Jackson", "Ella", "Sofia", "Benjamin", "Michael", "Sebastian", "Henry", "Isabella", "Gianna", "Avery", "Evelyn", "Noah", "Emma", "Sophia", "Harper",
                      "James", "Amelia", "Mia", "Ava", "Liam", "Mason", "Olivia", "Camila", "Levi", "William", "Ethan", "Emily", "Charlotte", "Luna", "Elijah", "Alexander", "Oliver", "Lucas",
                      "Logan", "Mateo", "Elizabeth", "Mila", "Daniel"};
                    return SimpleDialog(
                      title: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Symbols.voice_selection),
                          SizedBox(width: 10,),
                          Text("Voice"),
                        ],
                      ),
                      children: [
                        for (var voice in voices)
                          ListTile(
                            leading: voice == "Abigail" ? const Icon(Symbols.check) : const SizedBox(width: 20,),
                            title: Text(voice),
                            onTap: () {print(voice);},
                            selected: voice == "Abigail",
                          ),
                      ],
                    );
                  });
                },
              ),
              /*

              {af - Afrikaans, am - Amharic, ar - Arabic, bn - Bangla, eu - Basque, bg - Bulgarian, yue - Cantonese, ca - Catalan, zh - Chinese,
              cs - Czech, da - Danish, nl - Dutch, en - English, et - Estonian, fil - Filipino, fi - Finnish, fr - French, gl - Galician,
              de - German, el - Greek, gu - Gujarati, he - Hebrew, hi - Hindi, hu - Hungarian, is - Icelandic, id - Indonesian, it - Italian,
              ja - Japanese, kn - Kannada, ko - Korean, lv - Latvian, lt - Lithuanian, ms - Malay, ml - Malayalam, mr - Marathi, nb - Norwegian Bokmål,
              pl - Polish, pt - Portuguese, pa - Punjabi, ro - Romanian, ru - Russian, sr - Serbian, sk - Slovak, es - Spanish, sv - Swedish, ta - Tamil,
              te - Telugu, th - Thai, tr - Turkish, uk - Ukrainian, ur - Urdu, vi - Vietnamese}

               */
              SettingsTile.navigation(
                leading: const Icon(Symbols.text_to_speech),
                title: const Text('Language'),
                value: const Text('Deutsch'),
                onPressed: (value) {
                  showAdaptiveDialog(context: context, builder: (context) {
                    List<String> languageNames = [
                      "Afrikaans", "Amharic", "Arabic", "Bangla", "Basque", "Bulgarian", "Cantonese", "Catalan", "Chinese",
                      "Czech", "Danish", "Dutch", "English", "Estonian", "Filipino", "Finnish", "French", "Galician",
                      "German", "Greek", "Gujarati", "Hebrew", "Hindi", "Hungarian", "Icelandic", "Indonesian", "Italian",
                      "Japanese", "Kannada", "Korean", "Latvian", "Lithuanian", "Malay", "Malayalam", "Marathi", "Norwegian Bokmål",
                      "Polish", "Portuguese", "Punjabi", "Romanian", "Russian", "Serbian", "Slovak", "Spanish", "Swedish", "Tamil",
                      "Telugu", "Thai", "Turkish", "Ukrainian", "Urdu", "Vietnamese"
                    ];

                    return SimpleDialog(
                      title: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Symbols.voice_selection),
                          SizedBox(width: 10,),
                          Text("Voice"),
                        ],
                      ),
                      children: [
                        for (var lang in languageNames)
                          ListTile(
                            leading: lang == "German"? const Icon(Symbols.check) : const SizedBox(width: 20,),
                            title: Text(lang),
                            onTap: () {print(lang);},
                            selected: lang == "German",
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
