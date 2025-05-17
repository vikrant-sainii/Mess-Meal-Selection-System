import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hostelmess1/approval_page.dart';
import 'package:hostelmess1/login_page.dart';
import 'meal_toggle_control.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final int greenPrice = 60;

  void _resetAllBalances() async {
    final clientCollection = FirebaseFirestore.instance.collection('client');

    try {
      final snapshot = await clientCollection.get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final currentBalance = data['balance'] ?? 0;
        final mealPreference = data['meal']?.toString().toLowerCase() ?? "";

        double deduction = 0;
        if (mealPreference == 'green') {
          deduction = 60;
        } else if (mealPreference == 'red') {
          deduction = 80;
        }

        final newBalance = (currentBalance - deduction).clamp(
          0,
          double.infinity,
        );

        // Update the balance and set meal preference to "green"
        await clientCollection.doc(doc.id).update({
          'balance': newBalance,
          'meal': 'green', // Setting default meal preference to green
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Balances deducted and meal preference set to green for all users',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to reset balances: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          automaticallyImplyLeading: false, 
          backgroundColor: Colors.blueGrey,
          title: const Text(
            "Admin Dashboard",
            style: TextStyle(color: Colors.white),
          ),
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
                                  MaterialPageRoute(builder: (context) => const LoginPage()),
                                  (route) => false
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
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('client').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
      
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    "No student data found",
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }
      
              final students = snapshot.data!.docs;
              int greenCount = 0;
      
              for (var doc in students) {
                final meal = doc['meal']?.toString().toLowerCase();
                if (meal == 'green') greenCount++;
              }
      
              int totalIncome = greenCount * greenPrice;
      
              return LayoutBuilder(
                builder: (context, constraints) {
              return Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(0),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildCounterCard(
                                      "Green (Yes)",
                                      greenCount,
                                      Colors.green,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildCounterCard(
                                      "Red (No)",
                                      students.length - greenCount,
                                      Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              _buildIncomeCard(totalIncome),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Student Meal Selections",
                                    style: TextStyle(color: Colors.white, fontSize: 18),
                                  ),
                                  TextButton.icon(
                                    onPressed: () async {
                                      final shouldProceed = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text("Confirm Reset"),
                                          content: const Text(
                                            "Are you sure you want to deduct ₹60 from every user with green meal preference?",
                                          ),
                                          actions: [
                                            TextButton(
                                              child: const Text("Cancel"),
                                              onPressed: () => Navigator.pop(context, false),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                              ),
                                              child: const Text("Yes, Reset", style: TextStyle(color: Colors.white)),
                                              onPressed: () => Navigator.pop(context, true),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (shouldProceed == true) {
                                        _resetAllBalances();
                                      }
                                    },
                                    icon: const Icon(Icons.refresh, color: Colors.redAccent),
                                    label: const Text(
                                      'Reset',
                                      style: TextStyle(color: Colors.redAccent),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              MealToggleControl(),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                        // Student List
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListView.builder(
                            shrinkWrap: true,
                            // physics: const NeverScrollableScrollPhysics(),
                            itemCount: students.length,
                            itemBuilder: (context, index) {
                              final student = students[index];
                              final name = student['name'] ?? "N/A";
                              final messId = student['idmess'] ?? "N/A";
                              final mobile = student['mobile'] ?? "N/A";
                              final meal = (student['meal'] ?? "no").toString().toLowerCase();
                          
                              return ListTile(
                                leading: const Icon(Icons.person, color: Colors.white),
                                title: Text(name, style: const TextStyle(color: Colors.white)),
                                subtitle: Text(
                                  "Mess ID: $messId\nMobile: $mobile\nBalance: ₹${student['balance'] ?? 0}",
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                trailing: Text(
                                  meal == "green" ? "Yes" : "No",
                                  style: TextStyle(
                                    color: meal == "green" ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
                },
              );            
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCounterCard(String title, int count, Color color) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "$count",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeCard(int income) {
    return SizedBox(
      height: 80, // Fixed height for both cards
      child: Row(
        children: [
          // Total Income Card (takes 60% width)
          Flexible(
            flex: 5, // 60% of space
            child: Card(
              color: Colors.blueGrey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Flexible(
                        child: Text(
                          "Total\nIncome:",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          "₹$income",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Approvals Card (takes 40% width)
          Flexible(
            flex: 5,
            child: Stack(
              children: [
                // Main Approval Card
                Card(
                  color: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    splashColor: Colors.purpleAccent.withOpacity(0.3),
                    highlightColor: Colors.white.withOpacity(0.1),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AdminApprovalScreen()),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                "Pending\nApprovals",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // 🔵 Permanent Green Dot
                Positioned(
                  top: 6,
                  right: 10,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.green, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),       
        ],
      ),
    );
  }
}
