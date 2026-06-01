String formatNoteDate(DateTime dateTime) {
  final local = dateTime.toLocal();
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${months[local.month - 1]} ${local.day}, ${local.year}';
}

String formatRecordingDuration(int totalSeconds) {
  if (totalSeconds <= 0) return '0 sec';
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;
  if (hours > 0) {
    return '$hours hr $minutes min $seconds sec';
  }
  if (minutes > 0) {
    return '$minutes min $seconds sec';
  }
  return '$seconds sec';
}
