/// Single source of truth for free-tier limits and the rewrite options that
/// free users are allowed to use. Pro / trial / lifetime users bypass all of
/// these limits.
class PlanLimits {
  PlanLimits._();

  /// Lifetime cap on the number of notes a free user can create. Deleting a
  /// note does NOT free a slot (enforced server-side via notes_created_count).
  static const int freeNoteLimit = 10;

  /// Max recording length (seconds) for free users. 3 minutes.
  static const int freeMaxRecordingSeconds = 180;

  /// Rewrite option ids a free user can run. Everything else is Pro-only.
  static const Set<String> freeRewriteIds = {RewriteIds.meetingNotes};
}

/// Stable identifiers for each rewrite option. Used to gate options in the
/// rewrite bottom sheet without relying on display titles.
class RewriteIds {
  RewriteIds._();

  static const quickList = 'quick_list';
  static const meetingNotes = 'meeting_notes';
  static const todoList = 'todo_list';
  static const dailyStandup = 'daily_standup';
  static const featureDiscussion = 'feature_discussion';
  static const interviewSummary = 'interview_summary';
  static const delegationNote = 'delegation_note';
  static const emailCasual = 'email_casual';
  static const emailFormal = 'email_formal';
  static const xPost = 'x_post';
  static const xThread = 'x_thread';
  static const shortVideoScript = 'short_video_script';
  static const linkedInPost = 'linkedin_post';
  static const contentOutline = 'content_outline';
  static const lectureSummary = 'lecture_summary';
  static const journal = 'journal';
}
