import 'package:dio/dio.dart';
import 'package:frontend/constants/api_config.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/models/project_model.dart';
import 'package:frontend/models/skill_model.dart';
import 'package:frontend/models/experience_model.dart';

/// Typed error dengan HTTP status agar UI bisa bedakan 404/429/dll
/// tanpa string-match. `implements Exception` sehingga pemanggil lama
/// yang `catch (e)` / `on Exception` tetap kompatibel.
/// `toString()` hanya pesan bersih (tanpa prefix "Exception:").
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  bool get isNotFound => statusCode == 404;
  bool get isRateLimited => statusCode == 429;

  @override
  String toString() => message;
}

class ApiService {
  final Dio _dio;

  ApiService(this._dio) {
    _dio.options.baseUrl = ApiConfig.baseUrl;
    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.followRedirects = true;
    _dio.interceptors.add(
      LogInterceptor(responseBody: true, requestBody: true),
    );
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
    throw ApiException(msg, statusCode: e.response?.statusCode);
  }

  String _uploadUrl(dynamic data) {
    if (data is Map && data['url'] is String) {
      return data['url'] as String;
    }
    throw ApiException('Respons upload tidak valid');
  }

  Future<String> _uploadMultipart(String path, MultipartFile file) async {
    try {
      final form = FormData.fromMap({'file': file});
      final res = await _dio.post(path, data: form);
      return _uploadUrl(res.data);
    } on DioException catch (e) {
      _throwApiError(e, 'Gagal upload file');
    }
  }

  // Public endpoints
  Future<UserModel> getProfile(String slug) async {
    try {
      final res = await _dio.get('/public/u/$slug/profile');
      if (res.data is! Map<String, dynamic>) {
        throw ApiException('Respons profil tidak valid');
      }
      return UserModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _throwApiError(e, 'Profil tidak ditemukan');
    }
  }

  Future<List<ProjectModel>> getProjects(
    String slug, {
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final res = await _dio.get(
        '/public/u/$slug/projects',
        queryParameters: {'skip': skip, 'limit': limit},
      );
      final list = res.data as List;
      return list
          .map((e) => ProjectModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _throwApiError(e, 'Gagal memuat proyek');
    }
  }

  Future<List<SkillModel>> getSkills(
    String slug, {
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      final res = await _dio.get(
        '/public/u/$slug/skills',
        queryParameters: {'skip': skip, 'limit': limit},
      );
      final list = res.data as List;
      return list
          .map((e) => SkillModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _throwApiError(e, 'Gagal memuat skill');
    }
  }

  Future<List<ExperienceModel>> getExperiences(
    String slug, {
    int skip = 0,
    int limit = 50,
  }) async {
    try {
      final res = await _dio.get(
        '/public/u/$slug/experiences',
        queryParameters: {'skip': skip, 'limit': limit},
      );
      final list = res.data as List;
      return list
          .map((e) => ExperienceModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _throwApiError(e, 'Gagal memuat pengalaman');
    }
  }

  Future<MessageResponseModel> sendContact(
    String slug,
    MessageCreateModel payload,
  ) async {
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

  /// GET /public/gallery/projects — galeri multi-user (hanya published).
  Future<List<ProjectModel>> getGalleryProjects({
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final res = await _dio.get(
        '/public/gallery/projects',
        queryParameters: {'skip': skip, 'limit': limit},
      );
      final data = res.data;
      if (data is! List) {
        throw ApiException('Respons galeri tidak valid');
      }
      return data
          .map((e) => ProjectModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _throwApiError(e, 'Gagal memuat galeri');
    }
  }

  /// GET /health — health check backend. Endpoint ini di root, di luar
  /// prefix `/api/v1`, jadi URL dihitung dari origin `ApiConfig.baseUrl`.
  Future<bool> healthCheck() async {
    final base = Uri.tryParse(ApiConfig.baseUrl);
    if (base == null || base.host.isEmpty) {
      throw ApiException('Base URL belum dikonfigurasi');
    }
    final health = base.replace(path: '/health', query: '', fragment: '');
    try {
      final res = await _dio.getUri(health);
      return res.data is Map && res.data['status'] == 'ok';
    } on DioException catch (e) {
      _throwApiError(e, 'Health check gagal');
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
      final res = await _dio.get(
        '/me/projects',
        queryParameters: {'limit': 100},
      );
      return (res.data as List)
          .map((e) => ProjectModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _throwApiError(e, 'Gagal memuat proyek saya');
    }
  }

  Future<ProjectModel> createMyProject(Map<String, dynamic> payload) async {
    try {
      final res = await _dio.post('/me/projects', data: payload);
      return ProjectModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _throwApiError(e, 'Gagal tambah proyek');
    }
  }

  Future<ProjectModel> updateMyProject(
    int id,
    Map<String, dynamic> payload,
  ) async {
    try {
      final res = await _dio.patch('/me/projects/$id', data: payload);
      return ProjectModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _throwApiError(e, 'Gagal update proyek');
    }
  }

  Future<void> deleteMyProject(int id) async {
    try {
      await _dio.delete('/me/projects/$id');
    } on DioException catch (e) {
      _throwApiError(e, 'Gagal hapus proyek');
    }
  }

  /// POST /me/projects/{id}/media via queryParameters (media_url, media_type, caption).
  Future<ProjectMediaModel> addMyProjectMedia(
    int id, {
    required String mediaUrl,
    String mediaType = 'image',
    String? caption,
  }) async {
    try {
      final res = await _dio.post(
        '/me/projects/$id/media',
        queryParameters: {
          'media_url': mediaUrl,
          'media_type': mediaType,
          if (caption != null) 'caption': caption,
        },
      );
      return ProjectMediaModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _throwApiError(e, 'Gagal tambah media proyek');
    }
  }

  Future<List<SkillModel>> listMySkills() async {
    try {
      final res = await _dio.get('/me/skills');
      return (res.data as List)
          .map((e) => SkillModel.fromJson(e as Map<String, dynamic>))
          .toList();
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

  Future<SkillModel> updateMySkill(int id, Map<String, dynamic> payload) async {
    try {
      final res = await _dio.patch('/me/skills/$id', data: payload);
      return SkillModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _throwApiError(e, 'Gagal update skill');
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
      return (res.data as List)
          .map((e) => ExperienceModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _throwApiError(e, 'Gagal memuat experience');
    }
  }

  Future<ExperienceModel> createMyExperience(
    Map<String, dynamic> payload,
  ) async {
    try {
      final res = await _dio.post('/me/experiences', data: payload);
      return ExperienceModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _throwApiError(e, 'Gagal tambah experience');
    }
  }

  Future<ExperienceModel> updateMyExperience(
    int id,
    Map<String, dynamic> payload,
  ) async {
    try {
      final res = await _dio.patch('/me/experiences/$id', data: payload);
      return ExperienceModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _throwApiError(e, 'Gagal update experience');
    }
  }

  Future<void> deleteMyExperience(int id) async {
    try {
      await _dio.delete('/me/experiences/$id');
    } on DioException catch (e) {
      _throwApiError(e, 'Gagal hapus experience');
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

  Future<void> markMyMessageRead(int id) async {
    try {
      await _dio.patch('/me/messages/$id/read');
    } on DioException catch (e) {
      _throwApiError(e, 'Gagal tandai pesan dibaca');
    }
  }

  Future<void> deleteMyMessage(int id) async {
    try {
      await _dio.delete('/me/messages/$id');
    } on DioException catch (e) {
      _throwApiError(e, 'Gagal hapus pesan');
    }
  }

  /// POST /me/upload/cover (multipart FormData).
  Future<String> uploadMyCover(MultipartFile file) =>
      _uploadMultipart('/me/upload/cover', file);

  /// POST /me/upload/media (multipart FormData).
  Future<String> uploadMyMedia(MultipartFile file) =>
      _uploadMultipart('/me/upload/media', file);

  /// POST /me/upload/avatar (multipart FormData).
  Future<String> uploadMyAvatar(MultipartFile file) =>
      _uploadMultipart('/me/upload/avatar', file);

  // ---- Admin (/admin/*) ----
  Future<List<UserModel>> adminListUsers() async {
    try {
      final res = await _dio.get('/admin/users');
      return (res.data as List)
          .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _throwApiError(e, 'Gagal memuat users (admin only)');
    }
  }

  Future<UserModel> adminCreateUser(Map<String, dynamic> payload) async {
    try {
      final res = await _dio.post('/admin/users', data: payload);
      return UserModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _throwApiError(e, 'Gagal buat user');
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

  Future<void> adminMarkMessageRead(int id) async {
    try {
      await _dio.patch('/admin/messages/$id/mark-read');
    } on DioException catch (e) {
      _throwApiError(e, 'Gagal tandai pesan dibaca');
    }
  }

  Future<void> adminDeleteMessage(int id) async {
    try {
      await _dio.delete('/admin/messages/$id');
    } on DioException catch (e) {
      _throwApiError(e, 'Gagal hapus pesan');
    }
  }

  Future<List<ProjectModel>> adminListProjects() async {
    try {
      final res = await _dio.get('/admin/projects');
      return (res.data as List)
          .map((e) => ProjectModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _throwApiError(e, 'Gagal memuat proyek (admin)');
    }
  }

  /// GET /admin/projects?owner_id — filter proyek lintas user (metode baru,
  /// signature lama [adminListProjects] dipertahankan).
  Future<List<ProjectModel>> adminListProjectsFiltered({
    int? ownerId,
    int skip = 0,
    int limit = 50,
  }) async {
    try {
      final res = await _dio.get(
        '/admin/projects',
        queryParameters: {
          'skip': skip,
          'limit': limit,
          if (ownerId != null) 'owner_id': ownerId,
        },
      );
      return (res.data as List)
          .map((e) => ProjectModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _throwApiError(e, 'Gagal memuat proyek (admin)');
    }
  }

  Future<ProjectModel> adminCreateProject(Map<String, dynamic> payload) async {
    try {
      final res = await _dio.post('/admin/projects', data: payload);
      return ProjectModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _throwApiError(e, 'Gagal tambah proyek (admin)');
    }
  }

  Future<ProjectModel> adminUpdateProject(
    int id,
    Map<String, dynamic> payload,
  ) async {
    try {
      final res = await _dio.patch('/admin/projects/$id', data: payload);
      return ProjectModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _throwApiError(e, 'Gagal update proyek (admin)');
    }
  }

  Future<void> adminDeleteProject(int id) async {
    try {
      await _dio.delete('/admin/projects/$id');
    } on DioException catch (e) {
      _throwApiError(e, 'Gagal hapus proyek (admin)');
    }
  }

  /// POST /admin/projects/{id}/media via queryParameters (media_url, media_type, caption).
  Future<ProjectMediaModel> adminAddProjectMedia(
    int id, {
    required String mediaUrl,
    String mediaType = 'image',
    String? caption,
  }) async {
    try {
      final res = await _dio.post(
        '/admin/projects/$id/media',
        queryParameters: {
          'media_url': mediaUrl,
          'media_type': mediaType,
          if (caption != null) 'caption': caption,
        },
      );
      return ProjectMediaModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _throwApiError(e, 'Gagal tambah media proyek (admin)');
    }
  }

  Future<SkillModel> adminCreateSkill(Map<String, dynamic> payload) async {
    try {
      final res = await _dio.post('/admin/skills', data: payload);
      return SkillModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _throwApiError(e, 'Gagal tambah skill (admin)');
    }
  }

  Future<SkillModel> adminUpdateSkill(
    int id,
    Map<String, dynamic> payload,
  ) async {
    try {
      final res = await _dio.patch('/admin/skills/$id', data: payload);
      return SkillModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _throwApiError(e, 'Gagal update skill (admin)');
    }
  }

  Future<void> adminDeleteSkill(int id) async {
    try {
      await _dio.delete('/admin/skills/$id');
    } on DioException catch (e) {
      _throwApiError(e, 'Gagal hapus skill (admin)');
    }
  }

  Future<ExperienceModel> adminCreateExperience(
    Map<String, dynamic> payload,
  ) async {
    try {
      final res = await _dio.post('/admin/experiences', data: payload);
      return ExperienceModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _throwApiError(e, 'Gagal tambah experience (admin)');
    }
  }

  Future<ExperienceModel> adminUpdateExperience(
    int id,
    Map<String, dynamic> payload,
  ) async {
    try {
      final res = await _dio.patch('/admin/experiences/$id', data: payload);
      return ExperienceModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _throwApiError(e, 'Gagal update experience (admin)');
    }
  }

  Future<void> adminDeleteExperience(int id) async {
    try {
      await _dio.delete('/admin/experiences/$id');
    } on DioException catch (e) {
      _throwApiError(e, 'Gagal hapus experience (admin)');
    }
  }

  /// POST /admin/upload/project-cover (multipart FormData).
  Future<String> adminUploadProjectCover(MultipartFile file) =>
      _uploadMultipart('/admin/upload/project-cover', file);

  /// POST /admin/upload/project-media (multipart FormData).
  Future<String> adminUploadProjectMedia(MultipartFile file) =>
      _uploadMultipart('/admin/upload/project-media', file);

  /// POST /admin/upload/resume (multipart FormData).
  Future<String> adminUploadResume(MultipartFile file) =>
      _uploadMultipart('/admin/upload/resume', file);

  /// POST /admin/upload/avatar (multipart FormData).
  Future<String> adminUploadAvatar(MultipartFile file) =>
      _uploadMultipart('/admin/upload/avatar', file);
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
