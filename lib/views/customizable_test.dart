import 'package:chiclet/chiclet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/Models/configuration.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../util/voice.dart';

class CustomizableTest extends StatefulWidget {
  const CustomizableTest({super.key, required this.voiceHandler});

  final VoiceHandler voiceHandler;

  @override
  State<CustomizableTest> createState() => _CustomizableTestState();
}

class _CustomizableTestState extends State<CustomizableTest> {
  Map<int, bool> isLoading = {};
  IconData? selectedIcon;
  String title = "";
  String spoken = "";

  TextEditingController _controllerTitle = TextEditingController();
  TextEditingController _controllerSpoken = TextEditingController();

  Future<void> _handleLongPress(int index, String message) async {
    setState(() {
      isLoading[index] = true;
    });

    // Temporary variables
    IconData? tempIcon = selectedIcon;
    TextEditingController tempTitleController = TextEditingController(text: _controllerTitle.text);
    TextEditingController tempSpokenController = TextEditingController(text: _controllerSpoken.text);

    await showAdaptiveDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return SimpleDialog(
              children: [
                ListTile(
                  leading: OutlinedButton(
                    style: ButtonStyle(
                        shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        )
                    ),
                    onPressed: () async {
                      IconPickerIcon? pickedIcon = await showIconPicker(
                        context,
                        configuration: SinglePickerConfiguration(
                          iconColor: Theme.of(context).colorScheme.primary,
                        ),
                      );

                      if (pickedIcon != null) {
                        setDialogState(() {
                          tempIcon = pickedIcon.data;
                        });
                      }
                    },
                    child: SizedBox(
                      height: 60,
                      child: Icon(
                        tempIcon ?? Symbols.add,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  title: TextField(
                    controller: tempTitleController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelText: 'Title (optional)',
                    ),
                    maxLines: null,
                  ),
                ),
                ListTile(
                  title: TextField(
                    controller: tempSpokenController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelText: 'Text to be spoken',
                    ),
                    maxLines: null,
                  ),
                ),
                ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MaterialButton(
                        onPressed: () {
                          Navigator.of(context).pop(null); // Dismiss without saving
                        },
                        child: const Text("Cancel"),
                        textColor: Theme.of(context).colorScheme.error,
                      ),
                      MaterialButton(
                        onPressed: () {
                          Navigator.of(context).pop({
                            'icon': tempIcon,
                            'title': tempTitleController.text,
                            'spoken': tempSpokenController.text,
                          });
                        },
                        child: const Text("Save"),
                      ),
                    ],
                  ),
                )
              ],
            );
          },
        );
      },
    ).then((result) {
      // Apply changes only if "Save" was pressed
      if (result != null) {
        setState(() {
          selectedIcon = result['icon'];
          _controllerTitle.text = result['title'];
          _controllerSpoken.text = result['spoken'];
          title = _controllerTitle.text;
          spoken = _controllerSpoken.text;
        });
      }
    });

    setState(() {
      isLoading[index] = false;
    });
  }

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
      {"cellsX": 5, "cellsY": 5, "icon": Icons.plus_one, "message": "press"},
    ];

    return Center(
      child: StaggeredGrid.count(
        crossAxisCount: 5,
        mainAxisSpacing: 7,
        crossAxisSpacing: 7,
        children: List.generate(buttons.length, (index) {
          final button = buttons[index];
          return StaggeredGridTile.count(
            crossAxisCellCount: button["cellsX"],
            mainAxisCellCount: button["cellsY"],
            child: GestureDetector(
              onLongPress: button["message"]?.isNotEmpty == true
                  ? () => _handleLongPress(index, button["message"] as String)
                  : null,
              child: ChicletOutlinedAnimatedButton(
                buttonType: button["icon"] == null
                    ? ChicletButtonTypes.circle
                    : ChicletButtonTypes.roundedRectangle,
                onPressed: spoken == "" ? null : () => _handlePress(index, spoken),
                child: isLoading[index] == true
                    ? Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                )
                    : button["icon"] != null
                    ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(selectedIcon),
                        title != "" ? Text(title) : SizedBox(),
                      ],
                    )
                    : const Text(""),
              ),
            )
          );
        }),
      ),
    );
  }
}
