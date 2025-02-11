import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:text_to_speech_wizard_for_evaluations/pages/settings.dart';
import 'package:text_to_speech_wizard_for_evaluations/util/voice.dart';
import 'package:text_to_speech_wizard_for_evaluations/views/grid_view.dart';
import 'package:text_to_speech_wizard_for_evaluations/views/remote_control_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final voiceHandler = VoiceHandler();
  await voiceHandler.init();
  runApp(MyApp(voiceHandler: voiceHandler));
}

class MyApp extends StatelessWidget {
  final VoiceHandler voiceHandler;

  const MyApp({super.key, required this.voiceHandler});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Text-To-Speech | Wizard-Of-Oz for Evaluations',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: TextToSpeechScreen(voiceHandler: voiceHandler),
    );
  }
}

class TextToSpeechScreen extends StatefulWidget {
  final VoiceHandler voiceHandler;

  const TextToSpeechScreen({super.key, required this.voiceHandler});

  @override
  _TextToSpeechScreenState createState() => _TextToSpeechScreenState();
}

class _TextToSpeechScreenState extends State<TextToSpeechScreen> {
  final TextEditingController _controller = TextEditingController();

  // Define your dropdown items
  final Map<int, String> _dropdownItems = {
    1: 'Grid',
    2: 'Remote',
  };

  bool isEditMode = false;

  int _selectedOption = 1; // Default selected option

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const SettingsPage(),
            ),
          );
        }, icon: const Icon(Icons.settings)),
        title: DropdownButton<int>(
          value: _selectedOption,
          items: _dropdownItems.entries.map((entry) {
            return DropdownMenuItem<int>(
              value: entry.key,
              child: Text(entry.value),
            );
          }).toList(),
          onChanged: (int? newValue) {
            setState(() {
              _selectedOption = newValue!;
            });
          },
          underline: Container(), // Removes the default underline
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isEditMode = !isEditMode;
              });
            },
            icon: isEditMode ? const Icon(Icons.edit) : const Icon(Symbols.brand_awareness)
          )
        ],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: _selectedOption == 1 ? ChicletGridView(voiceHandler: widget.voiceHandler) : RemoteControlView(voiceHandler: widget.voiceHandler)),
            const SizedBox(height: 10),
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
