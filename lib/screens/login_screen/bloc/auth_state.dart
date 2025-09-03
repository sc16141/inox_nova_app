import 'package:equatable/equatable.dart';

class AuthState extends Equatable {
  final bool isLoading;
  final String? error;
  final String? userId;

  const AuthState({
    this.isLoading = false,
    this.error,
    this.userId,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    String? userId,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      userId: userId,
    );
  }

  @override
  List<Object?> get props => [isLoading, error, userId];
}
