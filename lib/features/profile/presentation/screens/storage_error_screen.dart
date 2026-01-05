import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:khel_mitra/features/profile/presentation/bloc/profile_bloc.dart';

class StorageErrorScreen extends StatelessWidget {
  final double freeSpaceMb;
  const StorageErrorScreen({super.key, required this.freeSpaceMb});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sd_storage_outlined, size: 64, color: Colors.red),
            const Gap(16),
            const Text(
              "Storage Full",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const Gap(8),
            Text(
              "We found only ${freeSpaceMb.toStringAsFixed(1)} MB available.\nMinimum 500 MB is required to record video evidence.",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const Gap(32),
            ElevatedButton(
              onPressed: () {
                context.read<ProfileBloc>().add(RetryStorageCheck());
              },
              child: const Text("I have cleared space, Retry"),
            )
          ],
        ),
      ),
    );
  }
}
