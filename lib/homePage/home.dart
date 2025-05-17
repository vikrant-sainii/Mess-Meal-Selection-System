import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hostelmess1/login_page.dart';
import 'dart:ui';
import 'package:hostelmess1/custom_error.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? verifiedMessId;
  bool isToggleLoading = false;
  bool isGreenMeal = true;
  int countgreen = 1, countred = 0;
  int mealPrice = 60;
  bool isLoading = false; // Declare isLoading here
  String fetchedName = '';
  String fetchedPhone = '';
  bool isEditingName = false;
  bool isEditingPhone = false;
  bool isMessIdSelected = false;

  // Firebase reference
  final dbRef = FirebaseDatabase.instance.ref("users");

  // Controllers
  final messIdController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  Future<void> fetchInitialMealState() async {
    final messId = messIdController.text.trim();
    if (messId.isEmpty) return;

    setState(() => isLoading = true);

    final isVerified = await verifyPassword(context, messId);
    if (!isVerified) {
      setState(() => isLoading = false);
      return; // stop here if not verified
    }

    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('client')
              .doc(messIdController.text)
              .get();

      if (doc.exists) {
        final data = doc.data()!;

        if (doc.exists) {
          final data = doc.data()!;

          //for input fields
          setState(() {
            isMessIdSelected = true; // ✅ mess id selected and data fetched
            fetchedName = data['name']?.toString() ?? '';
            fetchedPhone = data['mobile']?.toString() ?? '';
            // other setState updates
          });
        }

        // Safe type conversion for meal
        final dynamic mealData = data['meal'];
        final bool isMealGreen =
            (mealData is String)
                ? mealData == 'green'
                : true; // default to green if invalid type
  
        // Safe type conversion for balance (if needed)
        final dynamic balanceData = data['balance'];
        final int balance =
            (balanceData is int)
                ? balanceData
                : (balanceData is double)
                ? balanceData.toInt()
                : 0;

        fetchedName = data['name']?.toString() ?? '';
        fetchedPhone = data['mobile']?.toString() ?? '';

        setState(() {
          isMessIdSelected = true;
          // Reset editing state when mess ID changes
          isEditingName = false;
          isEditingPhone = false;

          // Store external hint values
          fetchedName = data['name']?.toString() ?? '';
          fetchedPhone = data['mobile']?.toString() ?? '';

          // Clear controllers to show external hint
          nameController.text = '';
          phoneController.text = '';

          // Meal data
          isGreenMeal = isMealGreen;
          mealPrice = isMealGreen ? 60 : 0;
          countgreen = isMealGreen ? 1 : 0;
          countred = isMealGreen ? 0 : 1;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading data: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<bool> showTransparentConfirmationDialog(
    BuildContext context,
    bool value,
  ) async {
    return await showDialog<bool>(
          context: context,
          barrierColor: Colors.black.withOpacity(0.5), // Semi-transparent
          barrierDismissible: false,
          builder: (context) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 30,
                vertical: 24,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 5,
                    sigmaY: 5,
                  ), // Reduced blur
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(
                        0.3,
                      ), // Semi-transparent dark
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2), // Visible border
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.help_outline,
                          color: value ? Colors.greenAccent : Colors.redAccent,
                          size: 40,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Confirm Meal Change",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          value
                              ? "Are you sure you want to eat your next Meal?"
                              : "Are you sure you want to miss your next Meal?",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context, false);
                              },
                              child: Text(
                                "No",
                                style: TextStyle(color: Colors.grey[300]),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    value ? Colors.green : Colors.red,
                              ),
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text(
                                "Yes",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ) ??
        false;
  }

  void _toggleMeal(bool value) async {


    // Prevent double taps and ensure messId is not empty
    if (isToggleLoading || messIdController.text.isEmpty) {
      return;
    }

    // Show confirmation dialog
    final shouldToggle = await showTransparentConfirmationDialog(
      context,
      value,
    );

    if (!shouldToggle) {
      return;
    }
    final toggleControlDoc =
        await FirebaseFirestore.instance
            .collection('toggle_control')
            .doc('meal_toggle')
            .get();

    final toggleData = toggleControlDoc.data();
    if (toggleData == null || !toggleData.containsValue(true)) {
      // No meal toggle is ON (i.e., breakfast, lunch, dinner are all false)
      // Just update local state without touching Firebase
      setState(() {
        isGreenMeal = value;
        mealPrice = value ? 60 : 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Meal toggling is currently disabled by admin."),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      isToggleLoading = true;
      isGreenMeal = value;
      mealPrice = value ? 60 : 0;
    });

    try {
      // Get the document reference
      final docRef = FirebaseFirestore.instance
          .collection('client')
          .doc(messIdController.text);

      // Get the document
      final doc = await docRef.get();

      // Safe type conversion for balance
      dynamic balanceData = doc.data()?['balance'];
      int currentBalance =
          (balanceData is int)
              ? balanceData
              : (balanceData is double)
              ? balanceData.toInt()
              : 0;

      if (value && countgreen == 0) {
        // Switching to green meal (costs 60)
        final newBalance = currentBalance - 60;
        if (newBalance >= 0) {
          // Update both balance and meal type in a batch
          final batch = FirebaseFirestore.instance.batch();
          batch.update(docRef, {'balance': newBalance});
          batch.update(docRef, {'meal': 'green'});
          await batch.commit();

          setState(() {
            countgreen = 1;
            countred = 0;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[800]!.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Meal Updated!',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Green meal selected (₹60 deducted)',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(20),
              duration: Duration(seconds: 1),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Insufficient balance!')),
          );
          // Revert the toggle if balance is insufficient
          setState(() {
            isGreenMeal = !value;
            mealPrice = value ? 0 : 60;
          });
        }
      } else if (!value && countred == 0) {
        // Switching to red meal (refund 60)
        final newBalance = currentBalance + 60;

        // Update both balance and meal type in a batch
        final batch = FirebaseFirestore.instance.batch();
        batch.update(docRef, {'balance': newBalance});
        batch.update(docRef, {'meal': 'red'});
        await batch.commit();

        setState(() {
          countred = 1;
          countgreen = 0;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[800]!.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.currency_rupee, color: Colors.white, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Meal Credit!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '₹60 credited to your balance',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(20),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      // Revert changes on error
      setState(() {
        isGreenMeal = !value;
        mealPrice = value ? 0 : 60;
      });
    } finally {
      setState(() {
        isToggleLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              onPressed: () async {
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: Text("Confirm Logout"),
                        content: Text("Are you sure you want to log out?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text("Cancel"),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();

                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
                                (route) => false,
                              );
                            },
                            child: Text("Logout"),
                          ),
                        ],
                      ),
                );

                if (shouldLogout == true) {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                }
              },
              icon: Icon(
                // size: 4,
                Icons.logout,
                color: Colors.white,
              ),
            ),
          ),
        ],
        title: const Text('BH1 MESS', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'Welcome to BH1 Mess!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            // Text Fields
            _buildDropdownField("Select Mess ID", [
              "CS 19",
              "CHEM 20",
              "CS 21",
              "ECE 40",
              "IT 45",
            ]),

            //for name input textfield
            _buildInputFieldWithExtras(
              hint: "Name",
              controller: nameController,
              type: TextInputType.name,
              externalHintText: fetchedName,
              readOnly: !isEditingName,
              onTap: () {
                if (!isMessIdSelected) {
                  return; // ⛔ block tap if mess ID not selected
                }
                _confirmEdit('Name');
              },
            ),

            //for phone input textfield
            _buildInputFieldWithExtras(
              hint: "Phone",
              controller: phoneController,
              type: TextInputType.phone,
              externalHintText: fetchedPhone,
              readOnly: !isEditingPhone,
              onTap: () {
                if (!isMessIdSelected) {
                  return; // ⛔ block tap if mess ID not selected
                }
                _confirmEdit('phone');
              },
            ),

            const SizedBox(height: 10),

            // Bank Balance Card with StreamBuilder
            Card(
              color: Colors.grey[900],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: messIdController.text.trim() == verifiedMessId
                    ? StreamBuilder<DocumentSnapshot>(
                        stream: messIdController.text.isNotEmpty
                            ? FirebaseFirestore.instance
                                .collection('client')
                                .doc(messIdController.text)
                                .snapshots()
                            : null,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text(
                              'Error: ${snapshot.error}',
                              style: const TextStyle(color: Colors.white),
                            );
                          }

                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Column(
                              children: [
                                Text(
                                  'Mess Bank Balance',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white70,
                                  ),
                                ),
                                SizedBox(height: 10),
                                CircularProgressIndicator(),
                              ],
                            );
                          }

                          if (!snapshot.hasData || !snapshot.data!.exists) {
                            return Column(
                              children: [
                                const Text(
                                  'Mess Bank Balance',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '...',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.greenAccent,
                                  ),
                                ),
                              ],
                            );
                          }

                          final data = snapshot.data!.data() as Map<String, dynamic>;
                          final balance = data['balance'] ?? "...";

                          return Column(
                            children: [
                              const Text(
                                'Mess Bank Balance',
                                style: TextStyle(fontSize: 18, color: Colors.white70),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '₹${balance.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.greenAccent,
                                ),
                              ),
                            ],
                          );
                        },
                      )
                    : const Column(
                        children: [
                          Text(
                            'Mess Bank Balance',
                            style: TextStyle(fontSize: 18, color: Colors.white70),
                          ),
                          SizedBox(height: 10),
                          Text(
                            '₹*****', // use '...' or '*****' for security
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.greenAccent,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // Meal Toggle-select next meal

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Next Meal:',
                    style: TextStyle(fontSize: 18, color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isGreenMeal
                                ? Icons.eco
                                : Icons.local_fire_department,
                            color:
                                isGreenMeal ? Colors.green : Colors.redAccent,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            isGreenMeal ? 'Green Meal' : 'Red Meal',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Switch(
                            value: isGreenMeal,
                            onChanged: isToggleLoading
                              ? null
                              : (value) {
                                  setState(() {
                                    isGreenMeal = value;
                                    mealPrice = value ? 60 : 0;
                                  });
                                  if (messIdController.text.trim().isNotEmpty &&
                                      messIdController.text.trim() == verifiedMessId) {
                                    _toggleMeal(value);
                                  }
                                },
                            activeColor: Colors.green,
                            inactiveThumbColor: Colors.red,
                            inactiveTrackColor: Colors.redAccent.shade100,
                          ),
                          if (isToggleLoading)
                            Positioned.fill(
                              child: Container(
                                color: Colors.black.withOpacity(0.3),
                                child: Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Price: ₹$mealPrice',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      if (messIdController.text.isEmpty)
                        Text(
                          'Select Mess ID to save changes',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                Colors.orangeAccent, // More friendly than red
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // SUBMIT BUTTON && FIREBASE
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 149, 0, 255),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.black, width: 2),
                ),
              ),
              // In your submit button's onPressed:
              onPressed: () async {
                final bool isNameChanged =
                    isEditingName &&
                    nameController.text.trim() != fetchedName.trim();
                final bool isPhoneChanged =
                    isEditingPhone &&
                    phoneController.text.trim() != fetchedPhone.trim();

                if (!isNameChanged && !isPhoneChanged) {
                  showCustomSnackbar(context, 'No changes made to update');
                  return;
                }

                if ((isEditingName && nameController.text.trim().isEmpty) ||
                    (isEditingPhone && phoneController.text.trim().isEmpty)) {
                  showCustomSnackbar(context, 'Edited fields cannot be empty');
                  return;
                }

                setState(() => isLoading = true);

                try {
                  final messId = messIdController.text;

                  // Check if mess ID exists
                  final clientDoc =
                      await FirebaseFirestore.instance
                          .collection('client')
                          .doc(messId)
                          .get();

                  if (!clientDoc.exists) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Mess ID $messId not found')),
                    );
                    return;
                  }

                  final currentName = clientDoc['name'] ?? '';
                  final currentPhone = clientDoc['mobile'] ?? '';
                  final requestedName = nameController.text;
                  final requestedPhone = phoneController.text;

                  // Show confirmation dialog with current vs requested values
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text("Confirm Update Request"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Mess ID: $messId"),
                              const SizedBox(height: 12),
                              Text(
                                "Name:\n   Current: $currentName\n   Requested: $requestedName",
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Phone:\n   Current: $currentPhone\n   Requested: $requestedPhone",
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("Submit"),
                            ),
                          ],
                        ),
                  );

                  if (confirm != true) return;

                  // Submit approval request
                  await FirebaseFirestore.instance
                      .collection('admin_approval')
                      .doc(messId)
                      .set({
                        'messId': messId,
                        'currentName': currentName,
                        'requestedName': requestedName,
                        'currentPhone': currentPhone,
                        'requestedPhone': requestedPhone,
                        'status': 'pending',
                        'timestamp': FieldValue.serverTimestamp(),
                        'processedAt': null,
                        'processedBy': null,
                      });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Update request submitted for approval'),
                    ),
                  );

                  nameController.clear();
                  phoneController.clear();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                } finally {
                  setState(() => isLoading = false);
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  height: 20,
                  width: 120,
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 300),
                      transitionBuilder: (
                        Widget child,
                        Animation<double> animation,
                      ) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child:
                          isLoading
                              ? SizedBox(
                                key: ValueKey('loading'),
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : Text(
                                'UPDATE',
                                key: ValueKey('text'),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                ),
                              ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField(String hint, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(15),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: messIdController.text.isEmpty ? null : messIdController.text,
            hint: Text(hint, style: const TextStyle(color: Colors.white54)),
            dropdownColor: Colors.grey[900],
            style: const TextStyle(color: Colors.white, fontSize: 16),
            iconEnabledColor: Colors.white54,
            isExpanded: true,
            onChanged: (String? newValue) {
              setState(() {
                messIdController.text = newValue!;
              });
              fetchInitialMealState(); // Add this line
            },
            items:
                items.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }

  // Use this internally for full custom control
  Widget _buildInputFieldWithExtras({
    required String hint,
    required TextEditingController controller,
    required TextInputType type,
    required String externalHintText,
    required bool readOnly,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: type,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white10,
          hintText:
              controller.text.isNotEmpty
                  ? controller.text
                  : (externalHintText.isNotEmpty ? externalHintText : hint),
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon:
              hint == "Phone"
                  ? const Icon(Icons.phone, color: Colors.white54)
                  : const Icon(Icons.person, color: Colors.white54),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.deepPurpleAccent),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmEdit(String field) async {
    final shouldEdit = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Edit $field?'),
            content: Text('Are you sure you want to edit your $field?'),
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

    if (shouldEdit == true) {
      setState(() {
        if (field == 'Name') {
          isEditingName = true;
          nameController.text = fetchedName;
        } else {
          isEditingPhone = true;
          phoneController.text = fetchedPhone;
        }
      });
    }
  }


Future<bool> verifyPassword(BuildContext context, String messId) async {
  try {
    final doc = await FirebaseFirestore.instance
        .collection('client')
        .doc(messId)
        .get();

    if (!doc.exists || !doc.data()!.containsKey('password')) {
      return true; // No password protection
    }

    final storedPassword = doc.data()!['password'];

    String? enteredPassword = await showDialog<String>(
      context: context,
      builder: (context) {
        String tempPassword = '';
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.grey[850]!, Colors.grey[900]!],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock_outline,
                      size: 48, color: Colors.blueAccent),
                  SizedBox(height: 16),
                  Text(
                    'Secure Access',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white70,
                      letterSpacing: 1.1,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Enter password for $messId',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  SizedBox(height: 24),
                  TextField(
                    obscureText: true,
                    onChanged: (val) => tempPassword = val,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[850],
                      hintText: 'Enter password',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      suffixIcon:
                          Icon(Icons.key, color: Colors.blueAccent.shade100),
                    ),
                  ),
                  SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey[400],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text('CANCEL'),
                      ),
                      SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          elevation: 4,
                        ),
                        onPressed: () =>
                            Navigator.pop(context, tempPassword),
                        child: Text('VERIFY'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (enteredPassword == storedPassword) {
      setState(() {
        verifiedMessId = messIdController.text.trim();
      });
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Incorrect password'),
          backgroundColor: Colors.red[800],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 6,
        ),
      );
      return false;
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error verifying password'),
        backgroundColor: Colors.red[800],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 6,
      ),
    );
    return false;
  }
}

}
