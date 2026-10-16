import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/models/user_model.dart';
import 'package:dio/dio.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(Dio());
});

final userProfileProvider = FutureProvider.family<UserModel, String>((ref, slug) async {
  final api = ref.read(apiServiceProvider);
  return api.getProfile(slug);
});

final userProjectsProvider = FutureProvider.family<List<dynamic>, String>((ref, slug) async {
  final api = ref.read(apiServiceProvider);
  return api.getProjects(slug);
});

final userSkillsProvider = FutureProvider.family<List<dynamic>, String>((ref, slug) async {
  final api = ref.read(apiServiceProvider);
  return api.getSkills(slug);
});