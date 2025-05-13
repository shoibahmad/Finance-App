import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String? initialEmail;
  const ForgotPasswordScreen({Key? key, this.initialEmail}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail != null && widget.initialEmail!.isNotEmpty) {
      _emailController.text = widget.initialEmail!;
    }
  }

  Future<void> _sendPasswordResetEmail() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      if (mounted) {
        setState(() {
          _successMessage =
              'Password reset link sent to ${_emailController.text.trim()}. Please check your inbox (and spam folder).';
          _emailController.clear();
        });
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String message;
        switch (e.code) {
          case 'invalid-email':
            message = 'The email address is badly formatted.';
            break;
          case 'user-not-found':
            // For security, Firebase might not reveal if the user exists.
            // It's often better to show a generic success-like message.
            message = 'If this email is registered, a reset link will be sent.';
             _successMessage = 'If this email is registered, a reset link will be sent to ${_emailController.text.trim()}.';
            break;
          default:
            message = e.message ?? "Failed to send reset email. Please check the email address.";
        }
        setState(() {
          _errorMessage = (e.code != 'user-not-found') ? message : null; // Only show error if not 'user-not-found'
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "An unexpected error occurred. Please try again.";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label, String hint, IconData prefixIcon, ThemeData theme) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(prefixIcon, color: theme.primaryColor.withOpacity(0.7), size: 22),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
      ),
      filled: true,
      fillColor: theme.colorScheme.surface.withOpacity(0.9),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.primaryColor, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text('Reset Password',
            style: TextStyle(
                color: theme.appBarTheme.foregroundColor ??
                    (ThemeData.estimateBrightnessForColor(primaryColor) == Brightness.dark
                        ? Colors.white
                        : Colors.black))),
        backgroundColor: primaryColor,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: theme.appBarTheme.iconTheme?.color ?? (ThemeData.estimateBrightnessForColor(primaryColor) == Brightness.dark
                        ? Colors.white
                        : Colors.black)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Icon(Icons.password_rounded, size: 70, color: primaryColor),
                  const SizedBox(height: 20),
                  Text(
                    'Forgot Password?',
                    textAlign: TextAlign.center,
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Enter your email address below. If an account exists, we\'ll send a link to reset your password.',
                    textAlign: TextAlign.center,
                    style: textTheme.titleSmall?.copyWith(
                      color: Colors.grey.shade600,
                      height: 1.45
                    ),
                  ),
                  const SizedBox(height: 40),

                  TextFormField(
                    controller: _emailController,
                    decoration: _inputDecoration('Email Address', 'you@example.com', Icons.alternate_email_rounded, theme),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 25),

                  if (_successMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        _successMessage!,
                        style: textTheme.bodyMedium?.copyWith(
                            color: Colors.green.shade700, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        _errorMessage!,
                        style: textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.error, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  _isLoading
                      ? Center(child: CircularProgressIndicator(color: primaryColor))
                      : ElevatedButton(
                          onPressed: _sendPasswordResetEmail,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5),
                            minimumSize: const Size.fromHeight(52),
                            elevation: 2,
                          ),
                          child: const Text('Send Reset Link'),
                        ),
                  const SizedBox(height: 20),
                   TextButton(
                    onPressed: _isLoading ? null : () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Back to Login',
                       style: textTheme.bodyMedium?.copyWith(color: primaryColor, fontWeight: FontWeight.w500),
                    ),
                   ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}