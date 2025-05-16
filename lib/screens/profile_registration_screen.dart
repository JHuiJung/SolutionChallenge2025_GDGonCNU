// lib/screens/profile_registration_screen.dart
import 'package:flutter/material.dart';
import '../firebase/firestoreManager.dart' as firestoreManager;
import 'package:firebase_auth/firebase_auth.dart';

// Change to StatefulWidget
class ProfileRegistrationScreen extends StatefulWidget {
  const ProfileRegistrationScreen({super.key});

  @override
  State<ProfileRegistrationScreen> createState() => _ProfileRegistrationScreenState();
}

class _ProfileRegistrationScreenState extends State<ProfileRegistrationScreen> {
  // State variables to store selected values
  // Add TextEditingController for Username
  final TextEditingController _usernameController = TextEditingController();
  String? _selectedNationality;
  String? _selectedGender;
  int? _selectedBirthYear;

  // Dropdown option data
  // TODO: In a real app, this list should be expanded or fetched from an external source (e.g., JSON)
  final List<String> _nationalities = [
    'South Korea', 'United States', 'Japan', 'China', 'United Kingdom',
    'Germany', 'France', 'Canada', 'Australia', 'India', 'Vietnam',
    'Thailand', 'Philippines', 'Russia', 'Brazil', 'Mexico', 'Other'
  ];
  final List<String> _genders = ['Male', 'Female', 'Other'];
  // Year of birth (1900 ~ 2025) - Use reversed to show recent years first
  final List<int> _birthYears = List<int>.generate(
      DateTime.now().year - 1900 + 1, (index) => 1900 + index)
      .reversed
      .toList();

  // --- Add Controller Dispose ---
  @override
  void dispose() {
    _usernameController.dispose(); // Release controller memory
    super.dispose();
  }

  // Helper function for input field style (reusable)
  InputDecoration _buildInputDecoration({String? labelText, String? hintText, required Color backgroundColor}) {
    return InputDecoration(
      labelText: labelText, // Add label text
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey[500]),
      filled: true,
      fillColor: backgroundColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color textFieldBackgroundColor = colorScheme.brightness == Brightness.light
        ? Colors.grey.shade200
        : Colors.grey.shade800;
    final Color fabColor = colorScheme.brightness == Brightness.light
        ? Colors.grey.shade300
        : Colors.grey.shade700;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onSurface),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, '/login');
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              // On Skip button click, navigate directly to preference analysis screen

              Navigator.pushReplacementNamed(context, '/preference');
            },
            child: const Text(
              'skip',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Set up\nyour account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.amberAccent,
                  child: Icon(Icons.person, size: 70, color: Colors.grey[700]),
                ),
              ),
              const SizedBox(height: 50),

              // --- Modified User Name TextField ---
              _buildSectionTitle('user name'),
              TextField(
                controller: _usernameController, // Connect controller
                decoration: _buildInputDecoration(
                  hintText: 'Enter your username',
                  backgroundColor: textFieldBackgroundColor,
                ),
                // Additional settings (optional)
                textCapitalization: TextCapitalization.words, // Capitalize first letter like names
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 20),

              // --- Nationality (DropdownButtonFormField) ---
              _buildSectionTitle('Nationality'),
              DropdownButtonFormField<String>(
                value: _selectedNationality, // Currently selected value
                hint: const Text('Select Nationality'), // Placeholder text
                items: _nationalities.map((String nationality) {
                  return DropdownMenuItem<String>(
                    value: nationality,
                    child: Text(nationality),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedNationality = newValue; // Update state on selection
                  });
                },
                decoration: _buildInputDecoration( // Apply style
                  backgroundColor: textFieldBackgroundColor,
                  // labelText: 'Nationality', // Add label if needed
                ),
                // Style when dropdown is expanded (optional)
                dropdownColor: colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12.0),
                isExpanded: true, // Fill width
              ),
              const SizedBox(height: 20),

              // --- Gender (DropdownButtonFormField) ---
              _buildSectionTitle('Gender'),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                hint: const Text('Select Gender'),
                items: _genders.map((String gender) {
                  return DropdownMenuItem<String>(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedGender = newValue;
                  });
                },
                decoration: _buildInputDecoration(
                  backgroundColor: textFieldBackgroundColor,
                ),
                dropdownColor: colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12.0),
                isExpanded: true,
              ),
              const SizedBox(height: 20),

              // --- Age (Year of Birth - DropdownButtonFormField) ---
              _buildSectionTitle('Age (Year of Birth)'),
              DropdownButtonFormField<int>(
                value: _selectedBirthYear,
                hint: const Text('Select Year'),
                items: _birthYears.map((int year) {
                  return DropdownMenuItem<int>(
                    value: year,
                    child: Text(year.toString()),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  setState(() {
                    _selectedBirthYear = newValue;
                  });
                },
                decoration: _buildInputDecoration(
                  backgroundColor: textFieldBackgroundColor,
                ),
                dropdownColor: colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12.0),
                isExpanded: true,
                // Make it scrollable (if many items)
                menuMaxHeight: 300.0,
              ),
              const SizedBox(height: 80), // Reserve space for FAB
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // --- Get entered Username value ---
          final String username = _usernameController.text.trim(); // Remove leading/trailing spaces with trim()

          // TODO: Add input validation (e.g., check if username is empty)
          if (username.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please enter your username.')),
            );
            return; // Stop process
          }
          // Add validation for other fields if needed

          // --- Print all data (for verification) ---
          // TODO: Add logic to save selected values (_selectedNationality, _selectedGender, _selectedBirthYear)
          print('Username: $username'); // Print fetched username
          print('Nationality: $_selectedNationality');
          print('Gender: $_selectedGender');
          print('Birth Year: $_selectedBirthYear');

          // Save to Firestore
          User? userinfo = FirebaseAuth.instance.currentUser;

          if(userinfo != null)
          {
            firestoreManager.mainUserInfo.email = userinfo.email;
          }
          firestoreManager.mainUserInfo.name = username;
          firestoreManager.mainUserInfo.gender = _selectedGender;
          firestoreManager.mainUserInfo.region = _selectedNationality;
          firestoreManager.mainUserInfo.birthYear = _selectedBirthYear!;

          Navigator.pushReplacementNamed(context, '/preference');
        },
        backgroundColor: fabColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Icon(
          Icons.arrow_forward,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }

  // Helper widget for input field titles
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.grey[600],
        ),
      ),
    );
  }


  // Helper widget function to build a TextField
  Widget _buildTextField({
    required String label,
    required String hint,
    required Color backgroundColor,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600], // Label color
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[500]),
            filled: true,
            // Enable background fill
            fillColor: backgroundColor,
            // Specify background color
            border: OutlineInputBorder( // Border settings
              borderRadius: BorderRadius.circular(12.0), // Rounded corners
              borderSide: BorderSide.none, // Remove default border line
            ),
            contentPadding: const EdgeInsets.symmetric(
                vertical: 16.0, horizontal: 16.0), // Inner padding
          ),
        ),
      ],
    );
  }
}