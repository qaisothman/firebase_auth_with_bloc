import 'package:auth_with_bloc/features/register/auth/auth_error.dart';
import 'package:auth_with_bloc/features/register/auth/bloc/auth_repo.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// there is no singleton that save the current [User]
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  /// [AuthBloc] handles the authentication state of the user
  /// [User] data is always saved in the current [AuthState]
  /// [AuthState] updates depending on the [AuthEvent]s by the [User]

  AuthBloc()
      : super(
          /// initial state of the [AuthBloc]
          const AuthStateSignedOut(isLoading: true),
        ) {
    /// event triggered when the [AuthBloc] is initialized
    on<AuthEventInitial>(AuthRepo.instance.checkSignedInUser);

    /// event triggered when user enter phone number and click sign in
    /// this event will send an OTP to the phone number and navigate to
    /// the OTP verification page
    on<AuthEventSendOtpToPhone>(
      (event, emit) => AuthRepo.instance.sendOtp(
        event: event,
        emit: emit,
        bloc: this,
      ),
    );

    /// event triggered when user enters the OTP and wants to verify it
    on<AuthEventOtpSent>(
      (event, emit) => AuthRepo.instance.onOtpSent(event: event, emit: emit),
    );
    on<AuthEventVerifyPhoneNumber>(
      AuthRepo.instance.signInWithPhoneNumber,
    );
    on<AuthEventSignInWithGoogle>(AuthRepo.instance.signInWithGoogle);
    on<AuthEventSignInWithApple>(AuthRepo.instance.signInWithApple);
    on<AuthEventSignInAnonymously>(AuthRepo.instance.signInAnonymously);

    /// event triggered when user wants to log out
    on<AuthEventSignOut>(
      (event, emit) => AuthRepo.instance.signOut(
        event: event,
        emit: emit,
        bloc: this,
      ),
    );

    on<AuthEventStateChanged>(
      AuthRepo.instance.checkSignedInUser,
    );


    /// event triggered when user wants to delete their account
    on<AuthEventDeleteAccount>(
      (event, emit) async {
        final user = FirebaseAuth.instance.currentUser;
        // if current user is null, then we are already logged out
        if (user == null) {
          emit(
            const AuthStateSignedOut(
              isLoading: false,
            ),
          );
          return;
        }
        try {
          await user.delete();
          await FirebaseAuth.instance.signOut();

          emit(
            const AuthStateSignedOut(
              isLoading: false,
            ),
          );
        } on FirebaseAuthException {
          emit(
            const AuthStateSignedOut(
              isLoading: false,
            ),
          );
        }
      },
    );
    _authStream = FirebaseAuth.instance.authStateChanges()
      ..listen((user) {
        if (user == null) {
          add(const AuthEventStateChanged());
        }
      });
   
  }

  late final Stream<User?> _authStream;

  /// [AuthBloc] of the current [BuildContext]
  static AuthBloc of(BuildContext context) =>
      BlocProvider.of<AuthBloc>(context);
}
