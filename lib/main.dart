import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khel_mitra/core/di/injection.dart';
import 'package:khel_mitra/features/auth/domain/auth_repository.dart';
import 'package:khel_mitra/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:khel_mitra/features/profile/domain/profile_repository.dart';
import 'package:khel_mitra/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:khel_mitra/features/profile/presentation/screens/root_wrapper.dart';
import 'package:khel_mitra/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with explicit options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Configure dependencies
  configureDependencies();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(getIt<AuthRepository>())
            ..add(CheckAuthStatus()),
        ),
        BlocProvider(
          create: (context) => ProfileBloc(getIt<ProfileRepository>()),
        ),
      ],
      child: MaterialApp(
        title: 'Khel Mitra',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const RootWrapper(),
      ),
    );
  }
}
