import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_chat_app/features/chat/data/repositories/chat_repository.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});