import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';
import '../../home/screens/home_screen.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  int _currentStep = 1;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(authProvider.notifier)
        .signUp(
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (success && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  Widget _buildPasswordRequirement(String text, bool met) {
    return Row(
      children: [
        Icon(
          met ? Icons.check_circle : Icons.circle_outlined,
          size: 14,
          color: met ? AppColors.success : AppColors.textHint,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: AppTextStyles.bodySmall.copyWith(
            color: met ? AppColors.success : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final password = _passwordController.text;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // Header
                Text('Sign Up', style: AppTextStyles.displayMedium),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Already have an account? ',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'Sign in',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Step indicator
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _currentStep == 1
                              ? Icons.person_outline
                              : Icons.lock_outline,
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _currentStep == 1
                            ? 'Personal Information'
                            : 'Secure Your Account',
                        style: AppTextStyles.headingMedium,
                      ),
                      const SizedBox(height: 8),

                      // Progress bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 3,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            width: 80,
                            height: 3,
                            decoration: BoxDecoration(
                              color: _currentStep == 2
                                  ? AppColors.primary
                                  : AppColors.divider,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Step $_currentStep of 2',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Form content
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: _currentStep == 1
                      ? _buildStep1()
                      : _buildStep2(password),
                ),

                // Error
                if (authState.errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      authState.errorMessage!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Google
                Center(
                  child: Text(
                    'or continue with',
                    style: AppTextStyles.bodySmall,
                  ),
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: 'Sign up with Google',
                  isOutlined: true,
                  onPressed: () {},
                ),

                const SizedBox(height: 24),

                // Navigation buttons
                Row(
                  children: [
                    if (_currentStep == 2) ...[
                      Expanded(
                        child: AppButton(
                          label: 'Back',
                          isOutlined: true,
                          onPressed: () {
                            setState(() => _currentStep = 1);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    Expanded(
                      child: AppButton(
                        label: _currentStep == 1 ? 'Continue' : 'Sign Up',
                        isLoading: authState.isLoading,
                        onPressed: () {
                          if (_currentStep == 1) {
                            if (_nameController.text.isNotEmpty &&
                                _emailController.text.isNotEmpty) {
                              setState(() => _currentStep = 2);
                            }
                          } else {
                            _handleSignUp();
                          }
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      children: [
        AppTextField(
          label: 'Full Name',
          hint: 'Enter your full name',
          controller: _nameController,
          prefixIcon: Icon(
            Icons.person_outline,
            color: AppColors.textSecondary,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Name is required';
            return null;
          },
        ),
        const SizedBox(height: 20),
        AppTextField(
          label: 'Email',
          hint: 'Enter your email',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icon(
            Icons.email_outlined,
            color: AppColors.textSecondary,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Email is required';
            if (!value.contains('@')) return 'Enter a valid email';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildStep2(String password) {
    return Column(
      children: [
        AppTextField(
          label: 'Password',
          hint: 'Enter your password',
          controller: _passwordController,
          isPassword: true,
          prefixIcon: Icon(Icons.lock_outline, color: AppColors.textSecondary),
          onChanged: (_) => setState(() {}),
          validator: (value) {
            if (value == null || value.length < 8) {
              return 'Password must be at least 8 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        AppTextField(
          label: 'Confirm Password',
          hint: 'Re-enter your password',
          controller: _confirmPasswordController,
          isPassword: true,
          prefixIcon: Icon(Icons.lock_outline, color: AppColors.textSecondary),
          validator: (value) {
            if (value != _passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Password requirements
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Password Requirement', style: AppTextStyles.labelMedium),
              const SizedBox(height: 8),
              _buildPasswordRequirement(
                'At least 8 characters',
                password.length >= 8,
              ),
              const SizedBox(height: 4),
              _buildPasswordRequirement(
                'One uppercase letter',
                password.contains(RegExp(r'[A-Z]')),
              ),
              const SizedBox(height: 4),
              _buildPasswordRequirement(
                'One number',
                password.contains(RegExp(r'[0-9]')),
              ),
              const SizedBox(height: 4),
              _buildPasswordRequirement(
                'One special character',
                password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]')),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
