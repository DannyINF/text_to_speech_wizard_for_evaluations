import 'package:chiclet/chiclet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../util/voice.dart';

class RemoteControlView extends StatefulWidget {
  const RemoteControlView({super.key, required this.voiceHandler});

  final VoiceHandler voiceHandler;

  @override
  State<RemoteControlView> createState() => _RemoteControlViewState();
}

class _RemoteControlViewState extends State<RemoteControlView> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: StaggeredGrid.count(
        crossAxisCount: 7,
        mainAxisSpacing: 7,
        crossAxisSpacing: 7,
        children: [
          StaggeredGridTile.count(
            crossAxisCellCount: 1,
            mainAxisCellCount: 1,
            child: ChicletOutlinedAnimatedButton(
              buttonType: ChicletButtonTypes.circle,
              onPressed: null,
              child: const Text(""),
            ),
          ),
          StaggeredGridTile.count(
            crossAxisCellCount: 5,
            mainAxisCellCount: 1,
            child: ChicletOutlinedAnimatedButton(
              onPressed: () {widget.voiceHandler.speak("An der nächsten Kreuzung geradeaus.");},
              child: Icon(Icons.keyboard_double_arrow_up),
            ),
          ),
          StaggeredGridTile.count(
            crossAxisCellCount: 1,
            mainAxisCellCount: 1,
            child: ChicletOutlinedAnimatedButton(
              buttonType: ChicletButtonTypes.circle,
              onPressed: null,
              child: Text(""),
            ),
          ),
          StaggeredGridTile.count(
            crossAxisCellCount: 1,
            mainAxisCellCount: 5,
            child: ChicletOutlinedAnimatedButton(
              onPressed: () {widget.voiceHandler.speak("An der nächsten Kreuzung links.");},
              child: Icon(Icons.keyboard_double_arrow_left),
            ),
          ),
          StaggeredGridTile.count(
            crossAxisCellCount: 1,
            mainAxisCellCount: 1,
            child: ChicletOutlinedAnimatedButton(
              buttonType: ChicletButtonTypes.circle,
              onPressed: null,
              child: Text(""),
            ),
          ),
          StaggeredGridTile.count(
            crossAxisCellCount: 3,
            mainAxisCellCount: 1,
            child: ChicletOutlinedAnimatedButton(
              onPressed: () {widget.voiceHandler.speak("Jetzt geradeaus.");},
              child: Icon(Icons.keyboard_arrow_up),
            ),
          ),
          StaggeredGridTile.count(
            crossAxisCellCount: 1,
            mainAxisCellCount: 1,
            child: ChicletOutlinedAnimatedButton(
              buttonType: ChicletButtonTypes.circle,
              onPressed: null,
              child: Text(""),
            ),
          ),
          StaggeredGridTile.count(
            crossAxisCellCount: 1,
            mainAxisCellCount: 5,
            child: ChicletOutlinedAnimatedButton(
              onPressed: () {widget.voiceHandler.speak("An der nächsten Kreuzung rechts.");},
              child: Icon(Icons.keyboard_double_arrow_right),
            ),
          ),
          StaggeredGridTile.count(
            crossAxisCellCount: 1,
            mainAxisCellCount: 3,
            child: ChicletOutlinedAnimatedButton(
              onPressed: () {widget.voiceHandler.speak("Jetzt links.");},
              child: Icon(Icons.keyboard_arrow_left),
            ),
          ),
          StaggeredGridTile.count(
            crossAxisCellCount: 3,
            mainAxisCellCount: 3,
            child: ChicletOutlinedAnimatedButton(
              buttonType: ChicletButtonTypes.circle,
              onPressed: null,
              child: Text(""),
            ),
          ),
          StaggeredGridTile.count(
            crossAxisCellCount: 1,
            mainAxisCellCount: 3,
            child: ChicletOutlinedAnimatedButton(
              onPressed: () {widget.voiceHandler.speak("Jetzt rechts.");},
              child: Icon(Icons.keyboard_arrow_right),
            ),
          ),
          StaggeredGridTile.count(
            crossAxisCellCount: 1,
            mainAxisCellCount: 1,
            child: ChicletOutlinedAnimatedButton(
              buttonType: ChicletButtonTypes.circle,
              onPressed: null,
              child: const Text(""),
            ),
          ),
          StaggeredGridTile.count(
            crossAxisCellCount: 3,
            mainAxisCellCount: 1,
            child: ChicletOutlinedAnimatedButton(
              onPressed: () {widget.voiceHandler.speak("Jetzt zurück.");},
              child: Icon(Icons.keyboard_arrow_down),
            ),
          ),
          StaggeredGridTile.count(
            crossAxisCellCount: 1,
            mainAxisCellCount: 1,
            child: ChicletOutlinedAnimatedButton(
              buttonType: ChicletButtonTypes.circle,
              onPressed: null,
              child: Text(""),
            ),
          ),
          StaggeredGridTile.count(
            crossAxisCellCount: 1,
            mainAxisCellCount: 1,
            child: ChicletOutlinedAnimatedButton(
              buttonType: ChicletButtonTypes.circle,
              onPressed: null,
              child: Text(""),
            ),
          ),
          StaggeredGridTile.count(
            crossAxisCellCount: 5,
            mainAxisCellCount: 1,
            child: ChicletOutlinedAnimatedButton(
              onPressed: () {widget.voiceHandler.speak("An der nächsten Kreuzung zurück.");},
              child: Icon(Icons.keyboard_double_arrow_down),
            ),
          ),
          StaggeredGridTile.count(
            crossAxisCellCount: 1,
            mainAxisCellCount: 1,
            child: ChicletOutlinedAnimatedButton(
              buttonType: ChicletButtonTypes.circle,
              onPressed: null,
              child: Text(""),
            ),
          ),
        ],
      ),
    );
  }
}