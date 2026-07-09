import 'package:injectable/injectable.dart';

import '../../core/errors/exceptions.dart';
import '../local/cache/hive_manager.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<UserModel?> getCachedUser();
  Future<void> cacheUser(UserModel user);
  Future<void> clearCachedUser();
  Future<String?> getAuthToken();
  Future<void> saveAuthToken(String token);
  Future<void> clearAuthToken();
}

@LazySingleton(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {

  AuthLocalDataSourceImpl(this._hiveManager);
  final HiveManager _hiveManager;

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final userData = _hiveManager.getCachedUserData();

      if (userData == null) {
        return null;
      }

      return UserModel.fromJson(userData);
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      await _hiveManager.cacheUserData(user.toJson());
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> clearCachedUser() async {
    try {
      await _hiveManager.clearUserData();
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<String?> getAuthToken() async {
    try {
      return _hiveManager.getAuthToken();
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> saveAuthToken(String token) async {
    try {
      await _hiveManager.saveAuthToken(token);
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> clearAuthToken() async {
    try {
      await _hiveManager.deleteAuthToken();
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }
}
