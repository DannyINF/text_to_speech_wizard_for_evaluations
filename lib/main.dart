import 'package:flutter/material.dart';
import 'package:cloud_text_to_speech/cloud_text_to_speech.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:typed_data';

import 'package:text_to_speech_wizard_for_evaluations/db.dart';
import 'package:text_to_speech_wizard_for_evaluations/env.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    TtsGoogle.init(
      params: InitParamsGoogle(apiKey: Env.GOOGLE_KEY),
      withLogs: true,
    );
    runApp(MyApp());
  } catch (e) {
    print("Error initializing TTS: $e");
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Text to Speech Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TextToSpeechScreen(),
    );
  }
}

class TextToSpeechScreen extends StatefulWidget {
  @override
  _TextToSpeechScreenState createState() => _TextToSpeechScreenState();
}

class _TextToSpeechScreenState extends State<TextToSpeechScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final TextEditingController _controller = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  late VoiceGoogle _selectedVoice;

  @override
  void initState() {
    super.initState();
    _loadVoices();
  }

  Future<void> _loadVoices() async {
    try {
      final voicesResponse = await TtsGoogle.getVoices();
      final voices = voicesResponse.voices;
      if (voices.isNotEmpty) {
        setState(() {
          _selectedVoice = voices.firstWhere(
                (voice) => voice.locale.code.startsWith('de-') && voice.engines.first == "wavenet" && voice.gender == "Female",
            orElse: () => voices.first,
          );
        });
      } else {
        print("No voices available.");
      }
    } catch (e) {
      print("Error fetching voices: $e");
    }
  }

  Future<void> _speak() async {
    if (_controller.text.isEmpty) return;

    final ttsParams = TtsParamsGoogle(
      voice: _selectedVoice,
      audioFormat: AudioOutputFormatGoogle.mp3,
      text: _controller.text,
      pitch: 'default',
    );

    // check db
    var result = await _databaseHelper.getAudioFile(_controller.text, _selectedVoice.gender.toString(), "google", _selectedVoice.provider, _selectedVoice.locale.languageCode.toString());
    if (result != null) {
      // Play the stored audio content
      Uint8List audioBytes = result["content"];
      await _audioPlayer.setAudioSource(MyJABytesSource(audioBytes));
      _audioPlayer.play();
      print("loaded from db and played");
    } else {
      try {
        // Convert text to speech and retrieve audio
        final ttsResponse = await TtsGoogle.convertTts(ttsParams);
        final Uint8List audioBytes =
        ttsResponse.audio.buffer.asByteData().buffer.asUint8List();

        // Save the new audio to the database
        await _databaseHelper.insertAudioFile(
          _controller.text,
          _selectedVoice.gender,
          "google",
          _selectedVoice.provider,
          _selectedVoice.locale.languageCode.toString(),
          audioBytes,
        );

        // Play the newly generated audio
        await _audioPlayer.setAudioSource(MyJABytesSource(audioBytes));
        _audioPlayer.processingStateStream.listen((ProcessingState state) {
          if (state == ProcessingState.ready) {
            _audioPlayer.play();
          } else if (state == ProcessingState.completed) {
            print("Playback completed");
          }
        });
      } catch (e) {
        print("Error converting text to speech: $e");
      }
    }


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Text to Speech Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter text',
              ),
              maxLines: null,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _speak,
              child: Text('Convert to Speech'),
            ),

          ],
        ),
      ),
    );
  }
}

class MyJABytesSource extends StreamAudioSource {
  final Uint8List _buffer;

  MyJABytesSource(this._buffer) : super(tag: 'MyAudioSource');

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    return StreamAudioResponse(
      sourceLength: _buffer.length,
      contentLength: (end ?? _buffer.length) - (start ?? 0),
      offset: start ?? 0,
      stream: Stream.fromIterable([_buffer.sublist(start ?? 0, end)]),
      contentType: 'audio/wav',
    );
  }
}
