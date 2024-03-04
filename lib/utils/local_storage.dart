import 'package:get_storage/get_storage.dart';

class LocalStorageKey {
  static String savingDateKey = 'savingDateKey';
}

///Get Storage Functions
Future<void> setData(String key, dynamic value) async =>
    await GetStorage().write(key, value);

int? getInt(String key) => GetStorage().read(key);

String? getString(String key) => GetStorage().read(key);

bool? getBool(String key) => GetStorage().read(key);

double? getDouble(String key) => GetStorage().read(key);

Future<dynamic> getData(String key) async => await GetStorage().read(key);

Future<void> removeData(String key) async => await GetStorage().remove(key);

Future<void> clearLocalData() async => await GetStorage().erase();
