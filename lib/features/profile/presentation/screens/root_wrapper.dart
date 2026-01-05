import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khel_mitra/features/assessment/calibration_screen.dart';
import 'package:khel_mitra/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:khel_mitra/features/auth/presentation/screens/login_screen.dart';
import 'package:khel_mitra/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:khel_mitra/features/profile/presentation/screens/profile_form_screen.dart';
import 'package:khel_mitra/features/profile/presentation/screens/storage_error_screen.dart';

class RootWrapper extends StatelessWidget {
  const RootWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        // Only proceed to profile/home if fully authenticated
        if (authState is AuthAuthenticated) {
          return BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, profileState) {
              if (profileState is ProfileInitial) {
                 context.read<ProfileBloc>().add(CheckProfileStatus());
                 return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              
              if (profileState is ProfileLoading) {
                 return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }

              if (profileState is ProfileIncomplete) {
                return const ProfileFormScreen();
              }

              if (profileState is ProfileComplete) {
                if (profileState.lowStorage) {
                  return StorageErrorScreen(freeSpaceMb: profileState.freeSpaceMb);
                } else {
                  return const CalibrationScreen();
                }
              }

              return const Scaffold(body: Center(child: Text("Unknown State")));
            },
          );
        }
        
        // For ALL other states (Initial, Loading, CodeSent, Error, Unauthenticated)
        // show the LoginScreen. LoginScreen handles its own internal navigation to OTP.
        return const LoginScreen();
      },
    );
  }
}
