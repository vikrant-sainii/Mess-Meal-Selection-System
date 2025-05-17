import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MealToggleControl extends StatefulWidget {
  const MealToggleControl({super.key});

  @override
  _MealToggleControlState createState() => _MealToggleControlState();
}

class _MealToggleControlState extends State<MealToggleControl> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<String> mealKeys = [
    'breakfast_toggle',
    'lunch_toggle',
    'dinner_toggle',
  ];
  final List<String> mealLabels = ['Breakfast', 'Lunch', 'Dinner'];

  final PageController _pageController = PageController(initialPage: 1000);
  int _selectedIndex = 1000;

  Map<String, bool> _toggleStates = {
    'breakfast_toggle': false,
    'lunch_toggle': false,
    'dinner_toggle': false,
  };

  @override
  void initState() {
    super.initState();
    _loadToggleStates();
  }

  Future<void> _loadToggleStates() async {
    final doc =
        await _firestore.collection('toggle_control').doc('meal_toggle').get();
    if (doc.exists) {
      setState(() {
        _toggleStates = {
          'breakfast_toggle': doc['breakfast_toggle'] ?? false,
          'lunch_toggle': doc['lunch_toggle'] ?? false,
          'dinner_toggle': doc['dinner_toggle'] ?? false,
        };
      });
    }
  }

  Future<void> _updateToggle(String key, bool value) async {
    if (value) {
      // If turning ON this key, turn OFF others
      final updatedStates = {
        for (var k in mealKeys) k: k == key ? true : false,
      };

      await _firestore
          .collection('toggle_control')
          .doc('meal_toggle')
          .update(updatedStates);

      setState(() {
        _toggleStates = Map<String, bool>.from(updatedStates);
      });

      final mealName = key.replaceAll('_toggle', '').toUpperCase();

      // WARNING DIALOG

      await showCriticalAlert(context, mealName);    } else {
      // If turning OFF the current toggle
      await _firestore.collection('toggle_control').doc('meal_toggle').update({
        key: false,
      });
      setState(() => _toggleStates[key] = false);
    }
  }

@override
Widget build(BuildContext context) {
  return Column(
    children: [
      Text(
        "Swipe to switch meal",
        style: TextStyle(
          color: Colors.grey ,// Light text for dark theme
          fontSize: 13,
        ),
      ),
      SizedBox(height: 10),
      SizedBox(
        height: 50,
        child: PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          onPageChanged: (index) {
            setState(() => _selectedIndex = index);
          },
          itemBuilder: (context, index) {
            final modIndex = index % 3;
            final label = mealLabels[modIndex];
            final key = mealKeys[modIndex];
            final isSelected = index == _selectedIndex;

            return SizedBox(
              height: 10,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (Theme.of(context).brightness == Brightness.dark
                            ? Colors.blueAccent // Bright blue for dark theme
                            : Colors.blue.shade100) // Lighter blue for light theme
                        : (Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey.shade800 // Darker grey for dark theme
                            : Colors.grey.shade200), // Lighter grey for light theme
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 18,
                          color: isSelected
                              ? (Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white // Bright text for dark theme
                                  : Colors.black) // Dark text for light theme
                              : (Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey.shade300 // Lighter text for dark theme
                                  : Colors.black54), // Lighter text for light theme
                        ),
                      ),
                      Switch(
                        value: _toggleStates[key] ?? false,
                        onChanged:
                            isSelected
                                ? (value) =>
                                    _confirmAndToggle(key, label, value)
                                : null,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ],
  );
}
  Future<void> _confirmAndToggle(String key, String label, bool value) async {
    final shouldToggle = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Confirm Action'),
            content: Text(
              'Are you sure you want to ${value ? "open" : "close"} portal for $label?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Yes'),
              ),
            ],
          ),
    );

    if (shouldToggle == true) {
      _updateToggle(key, value);
    }
  }




Future<void> showCriticalAlert(BuildContext context, String mealName) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // User must tap button to close
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.red, width: 0.5),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 40),
            SizedBox(width: 10),
            Text(
            'Critical Reset',
            style: TextStyle(
              color: Colors.red,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Required',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text.rich(
                TextSpan(children: [
                    TextSpan(text:'You activated the',
                      style: TextStyle(color: Colors.white),
                    ),
                    TextSpan(
                      text: ' $mealName',
                      style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold),
                    ),   
                    TextSpan(
                      text: '.',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Now you must reset balances',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 5),
              Text(
                'to deduct money from all users.',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 5),
              Text(
                'Ignoring this can cause',
                style: TextStyle(color: Colors.yellow),
              ),
              SizedBox(height: 5),
              Text(
                'major errors!',
                style: TextStyle(color: Colors.yellow),
              ),
              SizedBox(height: 15),
              Text(
                "DON'T FORGET TO RESET !!",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(
              'OK',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}


}
