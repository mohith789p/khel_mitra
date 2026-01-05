import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:khel_mitra/features/auth/presentation/bloc/auth_bloc.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  const OtpScreen({super.key, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify OTP")),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
           if (state is AuthAuthenticated) {
             // Let the main navigator handle the switch, just pop this or do nothing
             // Actually, since we use BlocBuilder in Main, we just need to pop back to root
             // But Main will rebuild and switch to Home.
             Navigator.of(context).popUntil((route) => route.isFirst);
          } else if (state is AuthError) {
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
           if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Gap(32),
                Text(
                  "Enter OTP sent to +91 ${widget.phoneNumber}",
                  style: const TextStyle(fontSize: 16),
                ),
                const Gap(24),
                TextField(
                  controller: _otpController,
                  decoration: const InputDecoration(
                    labelText: "OTP",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const Gap(24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    final otp = _otpController.text;
                    if (otp.length == 6) {
                      context.read<AuthBloc>().add(VerifyOtp(widget.phoneNumber, otp));
                    }
                  },
                  child: const Text("Verify"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
