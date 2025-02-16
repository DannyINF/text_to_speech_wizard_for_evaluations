import 'dart:convert';

import 'package:chiclet/chiclet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/Models/configuration.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../db.dart';
import '../util/voice.dart';

class CustomizableTest extends StatefulWidget {
  const CustomizableTest({super.key, required this.voiceHandler});

  final VoiceHandler voiceHandler;

  @override
  State<CustomizableTest> createState() => _CustomizableTestState();
}

class _CustomizableTestState extends State<CustomizableTest> {
  Map<int, bool> isLoading = {};
  IconPickerIcon? selectedIcon;
  String title = "";
  String spoken = "";
  final String view = "custom";

  TextEditingController _controllerTitle = TextEditingController();
  TextEditingController _controllerSpoken = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadButton();
  }

  Future<void> _loadButton() async {
    final dbHelper = DatabaseHelper();
    final buttonData = await dbHelper.getButtonByIdAndView(0, view);

    if (buttonData != null) {
      setState(() {
        selectedIcon = buttonData["icon"] == "" ? null : deserializeIcons(stringToListMap(buttonData["icon"]))?[0];
        title = buttonData["title"] ?? "";
        spoken = buttonData["message"] ?? "";
        _controllerTitle.text = title;
        _controllerSpoken.text = spoken;
      });
    } else {
      // Save a default button if none exists
      await dbHelper.insertButton(0, view, 5, 5, "", "", "");
    }
  }

  Future<void> _handleLongPress(int index, String message) async {
    setState(() {
      isLoading[index] = true;
    });

    IconPickerIcon? tempIcon = selectedIcon;
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
                  leading: IconButton(
                    onPressed: tempIcon == null ? null : () {
                      setDialogState(() {
                        selectedIcon = null;
                        tempIcon = null;
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
                          tempIcon = pickedIcon;
                        });
                      }
                    },
                    child: SizedBox(
                      height: 60,
                      child: Icon(
                        tempIcon?.data,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                ListTile(
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
                          Navigator.of(context).pop(null);
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
    ).then((result) async {
      if (result != null) {
        setState(() {
          selectedIcon = result['icon'];
          _controllerTitle.text = result['title'];
          _controllerSpoken.text = result['spoken'];
          title = _controllerTitle.text;
          spoken = _controllerSpoken.text;
        });

        // Update database
        final dbHelper = DatabaseHelper();
        await dbHelper.updateButton(0, view, 5, 5, selectedIcon == null ? "" : listMapToString(serializeIcons([selectedIcon!])), title, spoken);
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
        crossAxisCount: 5,
        mainAxisSpacing: 7,
        crossAxisSpacing: 7,
        children: [
          StaggeredGridTile.count(
            crossAxisCellCount: 5,
            mainAxisCellCount: 5,
            child: GestureDetector(
              onLongPress: () => _handleLongPress(0, spoken),
              child: ChicletOutlinedAnimatedButton(
                buttonType: selectedIcon == null
                    ? ChicletButtonTypes.circle
                    : ChicletButtonTypes.roundedRectangle,
                onPressed: spoken.isNotEmpty ? () => _handlePress(0, spoken) : null,
                child: isLoading[0] == true
                    ? Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (selectedIcon != null) Icon(selectedIcon?.data),
                    if (title.isNotEmpty) Text(title),
                  ],
                ),
              ),
            ),
          ),
        ],
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
