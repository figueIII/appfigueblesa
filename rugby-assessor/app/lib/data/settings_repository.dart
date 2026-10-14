// Preferencias de la app (tabla app_setting, v5): hoy solo el idioma.


import '../core/i18n.dart';
import 'db/app_database.dart';

abstract interface class SettingsRepository {
  Future<AppLanguage> loadLanguage();
  Future<void> saveLanguage(AppLanguage language);
}

class DriftSettingsRepository implements SettingsRepository {
  DriftSettingsRepository(this.db);
  final AppDatabase db;

  static const _language = 'language';

  @override
  Future<AppLanguage> loadLanguage() async {
    final row = await (db.select(db.appSetting)..where((t) => t.name.equals(_language))).getSingleOrNull();
    return decodeLanguage(row?.value);
  }

  @override
  Future<void> saveLanguage(AppLanguage language) =>
      db.into(db.appSetting).insertOnConflictUpdate(AppSettingCompanion.insert(name: _language, value: encodeLanguage(language)));
}

/// Para tests de widget.
class InMemorySettingsRepository implements SettingsRepository {
  AppLanguage language = AppLanguage.es;

  @override
  Future<AppLanguage> loadLanguage() async => language;

  @override
  Future<void> saveLanguage(AppLanguage l) async => language = l;
}
