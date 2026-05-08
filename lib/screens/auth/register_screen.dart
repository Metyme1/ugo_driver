import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _pageController = PageController();
  int _currentStep = 0;

  // Step 1 — Account
  final _step1Key = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;

  // Step 2 — Personal Info
  final _step2Key = GlobalKey<FormState>();
  DateTime? _dateOfBirth;
  String? _educationLevel;
  final _nationalIdCtrl = TextEditingController();
  final _licenseCtrl = TextEditingController();
  DateTime? _licenseExpiry;
  File? _nationalIdImage;

  // Step 3 — Vehicle Info
  final _step3Key = GlobalKey<FormState>();
  String? _vehicleType;
  final _plateCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();

  static const _educationLevels = [
    ('none', 'None'),
    ('primary', 'Primary School'),
    ('secondary', 'Secondary School'),
    ('diploma', 'Diploma'),
    ('degree', 'Bachelor\'s Degree'),
    ('masters', 'Master\'s Degree'),
    ('phd', 'PhD'),
  ];

  static const _vehicleTypes = [
    ('bajaj', 'Bajaj (3-Wheeler)'),
    ('electric', 'Electric Bajaj'),
    ('force', 'Force / Mini-bus'),
  ];

  static const _stepTitles = ['Register', 'Personal Info', 'Vehicle Info'];
  static const _stepSubtitles = [
    'Join the UGO driver network',
    'Your identity & license details',
    'Details about your vehicle',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _nationalIdCtrl.dispose();
    _licenseCtrl.dispose();
    _plateCtrl.dispose();
    _colorCtrl.dispose();
    _modelCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    final valid = switch (_currentStep) {
      0 => _step1Key.currentState!.validate(),
      1 => _step2Key.currentState!.validate(),
      _ => false,
    };
    if (!valid) return;
    _pageController.nextPage(
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    setState(() => _currentStep++);
  }

  void _prevStep() {
    _pageController.previousPage(
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    setState(() => _currentStep--);
  }

  Future<void> _pickDate({required bool isExpiry}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isExpiry
          ? now.add(const Duration(days: 365))
          : DateTime(now.year - 25),
      firstDate: isExpiry ? now : DateTime(1950),
      lastDate: isExpiry ? DateTime(now.year + 20) : now,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isExpiry) {
        _licenseExpiry = picked;
      } else {
        _dateOfBirth = picked;
      }
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final choice = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined,
                    color: AppColors.primary),
                title: const Text('Take a photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined,
                    color: AppColors.primary),
                title: const Text('Choose from gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );
    if (choice == null) return;
    final file = await picker.pickImage(source: choice, imageQuality: 80);
    if (file != null) setState(() => _nationalIdImage = File(file.path));
  }

  Future<void> _submit() async {
    if (!_step3Key.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      fullName: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      password: _passwordCtrl.text,
      confirmPassword: _confirmCtrl.text,
      dateOfBirth: _dateOfBirth != null
          ? DateFormat('yyyy-MM-dd').format(_dateOfBirth!)
          : null,
      educationLevel: _educationLevel,
      nationalIdNumber: _nationalIdCtrl.text.trim().isEmpty
          ? null
          : _nationalIdCtrl.text.trim(),
      nationalIdImage: _nationalIdImage,
      licenseNumber: _licenseCtrl.text.trim().isEmpty
          ? null
          : _licenseCtrl.text.trim(),
      licenseExpiry: _licenseExpiry != null
          ? DateFormat('yyyy-MM-dd').format(_licenseExpiry!)
          : null,
      vehicleType: _vehicleType,
      plateNumber: _plateCtrl.text.trim().isEmpty
          ? null
          : _plateCtrl.text.trim().toUpperCase(),
      vehicleColor:
          _colorCtrl.text.trim().isEmpty ? null : _colorCtrl.text.trim(),
      vehicleModel:
          _modelCtrl.text.trim().isEmpty ? null : _modelCtrl.text.trim(),
    );
    if (success && mounted) {
      context.push('/otp', extra: {
        'phone': auth.pendingPhone ?? _phoneCtrl.text.trim(),
        'purpose': 'registration',
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, Colors.white],
            stops: [0.0, 0.45],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Gradient header ──────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _currentStep > 0
                              ? _prevStep
                              : () => context.pop(),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.arrow_back_ios_new,
                                size: 16, color: Colors.white),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Step ${_currentStep + 1} of 3',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _stepTitles[_currentStep],
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _stepSubtitles[_currentStep],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // ── White card (fills remaining space) ───────────
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.card,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(32)),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 20,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      _StepIndicator(currentStep: _currentStep),
                      Expanded(
                        child: PageView(
                          controller: _pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _step1(),
                            _step2(),
                            _step3(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Step 1: Account Info ────────────────────────────────────

  Widget _step1() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Form(
          key: _step1Key,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Full Name'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _nameCtrl,
                hint: 'Enter Full Name',
                prefixIcon: Icons.person_outlined,
                textCapitalization: TextCapitalization.words,
                validator: (v) => (v == null || v.trim().length < 2)
                    ? 'Enter your full name'
                    : null,
              ),
              const SizedBox(height: 16),
              _buildLabel('Phone Number'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _phoneCtrl,
                hint: '09XXXXXXXX',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter your phone number' : null,
              ),
              const SizedBox(height: 16),
              _buildLabel('Password'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _passwordCtrl,
                hint: 'Enter Password',
                prefixIcon: Icons.lock_outline,
                obscureText: _obscure,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.textHint,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
                validator: (v) =>
                    (v == null || v.length < 8) ? 'At least 8 characters' : null,
              ),
              const SizedBox(height: 16),
              _buildLabel('Confirm Password'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _confirmCtrl,
                hint: 'Confirm Password',
                prefixIcon: Icons.lock_outline,
                obscureText: _obscure,
                validator: (v) =>
                    v != _passwordCtrl.text ? 'Passwords do not match' : null,
              ),
              if (auth.errorMessage != null) ...[
                const SizedBox(height: 12),
                _errorBox(auth.errorMessage!),
              ],
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28)),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style:
                        TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Step 2: Personal Info ───────────────────────────────────

  Widget _step2() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Form(
          key: _step2Key,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Date of Birth'),
              const SizedBox(height: 8),
              _dateField(
                hint: 'Select date of birth',
                value: _dateOfBirth,
                icon: Icons.cake_outlined,
                onTap: () => _pickDate(isExpiry: false),
              ),
              const SizedBox(height: 16),

              _buildLabel('Education Level'),
              const SizedBox(height: 8),
              _styledDropdown<String>(
                value: _educationLevel,
                hint: 'Select education level',
                prefixIcon: Icons.school_outlined,
                items: _educationLevels
                    .map((e) => DropdownMenuItem(value: e.$1, child: Text(e.$2)))
                    .toList(),
                onChanged: (v) => setState(() => _educationLevel = v),
              ),
              const SizedBox(height: 16),

              _buildLabel('National ID Number'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _nationalIdCtrl,
                hint: 'Enter national ID number',
                prefixIcon: Icons.badge_outlined,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Enter your national ID number'
                    : null,
              ),
              const SizedBox(height: 16),

              _buildLabel('National ID Photo'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _nationalIdImage != null
                          ? AppColors.primary
                          : AppColors.border,
                      width: _nationalIdImage != null ? 1.5 : 1,
                    ),
                  ),
                  child: _nationalIdImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(11),
                          child: Image.file(_nationalIdImage!, fit: BoxFit.cover),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_outlined,
                                size: 36, color: AppColors.textHint),
                            SizedBox(height: 8),
                            Text('Tap to upload ID photo',
                                style: TextStyle(
                                    color: AppColors.textHint, fontSize: 13)),
                          ],
                        ),
                ),
              ),
              if (_nationalIdImage == null) ...[
                const SizedBox(height: 4),
                const Text('  Required for verification',
                    style: TextStyle(color: AppColors.error, fontSize: 12)),
              ],
              const SizedBox(height: 16),

              _buildLabel('Driver License Number'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _licenseCtrl,
                hint: 'Enter license number',
                prefixIcon: Icons.credit_card_outlined,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Enter your license number'
                    : null,
              ),
              const SizedBox(height: 16),

              _buildLabel('License Expiry Date'),
              const SizedBox(height: 8),
              _dateField(
                hint: 'Select expiry date',
                value: _licenseExpiry,
                icon: Icons.event_outlined,
                onTap: () => _pickDate(isExpiry: true),
              ),

              if (auth.errorMessage != null) ...[
                const SizedBox(height: 12),
                _errorBox(auth.errorMessage!),
              ],
              const SizedBox(height: 28),

              Row(
                children: [
                  TextButton.icon(
                    onPressed: _prevStep,
                    icon: const Icon(Icons.arrow_back, size: 16),
                    label: const Text('Back'),
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_nationalIdImage == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Please upload your National ID photo')),
                            );
                            return;
                          }
                          if (_licenseExpiry == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Please select your license expiry date')),
                            );
                            return;
                          }
                          _nextStep();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textOnPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28)),
                        ),
                        child: const Text(
                          'Next',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Step 3: Vehicle Info ────────────────────────────────────

  Widget _step3() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Form(
          key: _step3Key,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Vehicle Type'),
              const SizedBox(height: 8),
              _styledDropdown<String>(
                value: _vehicleType,
                hint: 'Select vehicle type',
                prefixIcon: Icons.directions_car_outlined,
                items: _vehicleTypes
                    .map((e) => DropdownMenuItem(value: e.$1, child: Text(e.$2)))
                    .toList(),
                onChanged: (v) => setState(() => _vehicleType = v),
                validator: (v) => v == null ? 'Select your vehicle type' : null,
              ),
              const SizedBox(height: 16),

              _buildLabel('Plate Number'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _plateCtrl,
                hint: 'e.g. 3-12345',
                prefixIcon: Icons.pin_outlined,
                textCapitalization: TextCapitalization.characters,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Enter your plate number'
                    : null,
              ),
              const SizedBox(height: 16),

              _buildLabel('Vehicle Color'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _colorCtrl,
                hint: 'e.g. Blue',
                prefixIcon: Icons.palette_outlined,
                textCapitalization: TextCapitalization.words,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Enter vehicle color'
                    : null,
              ),
              const SizedBox(height: 16),

              _buildLabel('Vehicle Model / Year'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _modelCtrl,
                hint: 'e.g. Bajaj RE 2022',
                prefixIcon: Icons.build_outlined,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 16, color: AppColors.primary),
                        SizedBox(width: 6),
                        Text(
                          'After registration',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                              fontSize: 13),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Your account will be reviewed by the admin team before activation. You\'ll be notified once approved.',
                      style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.5),
                    ),
                  ],
                ),
              ),

              if (auth.errorMessage != null) ...[
                const SizedBox(height: 12),
                _errorBox(auth.errorMessage!),
              ],
              const SizedBox(height: 28),

              Row(
                children: [
                  TextButton.icon(
                    onPressed: auth.isLoading ? null : _prevStep,
                    icon: const Icon(Icons.arrow_back, size: 16),
                    label: const Text('Back'),
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: auth.isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textOnPrimary,
                          disabledBackgroundColor: AppColors.primaryLight,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28)),
                        ),
                        child: auth.isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                    color: AppColors.textOnPrimary,
                                    strokeWidth: 2.5),
                              )
                            : const Text(
                                'Submit Registration',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w600),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Shared helpers ──────────────────────────────────────────

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    IconData? prefixIcon,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    bool obscureText = false,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textCapitalization: textCapitalization,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, color: AppColors.textHint),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppColors.textHint, size: 20)
            : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        errorStyle: const TextStyle(fontSize: 12),
      ),
    );
  }

  Widget _dateField({
    required String hint,
    required DateTime? value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value != null
                ? AppColors.primary.withValues(alpha: 0.6)
                : Colors.transparent,
            width: value != null ? 1.5 : 0,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textHint, size: 20),
            const SizedBox(width: 12),
            Text(
              value != null ? DateFormat('dd MMM yyyy').format(value) : hint,
              style: TextStyle(
                fontSize: 14,
                color: value != null ? AppColors.textPrimary : AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _styledDropdown<T>({
    required T? value,
    required String hint,
    required IconData prefixIcon,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
    String? Function(T?)? validator,
  }) {
    return DropdownButtonFormField<T>(
      key: ValueKey(value),
      initialValue: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      icon: const Icon(Icons.keyboard_arrow_down,
          color: AppColors.textHint, size: 20),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, color: AppColors.textHint),
        prefixIcon: Icon(prefixIcon, color: AppColors.textHint, size: 20),
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        errorStyle: const TextStyle(fontSize: 12),
      ),
    );
  }

  Widget _errorBox(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppColors.error, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step progress indicator ─────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    const labels = ['Account', 'Personal', 'Vehicle'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Row(
        children: List.generate(3, (i) {
          final isActive = i == currentStep;
          final isDone = i < currentStep;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDone || isActive
                              ? AppColors.primary
                              : AppColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        labels[i],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: isActive
                              ? AppColors.primary
                              : isDone
                                  ? AppColors.primary
                                  : AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < 2) const SizedBox(width: 6),
              ],
            ),
          );
        }),
      ),
    );
  }
}
