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
  Map<int, bool> isLoading = {};

  Future<void> _handlePress(int index, String message) async {
    setState(() {
      isLoading[index] = true;
    });

    await widget.voiceHandler.speak(message);

    setState(() {
      isLoading[index] = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> buttons = [
      {"cellsX": 1, "cellsY": 1, "icon": null, "message": null},
      {"cellsX": 5, "cellsY": 1, "icon": Icons.keyboard_double_arrow_up, "message": "An der nächsten Kreuzung geradeaus."},
      {"cellsX": 1, "cellsY": 1, "icon": null, "message": null},
      {"cellsX": 1, "cellsY": 5, "icon": Icons.keyboard_double_arrow_left, "message": "An der nächsten Kreuzung links."},
      {"cellsX": 1, "cellsY": 1, "icon": null, "message": null},
      {"cellsX": 3, "cellsY": 1, "icon": Icons.keyboard_arrow_up, "message": "Jetzt geradeaus."},
      {"cellsX": 1, "cellsY": 1, "icon": null, "message": null},
      {"cellsX": 1, "cellsY": 5, "icon": Icons.keyboard_double_arrow_right, "message": "An der nächsten Kreuzung rechts."},
      {"cellsX": 1, "cellsY": 3, "icon": Icons.keyboard_arrow_left, "message": "Jetzt links."},
      {"cellsX": 3, "cellsY": 3, "icon": null, "message": null},
      {"cellsX": 1, "cellsY": 3, "icon": Icons.keyboard_arrow_right, "message": "Jetzt rechts."},
      {"cellsX": 1, "cellsY": 1, "icon": null, "message": null},
      {"cellsX": 3, "cellsY": 1, "icon": Icons.keyboard_arrow_down, "message": "Jetzt zurück."},
      {"cellsX": 1, "cellsY": 1, "icon": null, "message": null},
      {"cellsX": 1, "cellsY": 1, "icon": null, "message": null},
      {"cellsX": 5, "cellsY": 1, "icon": Icons.keyboard_double_arrow_down, "message": "An der nächsten Kreuzung zurück."},
      {"cellsX": 1, "cellsY": 1, "icon": null, "message": null},
    ];

    return Center(
      child: StaggeredGrid.count(
        crossAxisCount: 7,
        mainAxisSpacing: 7,
        crossAxisSpacing: 7,
        children: List.generate(buttons.length, (index) {
          final button = buttons[index];
          return StaggeredGridTile.count(
            crossAxisCellCount: button["cellsX"],
            mainAxisCellCount: button["cellsY"],
            child: ChicletOutlinedAnimatedButton(
              buttonType: button["icon"] == null ? ChicletButtonTypes.circle : ChicletButtonTypes.roundedRectangle,
              onPressed: button["message"] == null
                  ? null
                  : () => _handlePress(index, button["message"] as String),
              child: isLoading[index] == true
                  ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                ),
              )
                  : button["icon"] != null
                  ? Icon(button["icon"])
                  : const Text(""),
            ),
          );
        }),
      ),
    );
  }
}
