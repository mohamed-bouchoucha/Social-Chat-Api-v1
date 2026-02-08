import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_chat_app/features/auth/data/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});