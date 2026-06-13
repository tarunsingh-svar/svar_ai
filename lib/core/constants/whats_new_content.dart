import 'app_assets.dart';

/// A single highlighted update inside a release.
class WhatsNewFeature {
  const WhatsNewFeature({
    required this.title,
    required this.description,
    this.imageAsset,
  });

  final String title;
  final String description;

  /// Asset path under `assets/`. Omit for text-only updates.
  final String? imageAsset;
}

/// One app release worth of updates, shown newest first in [WhatsNewContent.releases].
class WhatsNewRelease {
  const WhatsNewRelease({
    required this.version,
    required this.dateLabel,
    this.summary,
    required this.features,
  });

  final String version;
  final String dateLabel;
  final String? summary;
  final List<WhatsNewFeature> features;
}

/// Release notes shown in Settings > What's New.
///
/// Update [releases] at every app release:
/// 1. Add a new [WhatsNewRelease] at the top of the list.
/// 2. Drop screenshots under `assets/whats_new/` (folder is in pubspec.yaml).
/// 3. Reference those paths in each feature's [WhatsNewFeature.imageAsset].
class WhatsNewContent {
  WhatsNewContent._();

  static const releases = <WhatsNewRelease>[
    WhatsNewRelease(
      version: '1.0.0',
      dateLabel: 'June 2026',
      summary: 'Welcome to SVAR AI — capture ideas by voice and turn them into polished notes.',
      features: [
        WhatsNewFeature(
          title: 'Record and transcribe',
          description:
              'Capture meetings, ideas, and voice memos. SVAR AI transcribes your recordings '
              'into searchable notes you can edit anytime.',
          imageAsset: AppAssets.intro1,
        ),
        WhatsNewFeature(
          title: 'AI-powered rewrites',
          description:
              'Turn rough transcripts into summaries, emails, to-do lists, and more with '
              '16+ rewrite options built for how you work.',
          imageAsset: AppAssets.spark,
        ),
        WhatsNewFeature(
          title: 'SVAR AI Pro',
          description:
              'Upgrade for unlimited notes, longer recordings, every rewrite option, and '
              'priority support.',
          imageAsset: AppAssets.intro2,
        ),
        WhatsNewFeature(
          title: 'Settings and account tools',
          description:
              'Manage your profile, read policies, get help at tech@svar.ai, and stay up to '
              'date with release notes right from Settings.',
          imageAsset: AppAssets.intro3,
        ),
      ],
    ),
  ];
}
