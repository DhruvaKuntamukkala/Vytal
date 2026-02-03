import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:vytal/theme_notifier.dart';
import '../helpers/nutrition_service.dart';
import '../helpers/profile_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:carousel_slider_plus/carousel_slider_plus.dart' as cs;

final List<String> foodSuggestions = [
  // Fruits
  'Apple',
  'Banana',
  'Orange',
  'Mango',
  'Pineapple',
  'Grapes',
  'Watermelon',
  'Papaya',
  'Kiwi',
  'Blueberries',
  // Vegetables
  'Carrot',
  'Spinach',
  'Broccoli',
  'Cauliflower',
  'Tomato',
  'Cucumber',
  'Lettuce',
  'Bell pepper',
  'Onion',
  'Potato',
  // Proteins
  'Chicken breast',
  'Eggs',
  'Boiled egg',
  'Paneer',
  'Tofu',
  'Salmon',
  'Tuna',
  'Mutton curry',
  'Pork chop',
  'Shrimp',
  // Grains & Rice
  'White rice',
  'Brown rice',
  'Basmati rice',
  'Quinoa',
  'Oats',
  'Barley',
  'Wheat roti',
  'Whole wheat bread',
  'Multigrain bread',
  'Cornflakes',
  // Dairy
  'Milk',
  'Yogurt',
  'Cheese',
  'Butter',
  'Ghee',
  'Buttermilk',
  'Cream',
  'Greek yogurt',
  'Curd rice',
  'Lassi',
  // Indian Dishes
  'Dal',
  'Rajma',
  'Chole',
  'Biryani',
  'Pulao',
  'Upma',
  'Poha',
  'Dosa',
  'Idli',
  'Sambar',
  // Snacks
  'Sandwich',
  'Veg puff',
  'Samosa',
  'Pakora',
  'French fries',
  'Nachos',
  'Popcorn',
  'Sev puri',
  'Bhel puri',
  'Masala peanuts',
  // Western Dishes
  'Pasta',
  'Pizza',
  'Burger',
  'Hotdog',
  'Pancakes',
  'Waffles',
  'Fried rice',
  'Noodles',
  'Grilled chicken',
  'Steak',
  // Nuts & Seeds
  'Almonds',
  'Walnuts',
  'Cashews',
  'Peanuts',
  'Pistachios',
  'Chia seeds',
  'Flax seeds',
  'Sunflower seeds',
  'Pumpkin seeds',
  'Trail mix',
  // Desserts
  'Ice cream',
  'Chocolate',
  'Gulab jamun',
  'Jalebi',
  'Cake',
  'Brownie',
  'Kheer',
  'Rasgulla',
  'Laddu',
  'Custard',
];

List<String> getSuggestions(String query) {
  return foodSuggestions
      .where((item) => item.toLowerCase().contains(query.toLowerCase()))
      .toList();
}

class HomePage extends StatefulWidget {
  final String name;
  final String email;
  const HomePage({super.key, required this.name, required this.email});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = '';
  String userEmail = '';
  String? nextMedicine;
  String? nextTime;
  double? _bmi;
  double? _requiredCalories;

  double _idealMinBMI = 18.5;
  double _idealMaxBMI = 24.9;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  List<Map<String, dynamic>> mealSections = [
    _createSection('Breakfast'),
    _createSection('Lunch'),
    _createSection('Dinner'),
  ];

  static Map<String, dynamic> _createSection(String title) {
    return {
      'id': const Uuid().v4(),
      'title': title,
      'items': [],
      'expanded': true,
      'showInputs': false,
      'controller': TextEditingController(),
      'quantityController': TextEditingController(),
    };
  }

  @override
  void initState() {
    super.initState();
    userName = widget.name;
    userEmail = widget.email;
    _fetchBMI();
    _loadNextReminder();
    _loadCaloriesAndOtherData();
  }

  void _fetchBMI() async {
    final profile = await ProfileService.getProfile();

    final heightStr = profile['height'];
    final weightStr = profile['weight'];
    final heightUnit = profile['heightUnit'] ?? 'cm';
    final weightUnit = profile['weightUnit'] ?? 'kg';

    if (heightStr != null &&
        weightStr != null &&
        heightStr.isNotEmpty &&
        weightStr.isNotEmpty) {
      double height = double.tryParse(heightStr) ?? 0;
      double weight = double.tryParse(weightStr) ?? 0;

      if (heightUnit == 'ft') height = height * 30.48;
      if (weightUnit == 'lbs') weight = weight * 0.453592;

      if (height > 0 && weight > 0) {
        final heightM = height / 100;
        setState(() {
          _bmi = weight / (heightM * heightM);
        });
      }
    } else {
      setState(() {
        _bmi = null;
      });
    }
  }

  Future<void> _loadNextReminder() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nextMedicine = prefs.getString('nextMedicine') ?? 'No medicine set';
      nextTime = prefs.getString('nextTime') ?? '';
    });
  }

  Future<void> _loadCaloriesAndOtherData() async {
    _requiredCalories = await ProfileService.calculateRequiredCalories();
    setState(() {});
  }

  void _addMealSection() {
    setState(() {
      mealSections.insert(
        0,
        _createSection('Custom Meal ${mealSections.length - 2}'),
      );
    });
  }

  Future<void> _handleAddFood(Map<String, dynamic> section) async {
    final controller = section['controller'] as TextEditingController;
    final qtyController =
        section['quantityController'] as TextEditingController;
    final items = section['items'] as List;

    final food = controller.text.trim();
    final qty = qtyController.text.trim();
    if (food.isEmpty || qty.isEmpty) return;

    final data = await NutritionService.fetchNutrition("$qty $food");
    if (data != null) {
      setState(() {
        items.add({
          'name': data['name'] ?? food,
          'protein': data['protein_g'] ?? 0,
          'carbohydrates': data['carbohydrates_total_g'] ?? 0,
          'fat': data['fat_total_g'] ?? 0,
          'calories': data['calories'] ?? 0,
        });
        controller.clear();
        qtyController.clear();
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Couldn't fetch food data")));
    }
  }

  Color get _accent => Colors.tealAccent[700]!;

  Widget _buildSectionHeader(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 8, top: 18),
      child: Row(
        children: [
          Icon(icon, color: _accent, size: 24),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: _accent,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsRow() {
    return Column(
      children: [
        // 🔹 Quick Actions Card
        Card(
          color: Colors.grey[900],
          elevation: 8,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickAction(
                  Icons.add_alert,
                  "Reminders",
                  () => Navigator.pushNamed(context, '/reminders'),
                ),
                _buildQuickAction(
                  Icons.search,
                  "Medicine Info",
                  () => Navigator.pushNamed(context, '/medicine_info'),
                ),
                _buildQuickAction(
                  Icons.calendar_today,
                  "Calendar",
                  () => Navigator.pushNamed(context, '/calendar'),
                ),
                _buildQuickAction(
                  Icons.food_bank,
                  "Diet",
                  () => Navigator.pushNamed(context, '/dietplan'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAction(IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        Ink(
          decoration: ShapeDecoration(
            color: _accent,
            shape: const CircleBorder(),
            shadows: [
              BoxShadow(
                color: Colors.tealAccent.withOpacity(0.25),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(icon),
            color: Colors.black,
            onPressed: onTap,
            iconSize: 34,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildQuickTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onPressed,
  }) {
    return Card(
      color: Colors.grey[900],
      elevation: 8,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        leading: Icon(icon, color: _accent, size: 32),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70)),
        trailing: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: _accent,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text("View All"),
        ),
      ),
    );
  }

  void _editSectionTitle(Map<String, dynamic> section) {
    final controller = TextEditingController(text: section['title']);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Section Title"),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              setState(() => section['title'] = controller.text.trim());
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Widget _buildBMIMeter() {
    final bmi = _bmi;
    final width = MediaQuery.of(context).size.width - 60;
    final minBMI = _idealMinBMI;
    final maxBMI = _idealMaxBMI;
    final minBar = 10.0;
    final maxBar = 40.0;

    if (bmi == null) {
      return Card(
        color: Colors.grey[900],
        elevation: 10,
        margin: const EdgeInsets.symmetric(vertical: 18, horizontal: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.monitor_heart,
                    color: Colors.tealAccent,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "BMI Overview",
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  "BMI unavailable, please update your profile",
                  style: TextStyle(
                    color: Colors.redAccent[100],
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/profile',
                      arguments: {'name': userName, 'email': userEmail},
                    ).then((_) {
                      _fetchBMI();
                    });
                  },
                  icon: const Icon(Icons.edit, color: Colors.black),
                  label: const Text(
                    "Update Profile",
                    style: TextStyle(color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.tealAccent[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final indicatorPos =
        ((bmi - minBar) / (maxBar - minBar)).clamp(0.0, 1.0) * width;
    final idealMinPos =
        ((minBMI - minBar) / (maxBar - minBar)).clamp(0.0, 1.0) * width;
    final idealMaxPos =
        ((maxBMI - minBar) / (maxBar - minBar)).clamp(0.0, 1.0) * width;

    String bmiLabel() {
      if (bmi < minBMI) return "Underweight";
      if (bmi > maxBMI) return "Overweight";
      return "Normal";
    }

    Color bmiColor() {
      if (bmi < minBMI) return Colors.blueAccent;
      if (bmi > maxBMI) return Colors.redAccent;
      return Colors.greenAccent;
    }

    return Card(
      color: Colors.grey[900],
      elevation: 10,
      margin: const EdgeInsets.symmetric(vertical: 18, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.monitor_heart,
                  color: Colors.tealAccent,
                  size: 28,
                ),
                const SizedBox(width: 10),
                const Text(
                  "BMI Overview",
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 1),
            SizedBox(
              height: 100,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.topLeft,
                children: [
                  // Indicator above the bar
                  Positioned(
                    left: indicatorPos - 12,
                    top: 0,
                    child: Column(
                      children: [
                        Icon(
                          Icons.arrow_drop_down,
                          color: bmiColor(),
                          size: 32,
                        ),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: bmiColor(),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              bmi > 0 ? bmi.toStringAsFixed(1) : "-",
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Gradient Bar
                  Positioned(
                    top: 40,
                    child: Container(
                      height: 18,
                      width: width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [
                            Colors.blueAccent,
                            Colors.greenAccent,
                            Colors.redAccent,
                          ],
                          stops: [0.0, 0.6, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Ideal range overlay
                  Positioned(
                    left: idealMinPos,
                    top: 40,
                    child: Container(
                      width: idealMaxPos - idealMinPos,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  // Labels below the bar, spaced evenly
                  Positioned(
                    top: 62,
                    left: 0,
                    child: SizedBox(
                      width: width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            "Underweight",
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            "Normal",
                            style: TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            "Overweight",
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 1),
            Row(
              children: [
                Text(
                  "Status: ",
                  style: TextStyle(
                    color: Colors.white70,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  bmiLabel(),
                  style: TextStyle(
                    color: bmiColor(),
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  "Ideal: $_idealMinBMI - $_idealMaxBMI",
                  style: const TextStyle(color: Colors.white38, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealSection(Map<String, dynamic> section, int index) {
    final items = section['items'] as List;
    final controller = section['controller'] as TextEditingController;
    final quantityController =
        section['quantityController'] as TextEditingController;

    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;
    double totalCalories = 0;

    for (var item in items) {
      totalProtein += item['protein'];
      totalCarbs += item['carbohydrates'];
      totalFat += item['fat'];
      totalCalories += item['calories'];
    }

    bool isDefault = [
      'Breakfast',
      'Lunch',
      'Dinner',
    ].contains(section['title']);

    return Card(
      key: ValueKey(section['id']),
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Row(
              children: [
                Icon(Icons.restaurant, color: Colors.tealAccent[700], size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    section['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                // Show edit icon only for custom meals
                if (!isDefault)
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.tealAccent),
                    tooltip: "Edit Section Name",
                    onPressed: () async {
                      final controller = TextEditingController(
                        text: section['title'],
                      );
                      final result = await showDialog<String>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Edit Section Name"),
                          content: TextField(
                            controller: controller,
                            autofocus: true,
                            decoration: const InputDecoration(
                              labelText: "Section Name",
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(
                                context,
                                controller.text.trim(),
                              ),
                              child: const Text("Save"),
                            ),
                          ],
                        ),
                      );
                      if (result != null && result.isNotEmpty) {
                        setState(() {
                          section['title'] = result;
                        });
                      }
                    },
                  ),
                // Delete button for all sections
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  tooltip: "Delete Section",
                  onPressed: () {
                    setState(() {
                      mealSections.removeAt(index);
                    });
                  },
                ),
                IconButton(
                  icon: Icon(
                    section['showInputs'] ? Icons.close : Icons.add,
                    color: Colors.tealAccent[700],
                  ),
                  tooltip: section['showInputs'] ? "Hide Inputs" : "Add Item",
                  onPressed: () {
                    setState(() {
                      section['showInputs'] = !section['showInputs'];
                    });
                  },
                ),
              ],
            ),
            const Divider(color: Colors.white24, thickness: 1),
            // Food items list
            if (items.isNotEmpty)
              ...items.map(
                (item) => Card(
                  color: Colors.grey[850],
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      item['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        "Protein: ${item['protein']}g   |   Carbs: ${item['carbohydrates']}g\nFat: ${item['fat']}g   |   Calories: ${item['calories']}",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => setState(() => items.remove(item)),
                    ),
                  ),
                ),
              ),
            // Add Item Inputs
            if (section['showInputs']) ...[
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    // Food name input with suggestions
                    TypeAheadField(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: controller,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "Food item",
                          labelStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.grey[800],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      suggestionsCallback: getSuggestions,
                      itemBuilder: (context, String suggestion) {
                        return ListTile(title: Text(suggestion));
                      },
                      onSuggestionSelected: (suggestion) {
                        controller.text = suggestion;
                      },
                    ),
                    const SizedBox(height: 10),
                    // Quantity input
                    TextField(
                      controller: quantityController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Quantity (e.g. 100 grams)",
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.grey[800],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _handleAddFood(section),
                        icon: const Icon(Icons.add, color: Colors.black),
                        label: const Text(
                          "Add Food",
                          style: TextStyle(color: Colors.black),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.tealAccent[700],
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            // Nutrition summary
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.tealAccent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "Total:  Protein: ${totalProtein.toStringAsFixed(1)}g   |   Carbs: ${totalCarbs.toStringAsFixed(1)}g\nFat: ${totalFat.toStringAsFixed(1)}g   |   Calories: ${totalCalories.toStringAsFixed(1)}",
                style: const TextStyle(
                  color: Colors.white70,
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _accent,
        elevation: 0,
        title: Row(
          children: [
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Welcome, $userName',
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  letterSpacing: 0,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.black),
            tooltip: "Profile",
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/profile',
                arguments: {'name': userName, 'email': userEmail},
              ).then((_) {
                _fetchBMI();
              });
            },
          ),
          IconButton(
            tooltip: "Toggle Theme",
            icon: Icon(
              Provider.of<ThemeNotifier>(context).isDarkMode
                  ? Icons.light_mode
                  : Icons.dark_mode,
              color: Colors.black,
            ),
            onPressed: () {
              Provider.of<ThemeNotifier>(context, listen: false).toggleTheme();
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _buildCarousel(),
            const SizedBox(height: 10),
            _buildBMIMeter(),
            _buildSectionHeader(Icons.flash_on, "Quick Actions"),
            _buildQuickActionsRow(),
            _buildSectionHeader(Icons.access_time, "Next Medicine"),
            _buildQuickTile(
              icon: Icons.access_time,
              title: "Next Medicine: ${nextMedicine ?? 'Loading...'}",
              subtitle: nextTime != null && nextTime!.isNotEmpty
                  ? "Time: $nextTime"
                  : '',
              onPressed: () async {
                await Navigator.pushNamed(context, '/reminders');
                _loadNextReminder();
              },
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12,
              ),
              child: Row(
                children: [
                  Row(
                    children: const [
                      Icon(Icons.restaurant_menu, color: Colors.teal),
                      SizedBox(width: 8),
                      Text(
                        "Your Meals",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          color: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _addMealSection,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text(
                      "Add Section",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final item = mealSections.removeAt(oldIndex);
                  mealSections.insert(newIndex, item);
                });
              },
              children: [
                for (int i = 0; i < mealSections.length; i++)
                  _buildMealSection(mealSections[i], i),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

Widget _buildCarousel() {
  final List<String> imageUrls = [
    'assets/medicines.jpg',
    'assets/jogging.jpeg',
    'assets/dietpic.jpg',
    'assets/clock.jpg',
  ];

  return cs.CarouselSlider(
    options: cs.CarouselOptions(
      height: 200,
      autoPlay: true,
      enlargeCenterPage: true,
      viewportFraction: 0.85,
      enableInfiniteScroll: true,
    ),
    items: imageUrls.map((url) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(url, fit: BoxFit.cover, width: double.infinity),
      );
    }).toList()
  );
}
