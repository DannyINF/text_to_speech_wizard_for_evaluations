import 'dart:convert';

import 'package:chiclet/chiclet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../db.dart';
import '../util/voice.dart';
import 'package:flutter_iconpicker/Models/configuration.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';

class RemoteControlView extends StatefulWidget {
  const RemoteControlView({super.key, required this.voiceHandler});

  final VoiceHandler voiceHandler;

  @override
  State<RemoteControlView> createState() => _RemoteControlViewState();
}

class _RemoteControlViewState extends State<RemoteControlView> {
  Map<int, bool> isLoading = {};
  Map<int, IconPickerIcon?> tempIcons = {};
  Map<int, IconPickerIcon?> selectedIcons = {};
  Map<int, TextEditingController> titleControllers = {};
  Map<int, TextEditingController> spokenControllers = {};
  Map<int, TextEditingController> tempTitleControllers = {};
  Map<int, TextEditingController> tempSpokenControllers = {};
  Map<int, String> titles = {};
  Map<int, String> spoken = {};
  final String view = "remote_control";
  List<Map<String, dynamic>> buttons = [];

  @override
  void initState() {
    super.initState();
    _loadButtons();
  }

  Future<void> _loadButtons() async {
    final dbHelper = DatabaseHelper();
    final storedButtons = await dbHelper.getButtonsByView(view);

    if (storedButtons.isNotEmpty) {
      setState(() {
        buttons = storedButtons;
      });
    } else {
      setState(() {
        buttons = [
          {"cellsX": 1, "cellsY": 1, "icon": "", "message": "", "title": ""},
          {
            "cellsX": 5,
            "cellsY": 1,
            "icon": listMapToString(serializeIcons([IconPickerIcon(
              name: 'keyboard_double_arrow_up',
              data: Icons.keyboard_double_arrow_up,
              pack: IconPack.material,
            )])),
            "message": "An der nächsten Kreuzung geradeaus.",
            "title": ""
          },
          {"cellsX": 1, "cellsY": 1, "icon": "", "message": "", "title": ""},
          {
            "cellsX": 1,
            "cellsY": 5,
            "icon": listMapToString(serializeIcons([IconPickerIcon(
              name: 'keyboard_double_arrow_left',
              data: Icons.keyboard_double_arrow_left,
              pack: IconPack.material,
            )])),
            "message": "An der nächsten Kreuzung links.",
            "title": ""
          },
          {"cellsX": 1, "cellsY": 1, "icon": "", "message": "", "title": ""},
          {
            "cellsX": 3,
            "cellsY": 1,
            "icon": listMapToString(serializeIcons([IconPickerIcon(
              name: 'keyboard_arrow_up',
              data: Icons.keyboard_arrow_up,
              pack: IconPack.material,
            )])),
            "message": "Jetzt geradeaus.",
            "title": ""
          },
          {"cellsX": 1, "cellsY": 1, "icon": "", "message": "", "title": ""},
          {
            "cellsX": 1,
            "cellsY": 5,
            "icon": listMapToString(serializeIcons([IconPickerIcon(
              name: 'keyboard_double_arrow_right',
              data: Icons.keyboard_double_arrow_right,
              pack: IconPack.material,
            )])),
            "message": "An der nächsten Kreuzung rechts.",
            "title": ""
          },
          {
            "cellsX": 1,
            "cellsY": 3,
            "icon": listMapToString(serializeIcons([IconPickerIcon(
              name: 'keyboard_arrow_left',
              data: Icons.keyboard_arrow_left,
              pack: IconPack.material,
            )])),
            "message": "Jetzt links.",
            "title": ""
          },
          {"cellsX": 3, "cellsY": 3, "icon": "", "message": "", "title": ""},
          {
            "cellsX": 1,
            "cellsY": 3,
            "icon": listMapToString(serializeIcons([IconPickerIcon(
              name: 'keyboard_arrow_right',
              data: Icons.keyboard_arrow_right,
              pack: IconPack.material,
            )])),
            "message": "Jetzt rechts.",
            "title": ""
          },
          {"cellsX": 1, "cellsY": 1, "icon": "", "message": "", "title": ""},
          {
            "cellsX": 3,
            "cellsY": 1,
            "icon": listMapToString(serializeIcons([IconPickerIcon(
              name: 'keyboard_arrow_down',
              data: Icons.keyboard_arrow_down,
              pack: IconPack.material,
            )])),
            "message": "Jetzt zurück.",
            "title": ""
          },
          {"cellsX": 1, "cellsY": 1, "icon": "", "message": "", "title": ""},
          {"cellsX": 1, "cellsY": 1, "icon": "", "message": "", "title": ""},
          {
            "cellsX": 5,
            "cellsY": 1,
            "icon": listMapToString(serializeIcons([IconPickerIcon(
              name: 'keyboard_double_arrow_down',
              data: Icons.keyboard_double_arrow_down,
              pack: IconPack.material,
            )])),
            "message": "An der nächsten Kreuzung zurück.",
            "title": ""
          },
          {"cellsX": 1, "cellsY": 1, "icon": "", "message": "", "title": ""},
        ];

      });
      for (int i = 0; i < buttons.length; i++) {
        final button = buttons[i];
        await dbHelper.insertButton(i, view, button["cellsX"] as int, button["cellsY"] as int, button["icon"] == "" ? "" : button["icon"], "", button["message"] == null ? "" : button["message"]);
      }
    }
    setState(() {
      for (int i = 0; i < buttons.length; i++) {
        isLoading[i] = false;
        tempIcons[i] = buttons[i]["icon"] == "" ? null : deserializeIcons(stringToListMap(buttons[i]["icon"]))?[0];
        selectedIcons[i] = buttons[i]["icon"] == "" ? null : deserializeIcons(stringToListMap(buttons[i]["icon"]))?[0];
        titleControllers[i] = TextEditingController(text: buttons[i]["title"]);
        spokenControllers[i] = TextEditingController(text: buttons[i]["message"]);
        tempTitleControllers[i] = TextEditingController(text: buttons[i]["title"]);
        tempSpokenControllers[i] = TextEditingController(text: buttons[i]["message"]);
        titles[i] = buttons[i]["title"];
        spoken[i] = buttons[i]["message"];
      }
    });
  }

  Future<void> _handleLongPress(int index) async {
    setState(() {
      isLoading[index] = true;
    });

    tempIcons[index] = selectedIcons[index];
    tempTitleControllers[index] = TextEditingController(text: titleControllers[index]?.text);
    tempSpokenControllers[index] = TextEditingController(text: spokenControllers[index]?.text);

    await showAdaptiveDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return SimpleDialog(
              children: [
                ListTile(
                  leading: IconButton(
                    onPressed: tempIcons[index] == null ? null : () {
                      setDialogState(() {
                        selectedIcons[index] = null;
                        tempIcons[index] = null;
                      });
                    },
                    icon: Icon(Symbols.delete),
                  ),
                  title: OutlinedButton(
                    onPressed: () async {
                      IconPickerIcon? pickedIcon = await showIconPicker(
                        context,
                        configuration: SinglePickerConfiguration(
                          shouldScrollToSelectedIcon: true,
                          iconColor: Theme.of(context).colorScheme.primary,
                        ),
                      );

                      if (pickedIcon != null) {
                        setDialogState(() {
                          tempIcons[index] = pickedIcon;
                        });
                      }
                    },
                    child: SizedBox(
                      height: 60,
                      child: Icon(
                        tempIcons[index]?.data,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                ListTile(
                  title: TextField(
                    controller: tempTitleControllers[index],
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
                    controller: tempSpokenControllers[index],
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
                          Navigator.of(context).pop(null);
                        },
                        child: const Text("Cancel"),
                        textColor: Theme.of(context).colorScheme.error,
                      ),
                      MaterialButton(
                        onPressed: () {
                          Navigator.of(context).pop({
                            'icon': tempIcons[index],
                            'title': tempTitleControllers[index]?.text,
                            'spoken': tempSpokenControllers[index]?.text,
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
    ).then((result) async {
      if (result != null) {
        setState(() {
          selectedIcons[index] = result['icon'];
          titleControllers[index]?.text = result['title'].toString();
          spokenControllers[index]?.text = result['spoken'].toString();
          titles[index] = result['title'].toString();
          spoken[index] = result['spoken'].toString();
        });

        // Update database
        final dbHelper = DatabaseHelper();
        await dbHelper.updateButton(index, view, buttons[index]['cellsX'], buttons[index]['cellsY'], selectedIcons[index] == null ? "" : listMapToString(serializeIcons([selectedIcons[index]!])), titles[index]!, spoken[index]!);
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
            child: GestureDetector(
              onLongPress: () => _handleLongPress(index),
              child: ChicletOutlinedAnimatedButton(
                buttonType: selectedIcons[index] == null ? ChicletButtonTypes.circle : ChicletButtonTypes.roundedRectangle,
                onPressed: spokenControllers[index] == null || spokenControllers[index]?.text == ""
                    ? null
                    : () => _handlePress(index, spokenControllers[index]!.text),
                child: isLoading[index] == true
                    ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                  ),
                )
                    : selectedIcons[index] != null
                    ? Icon(selectedIcons[index]?.data)
                    : const Text(""),
              ),
            ),
          );
        }),
      ),
    );
  }

  // Convert List<Map<dynamic, String>?> to String
  String listMapToString(List<Map<String, dynamic>?> list) {
    return jsonEncode(list);
  }

  // Convert String back to List<Map<dynamic, String>?>
  List<Map<String, dynamic>?> stringToListMap(String str) {
    List<dynamic> decoded = jsonDecode(str);

    // Convert each element to Map<dynamic, String>?, handling null values
    return decoded.map((e) => e != null ? Map<String, dynamic>.from(e as Map) : null).toList();
  }
}
