import 'package:flutter_test/flutter_test.dart';
import 'package:svar_ai/core/constants/plan_limits.dart';

/// The free-tier gates. A typo in a rewrite id here silently changes what free
/// users can reach, in either direction, with nothing to notice it at runtime.
void main() {
  const allRewriteIds = <String>{
    RewriteIds.quickList,
    RewriteIds.meetingNotes,
    RewriteIds.todoList,
    RewriteIds.dailyStandup,
    RewriteIds.featureDiscussion,
    RewriteIds.interviewSummary,
    RewriteIds.delegationNote,
    RewriteIds.emailCasual,
    RewriteIds.emailFormal,
    RewriteIds.xPost,
    RewriteIds.xThread,
    RewriteIds.shortVideoScript,
    RewriteIds.linkedInPost,
    RewriteIds.contentOutline,
    RewriteIds.lectureSummary,
    RewriteIds.journal,
  };

  group('free rewrite ids', () {
    test('every free id is a real rewrite id', () {
      expect(PlanLimits.freeRewriteIds, everyElement(isIn(allRewriteIds)));
    });

    test('at least one rewrite is free', () {
      expect(
        PlanLimits.freeRewriteIds,
        isNotEmpty,
        reason: 'a free user with no usable rewrite has nothing to try',
      );
    });

    test('the free set is a strict subset, so Pro still has something to sell', () {
      expect(
        PlanLimits.freeRewriteIds.length,
        lessThan(allRewriteIds.length),
      );
    });

    test('meeting notes is the free rewrite', () {
      expect(PlanLimits.freeRewriteIds, {RewriteIds.meetingNotes});
    });
  });

  group('rewrite ids', () {
    test('are unique', () {
      expect(allRewriteIds.length, 16);
    });

    test('are snake_case, matching the backend registry keys', () {
      for (final id in allRewriteIds) {
        expect(
          id,
          matches(RegExp(r'^[a-z0-9]+(_[a-z0-9]+)*$')),
          reason: '$id must match a REWRITE_CONFIGS key',
        );
      }
    });
  });

  group('free tier caps', () {
    test('the note limit is a positive lifetime cap', () {
      expect(PlanLimits.freeNoteLimit, 10);
      expect(PlanLimits.freeNoteLimit, greaterThan(0));
    });

    test('the recording cap is three minutes', () {
      expect(PlanLimits.freeMaxRecordingSeconds, 180);
    });

    test('the recording cap stays under the upload size ceiling', () {
      // Recording is 16 kHz at 32 kbps, and OpenAI rejects uploads over 25 MB.
      const bytesPerSecond = 32000 / 8;
      final maxBytes = PlanLimits.freeMaxRecordingSeconds * bytesPerSecond;

      expect(maxBytes, lessThan(25 * 1024 * 1024));
    });
  });
}
