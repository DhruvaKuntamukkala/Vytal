import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  // Save all user profile data
  static Future<void> saveProfile({
    required String phone,
    required String height,
    required String weight,
    required String gender,
    required String heightUnit,
    required String weightUnit,
    required String age,
    required String goal, // New: Maintain / Gain Weight / Lose Weight
    String? imagePath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('phone', phone);
    await prefs.setString('height', height);
    await prefs.setString('weight', weight);
    await prefs.setString('gender', gender);
    await prefs.setString('heightUnit', heightUnit);
    await prefs.setString('weightUnit', weightUnit);
    await prefs.setString('age', age);
    await prefs.setString('goal', goal);
    if (imagePath != null) {
      await prefs.setString('profileImage', imagePath);
    }
  }

  // Retrieve profile values
  static Future<Map<String, String>> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'phone': prefs.getString('phone') ?? '',
      'height': prefs.getString('height') ?? '',
      'weight': prefs.getString('weight') ?? '',
      'gender': prefs.getString('gender') ?? '',
      'heightUnit': prefs.getString('heightUnit') ?? '',
      'weightUnit': prefs.getString('weightUnit') ?? '',
      'age': prefs.getString('age') ?? '',
      'goal': prefs.getString('goal') ?? '',
      'profileImage': prefs.getString('profileImage') ?? '',
    };
  }

  // Clear profile data
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Calculate required daily calories based on profile data
  static Future<double?> calculateRequiredCalories() async {
    final prefs = await SharedPreferences.getInstance();

    final gender = prefs.getString('gender') ?? 'Male';
    final age = int.tryParse(prefs.getString('age') ?? '') ?? 0;
    final height = double.tryParse(prefs.getString('height') ?? '') ?? 0.0;
    final weight = double.tryParse(prefs.getString('weight') ?? '') ?? 0.0;
    final heightUnit = prefs.getString('heightUnit') ?? 'cm';
    final weightUnit = prefs.getString('weightUnit') ?? 'kg';
    final goal = prefs.getString('goal') ?? 'Maintain';

    // Convert to metric
    double h = heightUnit == 'ft' ? height * 30.48 : height;
    double w = weightUnit == 'lbs' ? weight * 0.453592 : weight;

    // Calculate BMR using Mifflin-St Jeor formula
    double bmr;
    if (gender == 'Male') {
      bmr = 10 * w + 6.25 * h - 5 * age + 5;
    } else {
      bmr = 10 * w + 6.25 * h - 5 * age - 161;
    }

    // Activity level can be added later (currently sedentary: 1.2)
    double tdee = bmr * 1.2;

    switch (goal) {
      case 'Lose Weight':
        tdee -= 500; // deficit
        break;
      case 'Gain Weight':
        tdee += 300; // surplus
        break;
      case 'Maintain':
      default:
        break;
    }

    return tdee;
  }
}
