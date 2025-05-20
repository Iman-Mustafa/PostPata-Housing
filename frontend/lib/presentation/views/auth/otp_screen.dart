// lib/presentation/views/auth/otp_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../controllers/auth/auth_controller.dart';
import '../../router/route_names.dart';

class OtpScreen extends StatefulWidget {
  final String emailOrPhone;
  final bool isPhoneVerification;

  const OtpScreen({
    super.key,
    required this.emailOrPhone,
    required this.isPhoneVerification,
  });

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _setupOtpFields();
  }

  void _setupOtpFields() {
    for (int i = 0; i < _focusNodes.length; i++) {
      _focusNodes[i].addListener(() {
        if (!_focusNodes[i].hasFocus && i < _focusNodes.length - 1) {
          FocusScope.of(context).requestFocus(_focusNodes[i + 1]);
        }
      });
    }
  }

  String _getOtpCode() {
    return _controllers.map((c) => c.text).join();
  }

  Future<void> _verifyOtp() async {
    if (_getOtpCode().length != 6) return;

    setState(() => _isLoading = true);
    
    try {
      final authController = context.read<AuthController>();
      await authController.verifyOtp(
        emailOrPhone: widget.emailOrPhone,
        otp: _getOtpCode(),
        isPhone: widget.isPhoneVerification,
      );
      
      if (authController.currentUser != null) {
        Navigator.pushNamedAndRemoveUntil(
          context, 
          RouteNames.home, 
          (route) => false,
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOtp() async {
    final authController = context.read<AuthController>();
    await authController.login(
      emailOrPhone: widget.emailOrPhone,
      password: '', // Not needed for OTP resend
      isPhone: widget.isPhoneVerification,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppStrings.resendOtp)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.otpVerification)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              AppStrings.otpSent.replaceAll('%s', widget.emailOrPhone),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 45,
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    decoration: InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      if (value.length == 1 && index < 5) {
                        FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
                      }
                      if (value.isEmpty && index > 0) {
                        FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
                      }
                    },
                  ),
                );
              }),
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
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }
}