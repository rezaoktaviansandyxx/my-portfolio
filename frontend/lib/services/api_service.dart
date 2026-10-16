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
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.interceptors.add(LogInterceptor(responseBody: true));
  }

  // Public endpoints
  Future<UserModel> getProfile(String slug) async {
    final res = await _dio.get('/public/u/$slug/profile');
    return UserModel.fromJson(res.data);
  }

  Future<List<ProjectModel>> getProjects(String slug, {int skip = 0, int limit = 20}) async {
    final res = await _dio.get(
      '/public/u/$slug/projects',
      queryParameters: {'skip': skip, 'limit': limit},
    );
    return (res.data as List).map((e) => ProjectModel.fromJson(e)).toList();
  }

  Future<List<SkillModel>> getSkills(String slug, {int skip = 0, int limit = 100}) async {
    final res = await _dio.get(
      '/public/u/$slug/skills',
      queryParameters: {'skip': skip, 'limit': limit},
    );
    return (res.data as List).map((e) => SkillModel.fromJson(e)).toList();
  }

  Future<List<ExperienceModel>> getExperiences(String slug, {int skip = 0, int limit = 50}) async {
    final res = await _dio.get(
      '/public/u/$slug/experiences',
      queryParameters: {'skip': skip, 'limit': limit},
    );
    return (res.data as List).map((e) => ExperienceModel.fromJson(e)).toList();
  }

  Future<MessageResponseModel> sendContact(String slug, MessageCreateModel payload) async {
    final res = await _dio.post(
      '/public/u/$slug/contact',
      data: payload.toJson(),
    );
    return MessageResponseModel.fromJson(res.data);
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
        id: json['id'] as int,
        senderName: json['sender_name'] as String,
        status: json['status'] as String? ?? 'sent',
      );
}