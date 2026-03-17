import 'package:dio/dio.dart';
import '../models/photo_model.dart';
import '../models/profile_model.dart';

class ProfileService {
  final Dio _dio;
  ProfileService(this._dio);

  Future<ProfileModel> getProfile() async {
    final res = await _dio.get('/profile');
    return ProfileModel.fromJson(res.data['profile'] as Map<String, dynamic>);
  }

  Future<ProfileModel> updateProfile(Map<String, dynamic> data) async {
    final res = await _dio.put('/profile', data: data);
    return ProfileModel.fromJson(res.data['profile'] as Map<String, dynamic>);
  }

  Future<PhotoModel> uploadPhoto(String filePath) async {
    final form = FormData.fromMap({
      'photo': await MultipartFile.fromFile(filePath),
    });
    final res = await _dio.post('/profile/photos', data: form);
    return PhotoModel.fromJson(res.data['photo'] as Map<String, dynamic>);
  }

  Future<void> deletePhoto(int photoId) =>
      _dio.delete('/profile/photos/$photoId');

  Future<void> setPrimaryPhoto(int photoId) =>
      _dio.patch('/profile/photos/$photoId/primary');
}
