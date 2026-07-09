import 'package:firebase_storage/firebase_storage.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

/// Module for registering app-level dependencies
@module
abstract class AppModule {
  @lazySingleton
  Uuid get uuid => const Uuid();

  @lazySingleton
  FirebaseStorage get firebaseStorage => FirebaseStorage.instance;

  @Named('mealCache')
  @preResolve
  Future<Box<Map<dynamic, dynamic>>> get mealCache async => Hive.openBox<Map<dynamic, dynamic>>('meals_cache');

  @Named('workoutCache')
  @preResolve
  Future<Box<Map<dynamic, dynamic>>> get workoutCache async => Hive.openBox<Map<dynamic, dynamic>>('workouts_cache');
}
