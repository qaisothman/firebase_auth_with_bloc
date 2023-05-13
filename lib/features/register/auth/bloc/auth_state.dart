// ignore_for_file: public_member_api_docs, sort_constructors_first

part of 'auth_bloc.dart';

/// generic state for the [AuthBloc]
@immutable
abstract class AuthState extends Equatable {
  /// constructor of [AuthState]
  const AuthState({
    required this.isLoading,
    this.authError,
  });

  /// if the state is loading
  final bool isLoading;

  /// if there is an error
  final AuthError? authError;
}

/// state emitted when the [AuthBloc] is initialized
@immutable
class AuthStateInit extends AuthState {
  /// constructor of [AuthStateInit]
  const AuthStateInit({
    required super.isLoading,
    super.authError,
  });

  @override
  List<Object?> get props => [isLoading, authError];
}

/// state emitted when the user is authenticated then signed in
@immutable
class AuthStateSignedIn extends AuthState {
  /// constructor of [AuthStateSignedIn]
  const AuthStateSignedIn({
    required super.isLoading,
    required this.user,
    this.redirectToNotifications = false,
    super.authError,
  });

  /// [User] object of the signed in user
  final User user;
  final bool redirectToNotifications;

  @override
  String toString() =>
      '''AppStateSignedIn, isLoading = $isLoading, user = $user, redirectToNotifications = $redirectToNotifications,''';

  @override
  List<Object?> get props => [
        isLoading,
        user,
        authError,
        redirectToNotifications,
      ];
}

/// state emitted when the user is not signed in
@immutable
class AuthStateSignedOut extends AuthState {
  /// constructor of [AuthStateSignedOut]
  const AuthStateSignedOut({
    required super.isLoading,
    super.authError,
  });

  @override
  String toString() =>
      'AppStateSignedOut, isLoading = $isLoading, authError = $authError';

  @override
  List<Object?> get props => [
        isLoading,
        authError,
      ];
}

@immutable
class AuthStateIsInOTPPage extends AuthState {
  /// constructor of [AuthStateIsInOTPPage]
  const AuthStateIsInOTPPage({
    required super.isLoading,
    this.otpCode,
    this.verificationId,
    super.authError,
    this.phoneNumber,
  });
  final String? otpCode;
  final String? verificationId;
  final String? phoneNumber;

  @override
  List<Object?> get props => [
        isLoading,
        authError,
        otpCode,
        verificationId,
        phoneNumber,
      ];
}

/// get [AuthState] internal data
extension GetAuthState on AuthState {
  /// checks if the current [AuthState] is [AuthStateSignedIn]
  /// and return the [User] object if it is not null
  User? get user {
    final state = this;
    if (state is AuthStateSignedIn) {
      return state.user;
    }
    return null;
  }

  bool get isSignedIn {
    final state = this;
    if (state is AuthStateSignedIn) {
      return true;
    }
    return false;
  }

  bool get isInSignInPage {
    final state = this;
    if (state is AuthStateIsInOTPPage) {
      return true;
    }
    return false;
  }

  String? get verificationId {
    final state = this;
    if (state is AuthStateIsInOTPPage) {
      return state.verificationId!;
    }
    return null;
  }

  bool get redirectToNotifications {
    if (isSignedIn) {
      final state = this as AuthStateSignedIn;
      return state.redirectToNotifications;
    }
    return false;
  }
}
