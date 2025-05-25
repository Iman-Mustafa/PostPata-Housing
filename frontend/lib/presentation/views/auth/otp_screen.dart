import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/exceptions/api_exception.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../controllers/auth/auth_controller.dart';
import '../../router/route_names.dart';

class OtpScreen extends StatefulWidget {
  final String emailOrPhone;
  final bool isPhoneVerification;
  final bool isPasswordReset;

  const OtpScreen({
    super.key,
    required this.emailOrPhone,
    required this.isPhoneVerification,
    this.isPasswordReset = false,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  // Controllers
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Focus Nodes
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  // State
  bool _isLoading = false;
  bool _isVerified = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _setupOtpFields();
  }

  // Setup Methods
  void _setupOtpFields() {
    for (int i = 0; i < _focusNodes.length; i++) {
      _focusNodes[i].addListener(() {
        if (!_focusNodes[i].hasFocus && i < _focusNodes.length - 1) {
          FocusScope.of(context).requestFocus(_focusNodes[i + 1]);
        }
      });
    }
  }

  // Helper Methods
  String _getOtpCode() => _controllers.map((c) => c.text).join();

  void _showError(String message) {
    setState(() => _errorMessage = message);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  // API Methods
  Future<void> _verifyOtp() async {
    if (_getOtpCode().length != 6) {
      _showError(AppStrings.invalidOtp);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authController = context.read<AuthController>();
      await authController.verifyOtp(
        emailOrPhone: widget.emailOrPhone,
        otp: _getOtpCode(),
        isPhone: widget.isPhoneVerification,
      );

      setState(() => _isVerified = true);

      if (!widget.isPasswordReset && authController.currentUser != null) {
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(
          context,
          RouteNames.home,
          (route) => false,
        );
      }
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError(AppStrings.genericError);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resetPassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showError(AppStrings.passwordMismatch);
      return;
    }

    if (_newPasswordController.text.length < 6) {
      _showError(AppStrings.passwordLength);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authController = context.read<AuthController>();
      await authController.resetPassword(
        emailOrPhone: widget.emailOrPhone,
        newPassword: _newPasswordController.text,
        isPhone: widget.isPhoneVerification,
      );

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        RouteNames.login,
        (route) => false,
      );
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError(AppStrings.genericError);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resendOtp() async {
    setState(() => _isLoading = true);

    try {
      final authController = context.read<AuthController>();
      await authController.requestPasswordReset(
        emailOrPhone: widget.emailOrPhone,
        isPhone: widget.isPhoneVerification,
      );
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.otpResent))
      );
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError(AppStrings.genericError);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.otpVerification)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              AppStrings.otpSent.replaceAll('%s', widget.emailOrPhone),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            if (!_isVerified) _buildOtpFields(),
            if (_isVerified && widget.isPasswordReset) 
              _buildPasswordResetFields(),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpFields() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(6, (index) => _buildOtpField(index)),
        ),
        const SizedBox(height: 30),
        PrimaryButton(
          text: AppStrings.verify,
          isLoading: _isLoading,
          onPressed: _verifyOtp,
        ),
        TextButton(
          onPressed: _isLoading ? null : _resendOtp,
          child: Text(AppStrings.resendOtp),
        ),
      ],
    );
  }

  Widget _buildOtpField(int index) {
    return SizedBox(
      width: 45,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        decoration: const InputDecoration(
          counterText: '',
          border: OutlineInputBorder(),
        ),
        onChanged: (value) => _handleOtpFieldChange(index, value),
      ),
    );
  }

  void _handleOtpFieldChange(int index, String value) {
    if (value.length == 1 && index < 5) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    }
    if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }
  }

  Widget _buildPasswordResetFields() {
    return Column(
      children: [
        TextField(
          controller: _newPasswordController,
          decoration: InputDecoration(
            labelText: AppStrings.password,
            prefixIcon: const Icon(Icons.lock),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _confirmPasswordController,
          decoration: InputDecoration(
            labelText: AppStrings.confirmPassword,
            prefixIcon: const Icon(Icons.lock),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 30),
        PrimaryButton(
          text: AppStrings.resetPassword,
          isLoading: _isLoading,
          onPressed: _resetPassword,
        ),
      ],
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}