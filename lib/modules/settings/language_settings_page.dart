import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/transcription_languages.dart';
import '../../core/helpers/transcription_preferences.dart';
import '../../core/theme/text_styles.dart';

/// Lets the user pin the language they record in.
///
/// Auto-detect is the default and right for most people. The override matters
/// for anyone whose device region does not match how they speak — a Punjabi
/// speaker in Toronto, or someone in India recording in Spanish.
class LanguageSettingsPage extends StatefulWidget {
  const LanguageSettingsPage({super.key});

  @override
  State<LanguageSettingsPage> createState() => _LanguageSettingsPageState();
}

class _LanguageSettingsPageState extends State<LanguageSettingsPage> {
  late String _selectedCode = TranscriptionPreferences.languageCode;
  String _query = '';

  Future<void> _select(String code) async {
    setState(() => _selectedCode = code);
    await TranscriptionPreferences.setLanguageCode(code);
  }

  bool _matches(TranscriptionLanguage language) {
    if (_query.isEmpty) return true;
    final needle = _query.toLowerCase();
    return language.name.toLowerCase().contains(needle) ||
        (language.nativeName?.toLowerCase().contains(needle) ?? false) ||
        language.code.toLowerCase().contains(needle);
  }

  @override
  Widget build(BuildContext context) {
    final indian = TranscriptionLanguages.indian.where(_matches).toList();
    final global = TranscriptionLanguages.global.where(_matches).toList();
    final showAuto = _matches(TranscriptionLanguages.auto);
    final hasResults = showAuto || indian.isNotEmpty || global.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchField(),
            Expanded(
              child: hasResults
                  ? ListView(
                      padding: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 4.h),
                      children: [
                        if (showAuto) ...[
                          _buildTile(TranscriptionLanguages.auto),
                          Padding(
                            padding: EdgeInsets.only(top: 0.5.h, bottom: 1.h),
                            child: Text(
                              'Picks the best engine from your recording and '
                              'device region. Change it only if transcripts come '
                              'back in the wrong language.',
                              style: AppTextTheme.body3.copyWith(
                                color: AppColors.textGrey,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                        if (indian.isNotEmpty) ...[
                          _buildSectionHeader('Indian languages'),
                          ...indian.map(_buildTile),
                        ],
                        if (global.isNotEmpty) ...[
                          _buildSectionHeader('Other languages'),
                          ...global.map(_buildTile),
                        ],
                      ],
                    )
                  : _buildEmptyState(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
      child: Row(
        children: [
          InkWell(
            onTap: () => Get.back(),
            borderRadius: BorderRadius.circular(8),
            child: Icon(
              Icons.arrow_back,
              size: 22.sp,
              color: AppColors.textBlack,
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Language',
                style: AppTextTheme.body1Medium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textBlack,
                ),
              ),
            ),
          ),
          SizedBox(width: 22.sp),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: EdgeInsets.fromLTRB(5.w, 0, 5.w, 1.h),
      child: TextField(
        onChanged: (value) => setState(() => _query = value.trim()),
        style: AppTextTheme.body2.copyWith(color: AppColors.textBlack),
        decoration: InputDecoration(
          hintText: 'Search languages',
          hintStyle: AppTextTheme.body2.copyWith(color: AppColors.grey500),
          prefixIcon: Icon(Icons.search, size: 18.sp, color: AppColors.grey500),
          filled: true,
          fillColor: AppColors.grey100,
          contentPadding: EdgeInsets.symmetric(vertical: 0.5.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.sp),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(top: 2.h, bottom: 0.5.h),
      child: Text(
        title.toUpperCase(),
        style: AppTextTheme.body3.copyWith(
          color: AppColors.textGrey,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTile(TranscriptionLanguage language) {
    final isSelected = language.code == _selectedCode;
    final showSubtitle =
        language.nativeName != null && language.nativeName != language.name;

    return InkWell(
      onTap: () => _select(language.code),
      borderRadius: BorderRadius.circular(12.sp),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 1.2.h),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language.name,
                    style: AppTextTheme.body2.copyWith(
                      color: AppColors.textBlack,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  if (showSubtitle) ...[
                    SizedBox(height: 0.2.h),
                    Text(
                      language.nativeName!,
                      style: AppTextTheme.body3.copyWith(
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                size: 20.sp,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Text(
          'No languages match "$_query".',
          textAlign: TextAlign.center,
          style: AppTextTheme.body2.copyWith(color: AppColors.textGrey),
        ),
      ),
    );
  }
}
