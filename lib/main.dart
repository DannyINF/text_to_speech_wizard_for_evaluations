import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:text_to_speech_wizard_for_evaluations/db.dart';
import 'package:text_to_speech_wizard_for_evaluations/pages/settings.dart';
import 'package:text_to_speech_wizard_for_evaluations/util/voice.dart';
import 'package:text_to_speech_wizard_for_evaluations/views/grid_view.dart';
import 'package:text_to_speech_wizard_for_evaluations/views/remote_control_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final voiceHandler = VoiceHandler();
  await voiceHandler.init();

  final DatabaseHelper databaseHelper = DatabaseHelper();
  await _initializeSettings(databaseHelper);

  final settings = await databaseHelper.getSettings();

  runApp(MyApp(
    voiceHandler: voiceHandler,
    initialSelectedModel: settings?["model"]?.toString() ?? "wavenet",
    initialSelectedLanguage: settings?["language_code"]?.toString() ?? "German",
    initialSelectedGender: settings?["gender"]?.toString() ?? "Female",
    initialSelectedVoice: settings?["voice"]?.toString() ?? "Ava",
    initialCustomInput: settings?["custom_input"] == 1,
  ));
}

Future<void> _initializeSettings(DatabaseHelper dbHelper) async {
  if (!await dbHelper.doesSettingsExist()) {
    await dbHelper.insertSettings("wavenet", "German", "Female", "Ava", false);
  }
}

class MyApp extends StatelessWidget {
  final VoiceHandler voiceHandler;
  final String initialSelectedModel;
  final String initialSelectedLanguage;
  final String initialSelectedGender;
  final String initialSelectedVoice;
  final bool initialCustomInput;

  const MyApp({
    super.key,
    required this.voiceHandler,
    required this.initialSelectedModel,
    required this.initialSelectedLanguage,
    required this.initialSelectedGender,
    required this.initialSelectedVoice,
    required this.initialCustomInput,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Text-To-Speech | Wizard-Of-Oz for Evaluations',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: TextToSpeechScreen(
        voiceHandler: voiceHandler,
        initialSelectedModel: initialSelectedModel,
        initialSelectedLanguage: initialSelectedLanguage,
        initialSelectedGender: initialSelectedGender,
        initialSelectedVoice: initialSelectedVoice,
        initialCustomInput: initialCustomInput,
      ),
    );
  }
}

class TextToSpeechScreen extends StatefulWidget {
  final VoiceHandler voiceHandler;
  final String initialSelectedModel;
  final String initialSelectedLanguage;
  final String initialSelectedGender;
  final String initialSelectedVoice;
  final bool initialCustomInput;

  const TextToSpeechScreen({
    super.key,
    required this.voiceHandler,
    required this.initialSelectedModel,
    required this.initialSelectedLanguage,
    required this.initialSelectedGender,
    required this.initialSelectedVoice,
    required this.initialCustomInput,
  });

  @override
  _TextToSpeechScreenState createState() => _TextToSpeechScreenState();
}

class _TextToSpeechScreenState extends State<TextToSpeechScreen> {
  final TextEditingController _controller = TextEditingController();
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  late String selectedModel;
  late String selectedLanguage;
  late String selectedGender;
  late String selectedVoice;
  late bool customInput;

  bool isEditMode = false;
  int _selectedOption = 1; // Default: Grid

  final Map<int, String> _dropdownItems = {1: 'Grid', 2: 'Remote'};

  @override
  void initState() {
    super.initState();
    // Assign default values before async initialization
    selectedModel = widget.initialSelectedModel;
    selectedLanguage = widget.initialSelectedLanguage;
    selectedGender = widget.initialSelectedGender;
    selectedVoice = widget.initialSelectedVoice;
    customInput = widget.initialCustomInput;

    _initializeState();
  }

  Future<void> _initializeState() async {
    final settings = await _databaseHelper.getSettings();
    if (settings != null) {
      setState(() {
        selectedModel = settings["model"]?.toString() ?? widget.initialSelectedModel;
        selectedLanguage = settings["language_code"]?.toString() ?? widget.initialSelectedLanguage;
        selectedGender = settings["gender"]?.toString() ?? widget.initialSelectedGender;
        selectedVoice = settings["voice"]?.toString() ?? widget.initialSelectedVoice;
        customInput = settings["custom_input"] == 1;
      });
      widget.voiceHandler.updateVoice(selectedModel, selectedLanguage, selectedGender, selectedVoice);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () async {
            await Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => SettingsPage(
                  voiceHandler: widget.voiceHandler,
                  initialSelectedModel: selectedModel,
                  initialSelectedLanguage: selectedLanguage,
                  initialSelectedGender: selectedGender,
                  initialSelectedVoice: selectedVoice,
                  initialCustomInput: customInput,
                ),
              ),
            );
            _initializeState();
            setState(() {});
          },

          icon: const Icon(Icons.settings),
        ),
        title: DropdownButton<int>(
          value: _selectedOption,
          items: _dropdownItems.entries.map((entry) {
            return DropdownMenuItem<int>(
              value: entry.key,
              child: Text(entry.value),
            );
          }).toList(),
          onChanged: (int? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedOption = newValue;
              });
            }
          },
          underline: Container(),
        ),
        actions: [
          IconButton(
            onPressed: () => setState(() => isEditMode = !isEditMode),
            icon: Icon(isEditMode ? Icons.edit : Symbols.brand_awareness),
          ),
        ],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _selectedOption == 1
                  ? ChicletGridView(voiceHandler: widget.voiceHandler)
                  : RemoteControlView(voiceHandler: widget.voiceHandler),
            ),
            if (customInput) const SizedBox(height: 10),
            if (customInput)
              Row(
                children: [
                  Flexible(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        labelText: 'Enter text',
                      ),
                      maxLines: null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filledTonal(
                    onPressed: () => widget.voiceHandler.speak(_controller.text),
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
