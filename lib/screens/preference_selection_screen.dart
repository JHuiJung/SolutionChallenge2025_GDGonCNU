// lib/screens/preference_selection_screen.dart
import 'package:flutter/material.dart';
import '../firebase/firestoreManager.dart' as firestoreManager;

import '../firebase/firestoreManager.dart' as firestoreManager;

// --- Data Structure Definition --- (Can be in another file)
class PreferenceSection {
  final String key;
  final String question;
  final List<String> options;
  final bool allowMultipleSelection;

  PreferenceSection({
    required this.key,
    required this.question,
    required this.options,
    required this.allowMultipleSelection,
  });
}

final List<PreferenceSection> preferenceSectionsData = [
  PreferenceSection(
    key: 'purpose',
    question: 'What is your main purpose for traveling?',
    options: ['Activities', 'Food Discovery', 'Photography', 'Relaxation', 'Cultural Exploration', 'etc'],
    allowMultipleSelection: true,
  ),
  PreferenceSection(
    key: 'destination',
    question: 'What type of destination do you prefer?',
    options: ['Nature', 'Cities', 'Both'],
    allowMultipleSelection: false,
  ),
  PreferenceSection(
    key: 'companion',
    question: 'Who do you usually travel with?',
    options: ['Alone', 'Friends', 'Family', 'Partners'],
    allowMultipleSelection: true, // Looks like multiple selection is possible based on the image
  ),
  PreferenceSection(
    key: 'planningStyle',
    question: 'What is your travel planning style?',
    options: ['Detailed and Structured Itinerary', 'Spontaneous and Flexible'],
    allowMultipleSelection: false,
  ),
];
// --- End of Data Structure Definition ---


class PreferenceSelectionScreen extends StatefulWidget {
  const PreferenceSelectionScreen({super.key});

  @override
  State<PreferenceSelectionScreen> createState() => _PreferenceSelectionScreenState();
}

class _PreferenceSelectionScreenState extends State<PreferenceSelectionScreen> {
  // State variable to store selected items (Manage all sections as a Set)
  final Map<String, Set<String>> _selectedPreferences = {};

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    // Define chip style (refer to image)
    final Color chipBackgroundColor = colorScheme.brightness == Brightness.light
        ? Colors.purple.shade100.withValues(alpha: 0.7)
        : Colors.purple.shade800.withValues(alpha: 0.7);
    final Color selectedChipColor = colorScheme.brightness == Brightness.light
        ? Colors.deepPurple.shade300 // Darker purple when selected
        : Colors.deepPurple.shade500;
    final Color chipTextColor = colorScheme.onSurface.withValues(alpha: 0.8);
    final Color selectedChipTextColor = Colors.white; // White text when selected

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
              Navigator.pushReplacementNamed(context, '/profile');
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/main');
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
          // Keep horizontal padding, adjust vertical padding
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: Column(
            // Center children of Column (text, etc.)
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Main title
              Text(
                'Let me know\nmore about you',
                textAlign: TextAlign.center,
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 50),

              // --- Dynamically generate preference sections ---
              ...preferenceSectionsData.map((section) {
                return _buildPreferenceSection(
                  context: context,
                  section: section, // Pass section data
                  selectedOptions: _selectedPreferences[section.key] ?? {}, // Pass current selection value
                  chipBackgroundColor: chipBackgroundColor,
                  selectedChipColor: selectedChipColor,
                  chipTextColor: chipTextColor,
                  selectedChipTextColor: selectedChipTextColor,
                );
              }).toList(),
              // --- End of section generation ---

              const SizedBox(height: 40), // Space between last section and button

              // Complete button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Add logic to save selected preferences (if needed)
                    print('Selected Preferences: $_selectedPreferences');

                    // Save to Firestore
                    firestoreManager.mainUserInfo.preferTravlePurpose = _selectedPreferences['purpose']!.toList();
                    firestoreManager.mainUserInfo.preferDestination = _selectedPreferences['destination']!.toList();
                    firestoreManager.mainUserInfo.preferPeople = _selectedPreferences['companion']!.toList();
                    firestoreManager.mainUserInfo.preferPlanningStyle = _selectedPreferences['planningStyle']!.toList();



                    firestoreManager.addUser();

                    // Navigate to main screen
                    Navigator.pushReplacementNamed(context, '/main');
                  },
                  style: ElevatedButton.styleFrom(
                    // Use theme's button style or specify directly
                    // backgroundColor: colorScheme.primary,
                    // foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Rounded button
                    ),
                  ),
                  child: const Text('완료'),
                ),
              ),
              const SizedBox(height: 40), // Bottom padding
            ],
          ),
        ),
      ),
      // Bottom completion button (using FloatingActionButton)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add logic to save selected preferences
          print('Selected Preferences: $_selectedPreferences');
          Navigator.pushReplacementNamed(context, '/main');
        },
        backgroundColor: chipBackgroundColor, // Button color (similar to unselected chip color)
        elevation: 2,
        child: Icon(
          Icons.arrow_forward,
          color: chipTextColor, // Icon color
        ),
      ),
    );
  }

  // Preference section builder function
  Widget _buildPreferenceSection({
    required BuildContext context,
    required PreferenceSection section, // Receive section data
    required Set<String> selectedOptions,
    required Color chipBackgroundColor,
    required Color selectedChipColor,
    required Color chipTextColor,
    required Color selectedChipTextColor,
  }) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      // Add slight margin to clearly distinguish each section (optional)
      margin: const EdgeInsets.only(bottom: 30.0),
      child: Column(
        // Center inner elements of the section (question, chip group)
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Question text
          Text(
            section.question,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center, // Also center question text
          ),
          const SizedBox(height: 15),
          // Option chip group (using Wrap)
          Wrap(
            spacing: 10.0, // Horizontal spacing
            runSpacing: 10.0, // Vertical spacing
            alignment: WrapAlignment.center, // *** Center the chips ***
            children: section.options.map((option) {
              final bool isSelected = selectedOptions.contains(option);
              return ChoiceChip(
                label: Text(option),
                labelStyle: TextStyle(
                  color: isSelected ? selectedChipTextColor : chipTextColor,
                  fontWeight: FontWeight.w500,
                ),
                selected: isSelected,
                onSelected: (selected) {
                  // --- Modify selection logic ---
                  setState(() {
                    final currentSelection = _selectedPreferences[section.key] ?? {};
                    if (section.allowMultipleSelection) {
                      // Multiple selection allowed section
                      if (selected) {
                        currentSelection.add(option);
                      }
                      else {
                        currentSelection.remove(option);
                      }
                    }
                    else {
                      // Single selection section
                      currentSelection.clear(); // Deselect all existing selections
                      if (selected) {
                        currentSelection.add(option); // Add only the newly selected one
                      }
                      // Maintain unselected state if deselected
                    }
                    _selectedPreferences[section.key] = currentSelection; // Save updated Set
                  });
                  // --- End of selection logic modification ---
                },
                backgroundColor: chipBackgroundColor,
                selectedColor: selectedChipColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  side: BorderSide.none, // Remove border
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0), // Adjust padding
                showCheckmark: false, // Hide checkmark
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}