import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../../services/shared_pref/pref_keys.dart';
import '../../services/shared_pref/shared_pref.dart';

import '../language_cache_helper.dart';
part 'locale_state.dart';

class LocaleCubit extends Cubit<ChangeLocaleState> {
  LocaleCubit() : super(ChangeLocaleState(locale: const Locale('en')));

  Future<void> getSavedLanguage() async {
    // First try to get from SharedPrefs (used by language selection screen)
    final savedLanguage = SharedPref().getString(PrefKeys.languageCode);

    if (savedLanguage != null && savedLanguage.isNotEmpty) {
      emit(ChangeLocaleState(locale: Locale(savedLanguage)));
    } else {
      // Fall back to the language cache helper
      final String cachedLanguageCode =
          await LanguageCacheHelper().getCachedLanguageCode();
      emit(ChangeLocaleState(locale: Locale(cachedLanguageCode)));

      // Update SharedPrefs for consistency
      SharedPref().setString(PrefKeys.languageCode, cachedLanguageCode);
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    // Update both caching mechanisms
    await LanguageCacheHelper().cacheLanguageCode(languageCode);
    SharedPref().setString(PrefKeys.languageCode, languageCode);

    emit(ChangeLocaleState(locale: Locale(languageCode)));
  }
}
