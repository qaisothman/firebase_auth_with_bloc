import 'dart:async';
import 'dart:convert' show utf8;
import 'dart:developer';
import 'dart:math' show Random;

import 'package:auth_with_bloc/features/register/auth/bloc/auth_bloc.dart';
import 'package:auth_with_bloc/features/register/register.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart' show sha256;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart'
    show AppleIDAuthorizationScopes, SignInWithApple;

const _userCollection = 'users';

/// singleton repository for the AuthBloc
class AuthRepo {
  AuthRepo._();

  /// public instance of [AuthRepo]
  static final AuthRepo instance = AuthRepo._();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// get [FirebaseAuth] user data from [FirebaseFirestore] if it exists
  Future<void> checkSignedInUser(
    AuthEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      // get the current [_firebaseAuth] user
      await _firebaseAuth.currentUser?.reload();
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        emit(
          AuthStateSignedIn(
            isLoading: false,
            user: user,
          ),
        );
        return;
      }
      emit(
        const AuthStateSignedOut(
          isLoading: false,
        ),
      );
    } on FirebaseAuthException catch (e) {
      emit(
        AuthStateSignedOut(
          isLoading: false,
          authError: AuthError.from(e),
        ),
      );
    } catch (e) {
      emit(
        const AuthStateSignedOut(
          isLoading: false,
          authError: AuthErrorUnknown(),
        ),
      );
    }
  }

  /// signs in the user using [PhoneAuthCredential]
  /// sends an OTP to the user's phone number
  FutureOr<void> sendOtp({
    required AuthEventSendOtpToPhone event,
    required Emitter<AuthState> emit,
    required AuthBloc bloc,
  }) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: event.phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {
          log('verification completed');
        },
        codeSent: (String verificationId, int? resendToken) {
          bloc.add(
            AuthEventOtpSent(
              verificationId: verificationId,
              otpCode: resendToken.toString(),
            ),
          );
        },
        verificationFailed: (FirebaseAuthException e) {},
        codeAutoRetrievalTimeout: (String verificationId) {},
        timeout: const Duration(seconds: 120),
      );
    } on FirebaseAuthException catch (e) {
      emit(
        AuthStateIsInOTPPage(
          isLoading: false,
          authError: AuthError.from(e),
        ),
      );
    } catch (e) {
      emit(
        const AuthStateIsInOTPPage(
          isLoading: true,
          authError: AuthErrorUnknown(),
        ),
      );
    }
  }

  /// verifies the phone number using the verification id and the otp code
  FutureOr<void> onOtpSent({
    required AuthEventOtpSent event,
    required Emitter<AuthState> emit,
  }) async {
    emit(
      AuthStateIsInOTPPage(
        isLoading: false,
        otpCode: event.otpCode,
        verificationId: event.verificationId,
      ),
    );
  }

  /// signs in the user using [PhoneAuthCredential]
  FutureOr<void> signInWithPhoneNumber(
    AuthEventVerifyPhoneNumber event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      const AuthStateIsInOTPPage(
        isLoading: true,
      ),
    );
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: event.verificationId,
        smsCode: event.otpCode,
      );
      await _firebaseAuth.signInWithCredential(credential);
      await checkSignedInUser(event, emit);
    } on FirebaseAuthException catch (e) {
      emit(AuthStateSignedOut(isLoading: false, authError: AuthError.from(e)));
    } catch (e) {
      emit(
        const AuthStateSignedOut(
          isLoading: false,
          authError: AuthErrorUnknown(),
        ),
      );
    }
  }

  /// sign user in using [GoogleSignIn]
  Future<void> signInWithGoogle(
    AuthEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      // get auth data from google sign in
      final googleUser = await _googleSignIn
          .signIn()
          .catchError((_) => throw Exception('error signing in with google'));
      final googleAuth = await googleUser?.authentication;
      if (googleAuth == null) return;

      // create a [GoogleAuthProvider] credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      emit(
        const AuthStateSignedOut(
          isLoading: true,
        ),
      );

      // sign in with the credential
      await _firebaseAuth.signInWithCredential(credential);
      await checkSignedInUser(event, emit);
    } on FirebaseAuthException catch (e) {
      emit(
        AuthStateSignedOut(
          isLoading: false,
          authError: AuthError.from(e),
        ),
      );
    } catch (e) {
      emit(
        const AuthStateSignedOut(
          isLoading: false,
          authError: AuthErrorUnknown(),
        ),
      );
    }
  }

  /// signs in the user using [SignInWithApple]
  Future<void> signInWithApple(
    AuthEvent event,
    Emitter<AuthState> emit,
  ) async {
    final rawNonce = _generateNonce();
    final nonce = _sha256ofString(rawNonce);
    try {
      // get the [AppleIDCredential] from [SignInWithApple]
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );
      // create an [OAuthCredential] from the [AppleIDCredential]
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );
      emit(
        const AuthStateSignedOut(
          isLoading: true,
        ),
      );

      // sign in with the [OAuthCredential]
      await _firebaseAuth.signInWithCredential(oauthCredential);
      await checkSignedInUser(event, emit);
    } on FirebaseAuthException catch (e) {
      emit(
        AuthStateSignedOut(
          isLoading: false,
          authError: AuthError.from(e),
        ),
      );
    } catch (e) {
      emit(
        const AuthStateSignedOut(
          isLoading: false,
          authError: AuthErrorUnknown(),
        ),
      );
    }
  }

  /// signs in the user anonymously
  Future<void> signInAnonymously(
    AuthEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(
        const AuthStateSignedOut(
          isLoading: true,
        ),
      );
      await _firebaseAuth.signInAnonymously();
      await checkSignedInUser(event, emit);
      return;
    } on FirebaseAuthException catch (e) {
      emit(
        AuthStateSignedOut(
          isLoading: false,
          authError: AuthError.from(e),
        ),
      );
    } catch (e) {
      emit(
        const AuthStateSignedOut(
          isLoading: false,
          authError: AuthErrorUnknown(),
        ),
      );
    }
  }

  /// signs out the user from [FirebaseAuth]
  Future<void> signOut({
    required AuthEvent event,
    required Emitter<AuthState> emit,
    required AuthBloc bloc,
  }) async {
    final user = bloc.state.user;
    if (user != null) {
      emit(
        AuthStateSignedIn(
          isLoading: true,
          user: user,
        ),
      );
    }
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null && user.isAnonymous) {
        await user.delete();
      }
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
      emit(const AuthStateSignedOut(isLoading: false));
      return;
    } on FirebaseAuthException catch (e) {
      if (user != null) {
        emit(
          AuthStateSignedIn(isLoading: false, user: user),
        );
        return;
      }
      emit(
        AuthStateSignedOut(
          isLoading: false,
          authError: AuthError.from(e),
        ),
      );
    } catch (e) {
      if (user != null) {
        emit(
          AuthStateSignedIn(
            isLoading: false,
            user: user,
          ),
        );
        return;
      }
      emit(
        const AuthStateSignedOut(
          isLoading: false,
          authError: AuthErrorUnknown(),
        ),
      );
    }
  }

 

  String _generateNonce() {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    log(charset);
    final random = Random.secure();
    return List.generate(32, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  FutureOr<Map<String, dynamic>?> _getUserData(String uid) async {
    try {
      return await _firestore.collection(_userCollection).doc(uid).get().then(
            (value) => value.exists ? value.data() : null,
          );
    } catch (e) {
      return null;
    }
  }
}
