import 'package:chiclet/chiclet.dart';
import 'package:flutter/material.dart';
import '../util/voice.dart';

class ChicletGridView extends StatefulWidget {
  const ChicletGridView({super.key, required this.voiceHandler});

  final VoiceHandler voiceHandler;

  @override
  State<ChicletGridView> createState() => _ChicletGridViewState();
}

class _ChicletGridViewState extends State<ChicletGridView> {
  Map<int, bool> isLoading = {};

  Future<void> _handlePress(int x) async {
    setState(() {
      isLoading[x] = true;
    });

    await widget.voiceHandler.speak("$x");

    setState(() {
      isLoading[x] = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GridView.count(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        children: [
          for (var x = 0; x < 15; x++)
            ChicletOutlinedAnimatedButton(
              onPressed: x % 5 == 0 ? null : () => _handlePress(x),
              child: isLoading[x] == true
                  ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                ),
              )
                  : Text("$x"),
            ),
        ],
      ),
    );
  }
}
