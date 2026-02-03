import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/profile_service.dart';

class ProfilePage extends StatefulWidget {
  final String name;
  final String email;

  ProfilePage({Key? key, required this.name, required this.email})
    : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;
  Uint8List? _profileImageBytes;
  File? _profileImageFile;
  String _goal = 'Maintain';

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  String _heightUnit = 'cm';
  String _weightUnit = 'kg';
  String _gender = 'Male';

  Color get _cardColor => Colors.grey[900]!;
  Color get _accent => Colors.tealAccent[700]!;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _phoneController.text = prefs.getString('phone') ?? '';
      _heightController.text = prefs.getString('height') ?? '';
      _weightController.text = prefs.getString('weight') ?? '';
      _ageController.text = prefs.getString('age') ?? '';
      _goal = prefs.getString('goal') ?? 'Maintain';

      _heightUnit = prefs.getString('heightUnit') ?? 'cm';
      _weightUnit = prefs.getString('weightUnit') ?? 'kg';
      _gender = prefs.getString('gender') ?? 'Male';
    });
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera, color: Colors.teal),
              title: const Text(
                'Take a photo',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () async {
                Navigator.pop(context);
                final picker = ImagePicker();
                final picked = await picker.pickImage(
                  source: ImageSource.camera,
                );
                if (picked != null) {
                  setState(() {
                    _profileImageFile = File(picked.path);
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.teal),
              title: const Text(
                'Choose from gallery',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () async {
                Navigator.pop(context);
                final picker = ImagePicker();
                final picked = await picker.pickImage(
                  source: ImageSource.gallery,
                );
                if (picked != null) {
                  if (kIsWeb) {
                    final bytes = await picked.readAsBytes();
                    setState(() {
                      _profileImageBytes = bytes;
                    });
                  } else {
                    setState(() {
                      _profileImageFile = File(picked.path);
                    });
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('phone', _phoneController.text);
    await prefs.setString('height', _heightController.text);
    await prefs.setString('weight', _weightController.text);
    await prefs.setString('age', _ageController.text);
    await prefs.setString('heightUnit', _heightUnit);
    await prefs.setString('weightUnit', _weightUnit);
    await prefs.setString('gender', _gender);
    await prefs.setString('goal', _goal);

    setState(() {
      _isEditing = false;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profile saved!')));
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    () => Navigator.pop(context, '/login');
  }

  Widget _buildEditableField(
    String label,
    TextEditingController controller,
    TextInputType keyboardType,
    bool isEditing, {
    IconData? icon,
    String? hint,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: !isEditing,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
      decoration: InputDecoration(
        prefixIcon: icon != null ? Icon(icon, color: _accent) : null,
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(
          color: Colors.white70,
          fontFamily: 'Poppins',
        ),
        filled: true,
        fillColor: Colors.white10,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: _accent, width: 2),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        suffixIcon: isEditing
            ? Tooltip(
                message: 'Edit $label',
                child: const Icon(Icons.edit, color: Colors.tealAccent),
              )
            : null,
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required bool enabled,
    IconData? icon,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        prefixIcon: icon != null ? Icon(icon, color: _accent) : null,
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.white70,
          fontFamily: 'Poppins',
        ),
        filled: true,
        fillColor: Colors.white10,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: _accent, width: 2),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items
              .map(
                (item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    item.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: enabled ? onChanged : null,
          dropdownColor: Colors.grey[900],
          iconEnabledColor: _accent,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider<Object>? imageWidget = kIsWeb
        ? (_profileImageBytes != null ? MemoryImage(_profileImageBytes!) : null)
        : (_profileImageFile != null ? FileImage(_profileImageFile!) : null);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: _accent,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text('Profile', style: TextStyle(fontFamily: 'Poppins')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.tealAccent.withOpacity(0.3),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 62,
                          backgroundColor: _accent,
                          backgroundImage: imageWidget,
                          child: imageWidget == null
                              ? const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.black,
                                )
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(6),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: Colors.teal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              widget.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.email,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Poppins',
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 28),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Personal Info",
                style: TextStyle(
                  color: _accent,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 0,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              color: _cardColor,
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 20,
                ),
                child: Column(
                  children: [
                    _buildEditableField(
                      "Phone Number",
                      _phoneController,
                      TextInputType.phone,
                      _isEditing,
                      icon: Icons.phone,
                      hint: "Enter your phone",
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown<String>(
                      label: 'Gender',
                      value: _gender,
                      items: const ['Male', 'Female', 'Other'],
                      onChanged: (val) =>
                          setState(() => _gender = val ?? 'Male'),
                      enabled: _isEditing,
                      icon: Icons.person,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            // --- Section: Body Metrics ---
            // --- Section: Body Metrics ---
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Body Metrics",
                style: TextStyle(
                  color: _accent,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 0,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              color: _cardColor,
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 20,
                ),
                child: Column(
                  children: [
                    _buildEditableField(
                      "Height ($_heightUnit)",
                      _heightController,
                      TextInputType.number,
                      _isEditing,
                      icon: Icons.height,
                      hint: "Enter your height",
                    ),
                    const SizedBox(height: 16),
                    _buildEditableField(
                      "Weight ($_weightUnit)",
                      _weightController,
                      TextInputType.number,
                      _isEditing,
                      icon: Icons.monitor_weight,
                      hint: "Enter your weight",
                    ),
                    const SizedBox(height: 16),
                    _buildEditableField(
                      "Age (years)",
                      _ageController,
                      TextInputType.number,
                      _isEditing,
                      hint: "Enter your age",
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown<String>(
                      label: 'Goal',
                      value: _goal,
                      items: const ['Maintain', 'Lose Weight', 'Gain Weight'],
                      onChanged: (val) =>
                          setState(() => _goal = val ?? 'Maintain'),
                      enabled: _isEditing,
                      icon: Icons.flag,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdown<String>(
                            label: 'Height Unit',
                            value: _heightUnit,
                            items: const ['cm', 'ft'],
                            onChanged: (val) =>
                                setState(() => _heightUnit = val ?? 'cm'),
                            enabled: _isEditing,
                            icon: Icons.straighten,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDropdown<String>(
                            label: 'Weight Unit',
                            value: _weightUnit,
                            items: const ['kg', 'lbs'],
                            onChanged: (val) =>
                                setState(() => _weightUnit = val ?? 'kg'),
                            enabled: _isEditing,
                            icon: Icons.scale,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
            // --- Action Buttons ---
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (_isEditing) {
                        _saveProfile();
                      } else {
                        setState(() => _isEditing = true);
                      }
                    },
                    icon: Icon(_isEditing ? Icons.save : Icons.edit),
                    label: Text(_isEditing ? 'Save Details' : 'Edit Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      textStyle: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      textStyle: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
