import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/providers/auth_providers.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/models/project_model.dart';
import 'package:frontend/models/skill_model.dart';
import 'package:frontend/models/experience_model.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  // Pakai Dio yang sama dengan AuthService agar header Bearer ikut terkirim.
  final dio = ref.watch(dioProvider);
  return ApiService(dio);
});

final userProfileProvider = FutureProvider.family<UserModel, String>((
  ref,
  slug,
) async {
  final api = ref.read(apiServiceProvider);
  return api.getProfile(slug);
});

final userProjectsProvider = FutureProvider.family<List<ProjectModel>, String>((
  ref,
  slug,
) async {
  final api = ref.read(apiServiceProvider);
  return api.getProjects(slug);
});

final userSkillsProvider = FutureProvider.family<List<SkillModel>, String>((
  ref,
  slug,
) async {
  final api = ref.read(apiServiceProvider);
  return api.getSkills(slug);
});

final userExperiencesProvider =
    FutureProvider.family<List<ExperienceModel>, String>((ref, slug) async {
      final api = ref.read(apiServiceProvider);
      return api.getExperiences(slug);
    });

// --- Dashboard (butuh login) ---
final myProfileProvider = FutureProvider<UserModel>((ref) async {
  final api = ref.read(apiServiceProvider);
  return api.getMyProfile();
});

final myProjectsProvider = FutureProvider<List<ProjectModel>>((ref) async {
  final api = ref.read(apiServiceProvider);
  return api.listMyProjects();
});

final mySkillsProvider = FutureProvider<List<SkillModel>>((ref) async {
  final api = ref.read(apiServiceProvider);
  return api.listMySkills();
});

final myExperiencesProvider = FutureProvider<List<ExperienceModel>>((
  ref,
) async {
  final api = ref.read(apiServiceProvider);
  return api.listMyExperiences();
});

final myMessagesProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final api = ref.read(apiServiceProvider);
  return api.listMyMessages();
});

final adminUsersProvider = FutureProvider<List<UserModel>>((ref) async {
  final api = ref.read(apiServiceProvider);
  return api.adminListUsers();
});

final adminMessagesProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final api = ref.read(apiServiceProvider);
  return api.adminListMessages();
});

final adminProjectsProvider = FutureProvider<List<ProjectModel>>((ref) async {
  final api = ref.read(apiServiceProvider);
  return api.adminListProjects();
});

final galleryProjectsProvider = FutureProvider<List<ProjectModel>>((ref) async {
  final api = ref.read(apiServiceProvider);
  return api.getGalleryProjects();
});

/// GET /health — status backend untuk kartu "Status platform" admin.
final adminHealthProvider = FutureProvider<bool>((ref) async {
  final api = ref.read(apiServiceProvider);
  return api.healthCheck();
});

/// GET /admin/projects?owner_id — filter proyek milik user tertentu.
final adminProjectsFilteredProvider =
    FutureProvider.family<List<ProjectModel>, int?>((ref, ownerId) async {
      final api = ref.read(apiServiceProvider);
      return api.adminListProjectsFiltered(ownerId: ownerId);
    });
