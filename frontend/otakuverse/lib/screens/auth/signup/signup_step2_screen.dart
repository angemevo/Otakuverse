import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:intl/intl.dart';
import 'package:otakuverse/core/constants/colors.dart';
import 'package:otakuverse/core/utils/helpers.dart';
import 'package:otakuverse/core/widgets/button/app_button.dart';
import 'package:otakuverse/core/widgets/step_indicator.dart'; // ✅ AJOUTÉ
import 'package:otakuverse/models/sign_up_data.dart';
import 'package:otakuverse/screens/auth/signup/signup_step3_screen.dart';

class SignUpStep2Screen extends StatefulWidget {
  final SignupData signupData;

  const SignUpStep2Screen({super.key, required this.signupData});

  @override
  State<SignUpStep2Screen> createState() => _SignUpStep2ScreenState();
}

class _SignUpStep2ScreenState extends State<SignUpStep2Screen> {
  DateTime? _selectedDate;
  String? _selectedGender;

  final List<Map<String, String>> _genders = [
    {'value': 'male', 'label': 'Homme', 'icon': '👨'},
    {'value': 'female', 'label': 'Femme', 'icon': '👩'},
    {'value': 'other', 'label': 'Autre', 'icon': '🧑'},
    {'value': 'prefer_not_to_say', 'label': 'Préfère ne pas dire', 'icon': '🤐'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.signupData.dateOfBirth;
    _selectedGender = widget.signupData.gender;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.crimsonRed,
              surface: AppColors.darkGray,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _handleNext() {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner votre date de naissance'),
        ),
      );
      return;
    }

    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner votre genre')),
      );
      return;
    }

    print('=== _handleNext appelé ===');
    print('Date: $_selectedDate');
    print('Genre: $_selectedGender');
    
    // if (_selectedDate == null) { ... }
    // if (_selectedGender == null) { ... }

    print('✅ Validation OK, navigation...');
    widget.signupData.dateOfBirth = _selectedDate;
    widget.signupData.gender = _selectedGender;

    Helpers.navigateTo(SignUpStep3Screen(signupData: widget.signupData));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: StepIndicator(currentStep: 2, totalSteps: 3), // ✅ CORRIGÉ
            ),
            const SizedBox(height: 32),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informations personnelles',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Étape 2 sur 3 : Date et genre',
                      style: TextStyle(fontSize: 16, color: AppColors.lightGray),
                    ),
                    const SizedBox(height: 40),
                    GestureDetector(
                      onTap: _selectDate,
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.darkGray,
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today_outlined,
                                color: AppColors.lightGray),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _selectedDate == null
                                    ? 'Date de naissance'
                                    : DateFormat('dd MMMM yyyy', 'fr_FR')
                                        .format(_selectedDate!),
                                style: TextStyle(
                                  color: _selectedDate == null
                                      ? AppColors.lightGray
                                      : Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Icon(Icons.arrow_drop_down,
                                color: AppColors.lightGray),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Genre',
                      style: TextStyle(
                        color: AppColors.lightGray,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._genders.map((gender) {
                      final isSelected = _selectedGender == gender['value'];
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedGender = gender['value']),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.crimsonWithOpacity(0.1)
                                : AppColors.darkGray,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.crimsonRed
                                  : AppColors.border,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Text(gender['icon']!,
                                  style: const TextStyle(fontSize: 24)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  gender['label']!,
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppColors.crimsonRed
                                        : Colors.white,
                                    fontSize: 16,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle,
                                    color: AppColors.crimsonRed, size: 24),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 32),
                    AppButton(
                      label: 'Suivant',
                      type: AppButtonType.primary,
                      onPressed: _handleNext,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}