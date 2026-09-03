import 'package:flutter/material.dart';
import '../constants.dart';
import '../services/local_auth_service.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _petNameController = TextEditingController();
  final _authService = LocalAuthService();
  bool _loading = false;
  bool _resetSent = false;
  String? _errorMessage;
  String? _resetCode;

  @override
  void dispose() {
    _petNameController.dispose();
    super.dispose();
  }

  void _handleSendReset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final petName = _petNameController.text.trim();
    final user = await _authService.getUserByPetName(petName);

    if (!mounted) return;

    if (user == null) {
      setState(() {
        _loading = false;
        _errorMessage = 'No account found for that pet name.';
      });
      return;
    }

    // Generate reset code (6-digit random code)
    final resetCode =
        (100000 + (DateTime.now().millisecondsSinceEpoch % 900000)).toString();

    final success = await _authService.setPasswordResetCode(petName, resetCode);

    if (!mounted) return;

    if (success) {
      setState(() {
        _loading = false;
        _resetSent = true;
        _resetCode = resetCode;
      });
      // In production, send this code via email or SMS
      debugPrint('Password reset code for $petName: $resetCode');
    } else {
      setState(() {
        _loading = false;
        _errorMessage = 'Failed to generate reset code. Try again.';
      });
    }
  }

  void _handleResetWithCode() async {
    showDialog(
      context: context,
      builder: (context) => _ResetPasswordDialog(
        petName: _petNameController.text.trim(),
        expectedCode: _resetCode ?? '',
        authService: _authService,
        onSuccess: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Password reset successfully! Please log in.')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppGradients.loginBackground),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon:
                        const Icon(Icons.arrow_back, color: AppColors.textDark),
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      gradient: AppGradients.logoBadge,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock_reset,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Reset password',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Enter your pet's name and we'll help you reset your password.",
                    style: TextStyle(color: AppColors.textGrey, fontSize: 14.5),
                  ),
                  const SizedBox(height: 32),
                  if (_errorMessage != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.dangerRedBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: AppColors.dangerRed,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  if (_resetSent)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.safeGreenLight,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.check_circle,
                                  color: AppColors.safeGreen),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Reset code generated!',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.safeGreen,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Your reset code: $_resetCode',
                                      style: const TextStyle(
                                        color: AppColors.safeGreen,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: _handleResetWithCode,
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.safeGreen,
                              ),
                              child: const Text('Enter New Password'),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Column(
                      children: [
                        TextFormField(
                          controller: _petNameController,
                          decoration: InputDecoration(
                            hintText: "Your pet's name",
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return "Please enter your pet's name";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _loading ? null : _handleSendReset,
                            child: _loading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : const Text('Send Reset Code'),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Back to Login',
                        style: TextStyle(color: AppColors.textGrey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResetPasswordDialog extends StatefulWidget {
  final String petName;
  final String expectedCode;
  final LocalAuthService authService;
  final VoidCallback onSuccess;

  const _ResetPasswordDialog({
    required this.petName,
    required this.expectedCode,
    required this.authService,
    required this.onSuccess,
  });

  @override
  State<_ResetPasswordDialog> createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends State<_ResetPasswordDialog> {
  final _resetCodeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _resetCodeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleReset() async {
    if (_resetCodeController.text != widget.expectedCode) {
      setState(() => _error = 'Invalid reset code');
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() => _error = 'Passwords do not match');
      return;
    }
    if (_newPasswordController.text.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters');
      return;
    }

    setState(() => _loading = true);

    final success = await widget.authService.resetPassword(
      petName: widget.petName,
      newPassword: _newPasswordController.text,
    );

    if (mounted) {
      if (success) {
        widget.onSuccess();
      } else {
        setState(() => _error = 'Failed to reset password');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reset Password'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _resetCodeController,
              decoration: InputDecoration(
                hintText: 'Enter reset code',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _newPasswordController,
              obscureText: !_showNewPassword,
              decoration: InputDecoration(
                hintText: 'New password (min 6 chars)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[100],
                suffixIcon: IconButton(
                  icon: Icon(_showNewPassword
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: () =>
                      setState(() => _showNewPassword = !_showNewPassword),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmPasswordController,
              obscureText: !_showConfirmPassword,
              decoration: InputDecoration(
                hintText: 'Confirm password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[100],
                suffixIcon: IconButton(
                  icon: Icon(_showConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: () => setState(
                      () => _showConfirmPassword = !_showConfirmPassword),
                ),
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _loading ? null : _handleReset,
          child: _loading
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Reset'),
        ),
      ],
    );
  }
}
