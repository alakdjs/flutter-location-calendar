import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ColorPickerDialog {
  // Add saveUserColor function inside the class
  static void saveUserColor(String userId, Color newColor) {
    int colorValue = newColor.value;

    // Save to Firestore
    FirebaseFirestore.instance
        .collection('users') // Replace with your Firestore collection name
        .doc(userId)         // Replace with your user document ID
        .set({
      'favoriteColor': colorValue,
    }, SetOptions(merge: true))
        .then((_) {
      print('Color saved successfully!');
    }).catchError((error) {
      print('Failed to save color: $error');
    });
  }

  static void open(BuildContext context, String userId, Color currentColor, Function(Color) onSaveColor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Color selectedColor = currentColor;
        return AlertDialog(
          title: const Text("Pick a color"),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: currentColor,
              onColorChanged: (Color color) {
                selectedColor = color;
              },
              enableAlpha: false,
              showLabel: false,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Select"),
              onPressed: () {
                // Save the color for the specific user
                saveUserColor(userId, selectedColor);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
