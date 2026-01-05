import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:khel_mitra/features/profile/domain/profile_repository.dart';

// Events
abstract class ProfileEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class CheckProfileStatus extends ProfileEvent {}
class SubmitProfile extends ProfileEvent {
  final String name;
  final DateTime dob;
  final String gender;
  final double heightCm;

  SubmitProfile({required this.name, required this.dob, required this.gender, required this.heightCm});
}
class RetryStorageCheck extends ProfileEvent {}

// States
abstract class ProfileState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}
class ProfileLoading extends ProfileState {}
class ProfileIncomplete extends ProfileState {} // Show Form
class ProfileComplete extends ProfileState { // Show Calibration/Home
  final bool lowStorage;
  final double freeSpaceMb;

  ProfileComplete({required this.lowStorage, required this.freeSpaceMb});
  
  @override
  List<Object?> get props => [lowStorage, freeSpaceMb];
}
class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}

// Bloc
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _repo;

  ProfileBloc(this._repo) : super(ProfileInitial()) {
    on<CheckProfileStatus>((event, emit) async {
      emit(ProfileLoading());
      final isComplete = await _repo.isProfileComplete();
      
      if (!isComplete) {
        emit(ProfileIncomplete());
      } else {
        await _checkStorage(emit);
      }
    });

    on<SubmitProfile>((event, emit) async {
      emit(ProfileLoading());
      try {
        await _repo.saveProfile(
          name: event.name,
          dob: event.dob,
          gender: event.gender,
          heightCm: event.heightCm,
        );
        await _checkStorage(emit);
      } catch (e) {
        emit(ProfileError("Failed to save profile"));
      }
    });

    on<RetryStorageCheck>((event, emit) async {
       emit(ProfileLoading());
       await _checkStorage(emit);
    });
  }

  Future<void> _checkStorage(Emitter<ProfileState> emit) async {
    final freeSpace = await _repo.getDiskSpaceFreeMb() ?? 0;
    // Hard check: < 500MB
    final lowStorage = freeSpace < 500;
    emit(ProfileComplete(lowStorage: lowStorage, freeSpaceMb: freeSpace));
  }
}
