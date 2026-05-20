import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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

  final _step1Key = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;

  final _step2Key = GlobalKey<FormState>();
  DateTime? _dateOfBirth;
  String? _educationLevel;
  final _nationalIdCtrl = TextEditingController();
  final _licenseCtrl = TextEditingController();
  DateTime? _licenseExpiry;
  File? _nationalIdImage;

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
    ('degree', "Bachelor's Degree"),
    ('masters', "Master's Degree"),
    ('phd', 'PhD'),
  ];

  static const _vehicleTypes = [
    ('bajaj', 'Bajaj (3-Wheeler)'),
    ('electric', 'Electric Bajaj'),
    ('force', 'Force / Mini-bus'),
  ];

  static const _stepTitles = ['Create Account', 'Personal Info', 'Vehicle Info'];
  static const _stepSubtitles = [
    'Join the UGO driver network',
    'Identity & license details',
    'Your vehicle details',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameCtrl.dispose(); _phoneCtrl.dispose(); _passwordCtrl.dispose();
    _confirmCtrl.dispose(); _nationalIdCtrl.dispose(); _licenseCtrl.dispose();
    _plateCtrl.dispose(); _colorCtrl.dispose(); _modelCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    final valid = switch (_currentStep) {
      0 => _step1Key.currentState!.validate(),
      1 => _step2Key.currentState!.validate(),
      _ => false,
    };
    if (!valid) return;
    _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    setState(() => _currentStep++);
  }

  void _prevStep() {
    _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    setState(() => _currentStep--);
  }

  Future<void> _pickDate({required bool isExpiry}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isExpiry ? now.add(const Duration(days: 365)) : DateTime(now.year - 25),
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
    setState(() => isExpiry ? _licenseExpiry = picked : _dateOfBirth = picked);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final choice = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(width: 40, height: 40,
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.camera_alt_outlined, color: AppColors.primary, size: 20)),
                title: Text('Take a photo', style: GoogleFonts.outfit(fontWeight: FontWeight.w400)),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: Container(width: 40, height: 40,
                  decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.photo_library_outlined, color: AppColors.accent, size: 20)),
                title: Text('Choose from gallery', style: GoogleFonts.outfit(fontWeight: FontWeight.w400)),
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
      dateOfBirth: _dateOfBirth != null ? DateFormat('yyyy-MM-dd').format(_dateOfBirth!) : null,
      educationLevel: _educationLevel,
      nationalIdNumber: _nationalIdCtrl.text.trim().isEmpty ? null : _nationalIdCtrl.text.trim(),
      nationalIdImage: _nationalIdImage,
      licenseNumber: _licenseCtrl.text.trim().isEmpty ? null : _licenseCtrl.text.trim(),
      licenseExpiry: _licenseExpiry != null ? DateFormat('yyyy-MM-dd').format(_licenseExpiry!) : null,
      vehicleType: _vehicleType,
      plateNumber: _plateCtrl.text.trim().isEmpty ? null : _plateCtrl.text.trim().toUpperCase(),
      vehicleColor: _colorCtrl.text.trim().isEmpty ? null : _colorCtrl.text.trim(),
      vehicleModel: _modelCtrl.text.trim().isEmpty ? null : _modelCtrl.text.trim(),
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
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Gradient header
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _currentStep > 0 ? _prevStep : () => context.pop(),
                          child: Container(
                            width: 38, height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.arrow_back_ios_new, size: 15, color: Colors.white),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Step ${_currentStep + 1} of 3',
                            style: GoogleFonts.outfit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w400),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _stepTitles[_currentStep],
                      style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w500, color: Colors.white, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _stepSubtitles[_currentStep],
                      style: GoogleFonts.outfit(fontSize: 14, color: Colors.white.withValues(alpha: 0.75)),
                    ),
                    const SizedBox(height: 20),
                    _StepIndicator(currentStep: _currentStep),
                  ],
                ),
              ),
            ),
          ),

          // Form area
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [_step1(), _step2(), _step3()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _step1() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Form(
          key: _step1Key,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Full Name'),
              const SizedBox(height: 8),
              _buildTextField(controller: _nameCtrl, hint: 'Enter full name',
                prefixIcon: Icons.person_outline_rounded,
                textCapitalization: TextCapitalization.words,
                validator: (v) => (v == null || v.trim().length < 2) ? 'Enter your full name' : null),
              const SizedBox(height: 18),
              _buildLabel('Phone Number'),
              const SizedBox(height: 8),
              _buildTextField(controller: _phoneCtrl, hint: '09XXXXXXXX',
                prefixIcon: Icons.phone_outlined, keyboardType: TextInputType.phone,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your phone number' : null),
              const SizedBox(height: 18),
              _buildLabel('Password'),
              const SizedBox(height: 8),
              _buildTextField(controller: _passwordCtrl, hint: 'Min 8 characters',
                prefixIcon: Icons.lock_outline_rounded, obscureText: _obscure,
                suffixIcon: GestureDetector(
                  onTap: () => setState(() => _obscure = !_obscure),
                  child: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: AppColors.textHint, size: 20)),
                validator: (v) => (v == null || v.length < 8) ? 'At least 8 characters' : null),
              const SizedBox(height: 18),
              _buildLabel('Confirm Password'),
              const SizedBox(height: 8),
              _buildTextField(controller: _confirmCtrl, hint: 'Confirm password',
                prefixIcon: Icons.lock_outline_rounded, obscureText: _obscure,
                validator: (v) => v != _passwordCtrl.text ? 'Passwords do not match' : null),
              if (auth.errorMessage != null) ...[
                const SizedBox(height: 16),
                _errorBox(auth.errorMessage!),
              ],
              const SizedBox(height: 28),
              _GradientButton(label: 'Continue', isLoading: false, onTap: _nextStep),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have an account? ', style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 14)),
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Text('Sign In', style: GoogleFonts.outfit(color: AppColors.primary, fontWeight: FontWeight.w500, fontSize: 14)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _step2() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Form(
          key: _step2Key,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Date of Birth'),
              const SizedBox(height: 8),
              _dateField(hint: 'Select date of birth', value: _dateOfBirth,
                icon: Icons.cake_outlined, onTap: () => _pickDate(isExpiry: false)),
              const SizedBox(height: 18),
              _buildLabel('Education Level'),
              const SizedBox(height: 8),
              _styledDropdown<String>(
                value: _educationLevel, hint: 'Select education level',
                prefixIcon: Icons.school_outlined,
                items: _educationLevels.map((e) => DropdownMenuItem(value: e.$1, child: Text(e.$2))).toList(),
                onChanged: (v) => setState(() => _educationLevel = v)),
              const SizedBox(height: 18),
              _buildLabel('National ID Number'),
              const SizedBox(height: 8),
              _buildTextField(controller: _nationalIdCtrl, hint: 'Enter national ID number',
                prefixIcon: Icons.badge_outlined,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your national ID number' : null),
              const SizedBox(height: 18),
              _buildLabel('National ID Photo'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _nationalIdImage != null ? AppColors.primary : AppColors.border,
                      width: _nationalIdImage != null ? 2 : 1,
                    ),
                  ),
                  child: _nationalIdImage != null
                      ? ClipRRect(borderRadius: BorderRadius.circular(14),
                          child: Image.file(_nationalIdImage!, fit: BoxFit.cover))
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(width: 52, height: 52,
                              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                              child: const Icon(Icons.add_a_photo_outlined, size: 24, color: AppColors.primary)),
                            const SizedBox(height: 10),
                            Text('Tap to upload ID photo',
                              style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                          ],
                        ),
                ),
              ),
              if (_nationalIdImage == null) ...[
                const SizedBox(height: 6),
                Text('  Required for verification',
                  style: GoogleFonts.outfit(color: AppColors.error, fontSize: 12)),
              ],
              const SizedBox(height: 18),
              _buildLabel('Driver License Number'),
              const SizedBox(height: 8),
              _buildTextField(controller: _licenseCtrl, hint: 'Enter license number',
                prefixIcon: Icons.credit_card_outlined,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your license number' : null),
              const SizedBox(height: 18),
              _buildLabel('License Expiry Date'),
              const SizedBox(height: 8),
              _dateField(hint: 'Select expiry date', value: _licenseExpiry,
                icon: Icons.event_outlined, onTap: () => _pickDate(isExpiry: true)),
              if (auth.errorMessage != null) ...[
                const SizedBox(height: 16),
                _errorBox(auth.errorMessage!),
              ],
              const SizedBox(height: 28),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: _prevStep,
                    icon: const Icon(Icons.arrow_back_rounded, size: 16),
                    label: Text('Back', style: GoogleFonts.outfit()),
                    style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _GradientButton(
                      label: 'Continue',
                      isLoading: false,
                      onTap: () {
                        if (_nationalIdImage == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: const Text('Please upload your National ID photo'),
                              backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
                          return;
                        }
                        if (_licenseExpiry == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: const Text('Please select your license expiry date'),
                              backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
                          return;
                        }
                        _nextStep();
                      },
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

  Widget _step3() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Form(
          key: _step3Key,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Vehicle Type'),
              const SizedBox(height: 8),
              _styledDropdown<String>(
                value: _vehicleType, hint: 'Select vehicle type',
                prefixIcon: Icons.directions_car_outlined,
                items: _vehicleTypes.map((e) => DropdownMenuItem(value: e.$1, child: Text(e.$2))).toList(),
                onChanged: (v) => setState(() => _vehicleType = v),
                validator: (v) => v == null ? 'Select your vehicle type' : null),
              const SizedBox(height: 18),
              _buildLabel('Plate Number'),
              const SizedBox(height: 8),
              _buildTextField(controller: _plateCtrl, hint: 'e.g. 3-12345',
                prefixIcon: Icons.pin_outlined, textCapitalization: TextCapitalization.characters,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your plate number' : null),
              const SizedBox(height: 18),
              _buildLabel('Vehicle Color'),
              const SizedBox(height: 8),
              _buildTextField(controller: _colorCtrl, hint: 'e.g. Blue',
                prefixIcon: Icons.palette_outlined, textCapitalization: TextCapitalization.words,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter vehicle color' : null),
              const SizedBox(height: 18),
              _buildLabel('Vehicle Model / Year'),
              const SizedBox(height: 8),
              _buildTextField(controller: _modelCtrl, hint: 'e.g. Bajaj RE 2022',
                prefixIcon: Icons.build_outlined, textCapitalization: TextCapitalization.words),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Container(width: 36, height: 36,
                      decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.15), shape: BoxShape.circle),
                      child: const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.accent)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your account will be reviewed by the admin team before activation.',
                        style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              if (auth.errorMessage != null) ...[
                const SizedBox(height: 16),
                _errorBox(auth.errorMessage!),
              ],
              const SizedBox(height: 28),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: auth.isLoading ? null : _prevStep,
                    icon: const Icon(Icons.arrow_back_rounded, size: 16),
                    label: Text('Back', style: GoogleFonts.outfit()),
                    style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _GradientButton(label: 'Submit Registration', isLoading: auth.isLoading, onTap: auth.isLoading ? null : _submit)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(text,
    style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w400,
      color: AppColors.textSecondary, letterSpacing: 0.3));

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
      style: GoogleFonts.outfit(fontSize: 15, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.outfit(fontSize: 14, color: AppColors.textHint),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppColors.primary.withValues(alpha: 0.5), size: 20) : null,
        suffixIcon: suffixIcon != null ? Padding(padding: const EdgeInsets.only(right: 12), child: suffixIcon) : null,
        suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        filled: true, fillColor: AppColors.inputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border, width: 1)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.error, width: 1)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.error, width: 2)),
        errorStyle: GoogleFonts.outfit(fontSize: 12),
      ),
    );
  }

  Widget _dateField({required String hint, required DateTime? value, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: value != null ? AppColors.primary : AppColors.border, width: value != null ? 2 : 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary.withValues(alpha: 0.5), size: 20),
            const SizedBox(width: 12),
            Text(
              value != null ? DateFormat('dd MMM yyyy').format(value) : hint,
              style: GoogleFonts.outfit(fontSize: 14, color: value != null ? AppColors.textPrimary : AppColors.textHint),
            ),
          ],
        ),
      ),
    );
  }

  Widget _styledDropdown<T>({
    required T? value, required String hint, required IconData prefixIcon,
    required List<DropdownMenuItem<T>> items, required void Function(T?) onChanged,
    String? Function(T?)? validator,
  }) {
    return DropdownButtonFormField<T>(
      key: ValueKey(value), initialValue: value, items: items,
      onChanged: onChanged, validator: validator,
      style: GoogleFonts.outfit(fontSize: 15, color: AppColors.textPrimary),
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textHint, size: 20),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.outfit(fontSize: 14, color: AppColors.textHint),
        prefixIcon: Icon(prefixIcon, color: AppColors.primary.withValues(alpha: 0.5), size: 20),
        filled: true, fillColor: AppColors.inputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border, width: 1)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.error, width: 1)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.error, width: 2)),
        errorStyle: GoogleFonts.outfit(fontSize: 12),
      ),
    );
  }

  Widget _errorBox(String message) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: AppColors.error.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
    ),
    child: Row(children: [
      const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 18),
      const SizedBox(width: 10),
      Expanded(child: Text(message, style: GoogleFonts.outfit(color: AppColors.error, fontSize: 13))),
    ]),
  );
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    const labels = ['Account', 'Personal', 'Vehicle'];
    return Row(
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
                        color: isDone ? AppColors.accent : isActive ? Colors.white : Colors.white30,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(labels[i],
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                        color: isDone ? AppColors.accent : isActive ? Colors.white : Colors.white38,
                      )),
                  ],
                ),
              ),
              if (i < 2) const SizedBox(width: 6),
            ],
          ),
        );
      }),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onTap;
  const _GradientButton({required this.label, required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: isLoading ? null : AppColors.primaryGradient,
          color: isLoading ? AppColors.disabled : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isLoading ? null : [
            BoxShadow(color: AppColors.primary.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 6)),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(width: 22, height: 22,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
              : Text(label, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
        ),
      ),
    );
  }
}

