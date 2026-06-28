// lib/core/network/network_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';
import 'token_storage.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  final client = ApiClient(tokenStorage: tokenStorage);
  ref.onDispose(client.dispose);
  return client;
});
