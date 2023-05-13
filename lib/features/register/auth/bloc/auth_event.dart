part of 'auth_bloc.dart';

/// generic event for the [AuthBloc]
@immutable
abstract class AuthEvent {
  const AuthEvent();
}

/// first event to initialize the [AuthBloc]
@immutable
class AuthEventInitial implements AuthEvent {
  const AuthEventInitial();
}

/// event added by user to verify send otp to phone
@immutable
class AuthEventSendOtpToPhone implements AuthEvent {
  const AuthEventSendOtpToPhone({required this.phoneNumber});
  final String phoneNumber;
  @override
  bool operator ==(covariant AuthEventSendOtpToPhone other) {
    if (identical(this, other)) return true;
    return other.phoneNumber == phoneNumber;
  }

  @override
  int get hashCode => phoneNumber.hashCode;
}

/// event added by [AuthBloc] when otp is sent to phone
@immutable
class AuthEventOtpSent implements AuthEvent {
  const AuthEventOtpSent({
    required this.verificationId,
    required this.otpCode,
  });
  final String verificationId;
  final String otpCode;
  @override
  bool operator ==(covariant AuthEventOtpSent other) {
    if (identical(this, other)) return true;
    return other.verificationId == verificationId && other.otpCode == otpCode;
  }

  @override
  int get hashCode => verificationId.hashCode ^ otpCode.hashCode;
}

/// event added by user to verify phone number with otp code
@immutable
class AuthEventVerifyPhoneNumber implements AuthEvent {
  const AuthEventVerifyPhoneNumber({
    required this.verificationId,
    required this.otpCode,
  });

  final String verificationId;
  final String otpCode;
}

/// event to sign in a user with google account
@immutable
class AuthEventSignInWithGoogle implements AuthEvent {
  const AuthEventSignInWithGoogle();
}

/// event to sign in a user with apple account
@immutable
class AuthEventSignInWithApple implements AuthEvent {
  const AuthEventSignInWithApple();
}

/// event so sign in a user anonymously
@immutable
class AuthEventSignInAnonymously implements AuthEvent {
  const AuthEventSignInAnonymously();
}

/// event to sign out a user
@immutable
class AuthEventSignOut implements AuthEvent {
  const AuthEventSignOut();
}

/// event triggered when the state of the user is changed
@immutable
class AuthEventStateChanged implements AuthEvent {
  const AuthEventStateChanged();
}

/// event to delete the account of the user
@immutable
class AuthEventDeleteAccount implements AuthEvent {
  const AuthEventDeleteAccount({required this.user});
  final User user;
}

/// event to update the user data
@immutable
class AuthEventUserDataUpdated implements AuthEvent {
  const AuthEventUserDataUpdated({required this.user});
  final User user;
  @override
  bool operator ==(covariant AuthEventUserDataUpdated other) {
    if (identical(this, other)) return true;
    return other.user == user;
  }

  @override
  int get hashCode => Object.hashAll(
        [
          user.uid,
          user.displayName,
          user.phoneNumber,
          user.photoURL,
          user.isAnonymous,
        ],
      );
}

