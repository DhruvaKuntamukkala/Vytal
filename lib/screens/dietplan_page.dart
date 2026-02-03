import 'package:flutter/material.dart';
import 'dart:math';

class DietPlanPage extends StatefulWidget {
  const DietPlanPage({Key? key}) : super(key: key);

  @override
  _DietPlanPageState createState() => _DietPlanPageState();
}

class _DietPlanPageState extends State<DietPlanPage> {
  bool loading = false;
  bool missingProfile = false;

  List<Map<String, dynamic>> meals = [
    {
      "title": "Breakfast",
      "items": [
        {"name": "Oats", "calories": 150.0},
        {"name": "Milk", "calories": 100.0},
      ],
    },
    {
      "title": "Lunch",
      "items": [
        {"name": "Rice", "calories": 200.0},
        {"name": "Dal", "calories": 150.0},
      ],
    },
    {
      "title": "Dinner",
      "items": [
        {"name": "Chapati", "calories": 120.0},
        {"name": "Paneer", "calories": 180.0},
      ],
    },
  ];

  final profileData = {
    "goal": "Maintain",
    "age": 21,
    "gender": "Female",
    "height": 165,
    "weight": 55,
    "calories": 1800.0,
  };

  void _addFood(int index) {
    setState(() {
      meals[index]["items"].add({
        "name": "New Food ${Random().nextInt(100)}",
        "calories": Random().nextDouble() * 200,
      });
    });
  }

  void _revertPlan() {
    // Example reset logic
    setState(() {
      meals.removeRange(1, meals.length); // resets to just breakfast
    });
  }

  double _total(String type) {
    double total = 0;
    for (var meal in meals) {
      for (var item in meal["items"]) {
        if (type == "calories") {
          total += item["calories"];
        } else if (type == "protein") {
          total += 5; // placeholder logic
        } else if (type == "carbs") {
          total += 10; // placeholder logic
        } else if (type == "fat") {
          total += 3; // placeholder logic
        }
      }
    }
    return total;
  }

  TextStyle _infoStyle() => TextStyle(
    fontFamily: 'Poppins',
    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
    fontSize: 13,
  );

  Widget _buildProfileCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.tealAccent, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            profileData['goal'].toString().toUpperCase(),
            style: const TextStyle(
              color: Colors.tealAccent,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "${(profileData['calories'] as num?)?.toStringAsFixed(0) ?? '0'} kcal/day",

            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 16,
            runSpacing: 4,
            children: [
              Text("Age: ${profileData['age']}", style: _infoStyle()),
              Text("Gender: ${profileData['gender']}", style: _infoStyle()),
              Text("Height: ${profileData['height']} cm", style: _infoStyle()),
              Text("Weight: ${profileData['weight']} kg", style: _infoStyle()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMealCard(Map<String, dynamic> meal, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.tealAccent, width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.restaurant, color: Colors.tealAccent),
              const SizedBox(width: 8),
              Text(
                meal["title"],
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(meal["items"].length, (i) {
            final item = meal["items"][i];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item["name"] ?? "Food", style: _infoStyle()),
                    Text(
                      "${item["calories"]?.toStringAsFixed(0) ?? 0} kcal",
                      style: _infoStyle(),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 60),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.tealAccent, width: 1),
      ),
      child: Column(
        children: [
          Text(
            "Total Nutrition",
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontFamily: 'Poppins',
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "${_total("calories").toStringAsFixed(0)} kcal",
            style: const TextStyle(
              fontSize: 20,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              color: Colors.tealAccent,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMacro("Protein", _total("protein")),
              _buildMacro("Carbs", _total("carbs")),
              _buildMacro("Fats", _total("fat")),
            ],
          ),
          const SizedBox(height: 16),
         
        ],
      ),
    );
  }

  Widget _buildMacro(String label, double value) {
    return Column(
      children: [
        Text(label, style: _infoStyle()),
        const SizedBox(height: 4),
        Text(
          "${value.toStringAsFixed(1)} g",
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Poppins',
            color: Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.tealAccent[700],
        foregroundColor: Colors.black,
        title: const Text("Diet Plan", style: TextStyle(fontFamily: 'Poppins')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: missingProfile
          ? const Center(child: Text("Profile data missing"))
          : loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.tealAccent),
            )
          : Column(
              children: [
                const SizedBox(height: 12),
                _buildProfileCard(),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: meals.length,
                    itemBuilder: (context, index) =>
                        _buildMealCard(meals[index], index),
                  ),
                ),
                const SizedBox(height: 10),
                _buildSummaryCard(),
                const SizedBox(height: 16),
              ],
            ),
    );
  }
}
