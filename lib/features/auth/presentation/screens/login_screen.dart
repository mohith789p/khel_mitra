import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:khel_mitra/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:khel_mitra/features/auth/presentation/screens/otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _onGetOtp() {
    if (_formKey.currentState?.validate() ?? false) {
      final phone = _phoneController.text.trim();
      context.read<AuthBloc>().add(RequestOtp(phone));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is CodeSent) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<AuthBloc>(),
                  child: OtpScreen(
                    phoneNumber: state.phoneNumber,
                    verificationId: state.verificationId,
                  ),
                ),
              ),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo/Title
                    const Icon(
                      Icons.sports_gymnastics,
                      size: 80,
                      color: Colors.deepPurple,
                    ),
                    const Gap(16),
                    const Text(
                      "Khel Mitra",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Gap(8),
                    Text(
                      "Athlete Login",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Gap(48),
                    
                    // Phone Number Field
                    TextFormField(
                      controller: _phoneController,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        labelText: "Phone Number",
                        prefixText: "+91 ",
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.phone),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        if (value.length != 10) {
                          return 'Phone number must be 10 digits';
                        }
                        if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
                          return 'Please enter a valid Indian mobile number';
                        }
                        return null;
                      },
                    ),
                    const Gap(24),
                    
                    // Get OTP Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[300],
                      ),
                      onPressed: isLoading ? null : _onGetOtp,
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              "Get OTP",
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                    const Gap(24),
                    
                    // Info text
                    Text(
                      "We'll send a verification code to your phone",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
