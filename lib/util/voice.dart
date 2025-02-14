import 'package:cloud_text_to_speech/cloud_text_to_speech.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:typed_data';

import 'package:text_to_speech_wizard_for_evaluations/db.dart';
import 'package:text_to_speech_wizard_for_evaluations/env.dart';

class VoiceHandler {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final AudioPlayer _audioPlayer = AudioPlayer();
  late VoiceGoogle _selectedVoice;
  late List<VoiceGoogle> cachedVoices;

  List<String> _models = [];
  Map<String, List<String>> _languages = {};
  Map<String, Map<String, List<String>>> _genders = {};
  Map<String, Map<String, Map<String, List<String>>>> _names = {};

  Future<void> init() async {
    try {
      TtsGoogle.init(
        params: InitParamsGoogle(apiKey: Env.GOOGLE_KEY),
        withLogs: false,
      );
      await _loadVoices();
    } catch (e) {
      print("Error initializing TTS: $e");
    }
  }

  void updateVoice(String engine, String language, String gender, String name) {
    try {
      print(cachedVoices);
      if (cachedVoices.isNotEmpty) {
        _selectedVoice = cachedVoices.firstWhere(
              (voice) =>
          voice.locale.languageName == language &&
              voice.engines.isNotEmpty &&
              voice.engines.first == engine &&
              voice.gender == gender &&
              voice.name == name,
          orElse: () => cachedVoices.first,
        );
      }
    } catch(e) {
      print("Error fetching voices: $e");
    }
  }

  Future<void> _loadVoices() async {
    try {
      final voicesResponse = await TtsGoogle.getVoices();
      final voices = voicesResponse.voices;
      cachedVoices = voices;

      if (voices.isNotEmpty) {
        _selectedVoice = voices.firstWhere(
              (voice) =>
          voice.locale.languageName == "German" &&
              voice.engines.isNotEmpty &&
              voice.engines.first == "wavenet" &&
              voice.gender == "Female",
          orElse: () => voices.first,
        );

        // Populate models
        _models = {
          for (var voice in voices)
            if (voice.engines.isNotEmpty) voice.engines.first
        }.toList();

        // Populate languages, genders, and names
        _languages = {};
        _genders = {};
        _names = {};

        for (var model in _models) {
          // Get languages for each model
          var modelLanguages = {
            for (var voice in voices.where(
                    (v) => v.engines.isNotEmpty && v.engines.first == model))
              voice.locale.languageName.toString()
          }.toList();

          _languages[model] = modelLanguages;

          _genders[model] = {};
          _names[model] = {};

          for (var language in modelLanguages) {
            // Get genders for each model and language
            var modelLanguageGenders = {
              for (var voice in voices.where((v) =>
              v.engines.isNotEmpty &&
                  v.locale.languageName!.isNotEmpty &&
                  v.engines.first == model &&
                  v.locale.languageName == language))
                voice.gender
            }.toList();

            _genders[model]![language] = modelLanguageGenders;
            _names[model]![language] = {};

            for (var gender in modelLanguageGenders) {
              // Get names for each model, language, and gender
              var modelLanguageGenderNames = {
                for (var voice in voices.where((v) =>
                v.engines.isNotEmpty &&
                    v.locale.languageName!.isNotEmpty &&
                    v.gender.isNotEmpty &&
                    v.engines.first == model &&
                    v.locale.languageName == language &&
                    v.gender == gender))
                  if (voice.name.isNotEmpty) voice.name
              }.toList();

              _names[model]![language]![gender] = modelLanguageGenderNames;
            }
          }
        }
      } else {
        print("No voices available.");
      }
    } catch (e) {
      print("Error fetching voices: $e");
    }
  }


  // Return models as a regular list
  List<String> getModels() {
    return _models;
  }

  // Return languages as a regular list based on model
  List<String> getLanguages(String model) {
    return _languages[model] ?? [];
  }

  // Return genders as a regular list based on model and language
  List<String> getGenders(String model, String language) {
    return _genders[model]?[language] ?? [];
  }

  // Return names as a regular list based on model, language, and gender
  List<String> getNames(String model, String language, String gender) {
    return _names[model]?[language]?[gender] ?? [];
  }

  Future<void> speak(String message) async {
    final ttsParams = TtsParamsGoogle(
      voice: _selectedVoice,
      audioFormat: AudioOutputFormatGoogle.mp3,
      text: message,
      pitch: 'default',
    );

    var result = await _databaseHelper.getAudioFile(
      message,
      _selectedVoice.gender.toString(),
      "google",
      _selectedVoice.provider,
      _selectedVoice.locale.languageCode.toString(),
    );

    if (result != null) {
      Uint8List audioBytes = result["content"];
      await _audioPlayer.setAudioSource(MyJABytesSource(audioBytes));
      _audioPlayer.play();
      print("loaded from db and played");
    } else {
      try {
        final ttsResponse = await TtsGoogle.convertTts(ttsParams);
        final Uint8List audioBytes =
        ttsResponse.audio.buffer.asByteData().buffer.asUint8List();

        await _databaseHelper.insertAudioFile(
          message,
          _selectedVoice.gender,
          "google",
          _selectedVoice.provider,
          _selectedVoice.locale.languageCode.toString(),
          audioBytes,
        );

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
