import 'package:dio/dio.dart';
import 'package:frontend/constants/api_config.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/models/project_model.dart';
import 'package:frontend/models/skill_model.dart';
import 'package:frontend/models/experience_model.dart';

class ApiService {
  final Dio _dio;

  ApiService(this._dio) {
    _dio.options.baseUrl = ApiConfig.baseUrl;
    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.followRedirects = true;
    _dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
    // Biarkan Dio throw untuk 4xx/5xx agar error 404 tidak masuk ke fromJson.
    // Default validateStatus sudah benar, jangan dilonggarkan ke <500.
  }

  Never _throwApiError(DioException e, String fallback) {
    final data = e.response?.data;
    String msg = fallback;
    if (data is Map && data['detail'] != null) {
      final d = data['detail'];
      msg = d is String ? d : d.toString();
    } else if (e.message != null && e.message!.isNotEmpty) {
      msg = e.message!;
    }
    throw Exception(msg);
  }

  // Public endpoints
  Future<UserModel> getProfile(String slug) async {
    try {
      final res = await _dio.get('/public/u/$slug/profile');
      if (res.data is! Map<String, dynamic>) {
        throw Exception('Respons profil tidak valid');
      }
      return UserModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _throwApiError(e, 'Profil tidak ditemukan');
    }
  }

  Future<List<ProjectModel>> getProjects(String slug, {int skip = 0, int limit = 20}) async {
    try {
      final res = await _dio.get(
        '/public/u/$slug/projects',
        queryParameters: {'skip': skip, 'limit': limit},
      );
      final list = res.data as List;
      return list.map((e) => ProjectModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      _throwApiError(e, 'Gagal memuat proyek');
    }
  }

  Future<List<SkillModel>> getSkills(String slug, {int skip = 0, int limit = 100}) async {
    try {
      final res = await _dio.get(
        '/public/u/$slug/skills',
        queryParameters: {'skip': skip, 'limit': limit},
      );
      final list = res.data as List;
      return list.map((e) => SkillModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      _throwApiError(e, 'Gagal memuat skill');
    }
  }

  Future<List<ExperienceModel>> getExperiences(String slug, {int skip = 0, int limit = 50}) async {
    try {
      final res = await _dio.get(
        '/public/u/$slug/experiences',
        queryParameters: {'skip': skip, 'limit': limit},
      );
      final list = res.data as List;
      return list.map((e) => ExperienceModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      _throwApiError(e, 'Gagal memuat pengalaman');
    }
  }

  Future<MessageResponseModel> sendContact(String slug, MessageCreateModel payload) async {
    try {
      final res = await _dio.post(
        '/public/u/$slug/contact',
        data: payload.toJson(),
      );
      return MessageResponseModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _throwApiError(e, 'Gagal mengirim pesan');
    }
  }

  // ---- User dashboard (/me/*) ----
  Future<UserModel> getMyProfile() async {
    try {
      final res = await _dio.get('/me/profile');
      return UserModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _throwApiError(e, 'Gagal memuat profil saya');
    }
  }

  Future<UserModel> updateMyProfile(Map<String, dynamic> payload) async {
    try {
      final res = await _dio.put('/me/profile', data: payload);
      return UserModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _throwApiError(e, 'Gagal update profil');
    }
  }

  Future<void> setPublish(bool publish) async {
    try {
      await _dio.post(publish ? '/me/publish' : '/me/unpublish');
    } on DioException catch (e) {
      _throwApiError(e, 'Gagal ubah status publish');
    }
  }

  Future<List<ProjectModel>> listMyProjects() async {
    try {
      final res = await _dio.get('/me/projects', queryParameters: {'limit': 100});
      return (res.data as List).map((e) => ProjectModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      _throwApiError(e, 'Gagal memuat proyek saya');
    }
  }

  Future<void> deleteMyProject(int id) async {
    try {
      await _dio.delete('/me/projects/$id');
    } on DioException catch (e) {
      _throwApiError(e, 'Gagal hapus proyek');
    }
  }

  Future<List<SkillModel>> listMySkills() async {
    try {
      final res = await _dio.get('/me/skills');
      return (res.data as List).map((e) => SkillModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      _throwApiError(e, 'Gagal memuat skill saya');
    }
  }

  Future<SkillModel> createMySkill(Map<String, dynamic> payload) async {
    try {
      final res = await _dio.post('/me/skills', data: payload);
      return SkillModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _throwApiError(e, 'Gagal tambah skill');
    }
  }

  Future<void> deleteMySkill(int id) async {
    try {
      await _dio.delete('/me/skills/$id');
    } on DioException catch (e) {
      _throwApiError(e, 'Gagal hapus skill');
    }
  }

  Future<List<ExperienceModel>> listMyExperiences() async {
    try {
      final res = await _dio.get('/me/experiences');
      return (res.data as List).map((e) => ExperienceModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      _throwApiError(e, 'Gagal memuat experience');
    }
  }

  Future<List<Map<String, dynamic>>> listMyMessages() async {
    try {
      final res = await _dio.get('/me/messages');
      return (res.data as List).map((e) => e as Map<String, dynamic>).toList();
    } on DioException catch (e) {
      _throwApiError(e, 'Gagal memuat inbox');
    }
  }

  // ---- Admin (/admin/*) ----
  Future<List<UserModel>> adminListUsers() async {
    try {
      final res = await _dio.get('/admin/users');
      return (res.data as List).map((e) => UserModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      _throwApiError(e, 'Gagal memuat users (admin only)');
    }
  }

  Future<void> adminUpdateUser(int id, Map<String, dynamic> payload) async {
    try {
      await _dio.patch('/admin/users/$id', data: payload);
    } on DioException catch (e) {
      _throwApiError(e, 'Gagal update user');
    }
  }

  Future<List<Map<String, dynamic>>> adminListMessages() async {
    try {
      final res = await _dio.get('/admin/messages');
      return (res.data as List).map((e) => e as Map<String, dynamic>).toList();
    } on DioException catch (e) {
      _throwApiError(e, 'Gagal memuat semua pesan');
    }
  }

  Future<List<ProjectModel>> adminListProjects() async {
    try {
      final res = await _dio.get('/admin/projects');
      return (res.data as List).map((e) => ProjectModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      _throwApiError(e, 'Gagal memuat proyek (admin)');
    }
  }
}

// Message models (inline for simplicity)
class MessageCreateModel {
  final String senderName;
  final String senderEmail;
  final String? subject;
  final String content;

  MessageCreateModel({
    required this.senderName,
    required this.senderEmail,
    this.subject,
    required this.content,
  });

  Map<String, dynamic> toJson() => {
    'sender_name': senderName,
    'sender_email': senderEmail,
    if (subject != null) 'subject': subject,
    'content': content,
  };
}

class MessageResponseModel {
  final int id;
  final String senderName;
  final String status;

  MessageResponseModel({
    required this.id,
    required this.senderName,
    required this.status,
  });

  factory MessageResponseModel.fromJson(Map<String, dynamic> json) =>
      MessageResponseModel(
        id: (json['id'] as num).toInt(),
        senderName: json['sender_name'] as String? ?? '',
        status: json['status'] as String? ?? 'sent',
      );
}
