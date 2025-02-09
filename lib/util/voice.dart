// voice.dart
import 'package:cloud_text_to_speech/cloud_text_to_speech.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:typed_data';

import 'package:text_to_speech_wizard_for_evaluations/db.dart';
import 'package:text_to_speech_wizard_for_evaluations/env.dart';

class VoiceHandler {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final AudioPlayer _audioPlayer = AudioPlayer();
  late VoiceGoogle _selectedVoice;

  Future<void> init() async {
    try {
      TtsGoogle.init(
        params: InitParamsGoogle(apiKey: Env.GOOGLE_KEY),
        withLogs: true,
      );
      await _loadVoices();
    } catch (e) {
      print("Error initializing TTS: $e");
    }
  }

  Future<void> _loadVoices() async {
    try {
      final voicesResponse = await TtsGoogle.getVoices();
      final voices = voicesResponse.voices;
      if (voices.isNotEmpty) {
        _selectedVoice = voices.firstWhere(
              (voice) => voice.locale.code.startsWith('de-') &&
              voice.engines.first == "wavenet" &&
              voice.gender == "Female",
          orElse: () => voices.first,
        );
      } else {
        print("No voices available.");
      }
    } catch (e) {
      print("Error fetching voices: $e");
    }
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
