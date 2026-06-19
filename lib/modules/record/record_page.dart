import 'dart:async';
import 'dart:io';
import 'package:animate_do/animate_do.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:svar_ai/core/routing/app_routes.dart';
import 'package:svar_ai/core/helpers/recording_foreground.dart';
import 'package:svar_ai/modules/ai/transcribe_controller.dart';
import 'package:svar_ai/modules/subscription/subscription_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../ai/ai_controller.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  final aiController = Get.find<AIController>();
  final TranscribeController transcribeController = Get.find();
  final SubscriptionController subscriptionController = Get.find();

  late final RecorderController recorderController;
  final RxBool isRecording = false.obs;
  final RxInt seconds = 0.obs;
  final RxString timeDisplay = "00:00:00".obs;
  Timer? timer;
  StreamSubscription<Duration>? _durationSub;
  String? recordedFilePath;
  final RxBool _stopInProgress = false.obs;

  @override
  void initState() {
    super.initState();

    recorderController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 44100;

    WidgetsBinding.instance.addPostFrameCallback((_) => startRecording());
  }

  void _updateTimeDisplay(int elapsedSeconds) {
    final cap = subscriptionController.maxRecordingSeconds;
    final displaySeconds = cap != null
        ? (cap - elapsedSeconds).clamp(0, cap)
        : elapsedSeconds;
    final h = (displaySeconds ~/ 3600).toString().padLeft(2, '0');
    final m = ((displaySeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (displaySeconds % 60).toString().padLeft(2, '0');
    timeDisplay.value = "$h:$m:$s";
  }

  void _startDurationListener() {
    _durationSub?.cancel();
    _durationSub = recorderController.onCurrentDuration.listen((duration) {
      if (!isRecording.value) return;

      final totalSeconds = duration.inSeconds;
      seconds.value = totalSeconds;
      _updateTimeDisplay(totalSeconds);

      final cap = subscriptionController.maxRecordingSeconds;
      if (cap != null && totalSeconds >= cap) {
        Get.snackbar(
          "Recording limit reached",
          "Free recordings are capped at 3 minutes. Upgrade to Pro for unlimited recording.",
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
        stopRecording();
      }
    });
  }

  void _stopDurationListener() {
    _durationSub?.cancel();
    _durationSub = null;
  }

  Future<String> _getPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return "${dir.path}/record_${DateTime.now().millisecondsSinceEpoch}.m4a";
  }

  void _startTimer() {
    _startDurationListener();
  }

  Future<void> startRecording() async {
    if (await recorderController.checkPermission()) {
      final path = await _getPath();
      recordedFilePath = path;
      await RecordingForeground.start();
      await recorderController.record(path: path);
      isRecording.value = true;
      seconds.value = 0;
      _updateTimeDisplay(0);
      _startTimer();
    } else {
      Get.snackbar("Permission denied", "Please allow microphone access");
    }
  }

  Future<void> pauseRecording() async {
    await recorderController.pause();
    isRecording.value = false;
    _stopDurationListener();
  }

  Future<void> resumeRecording() async {
    await recorderController.record();
    isRecording.value = true;
    _updateTimeDisplay(seconds.value);
    _startTimer();
  }

  Future<void> stopRecording() async {
    if (_stopInProgress.value) return;
    _stopInProgress.value = true;

    try {
      var path = await recorderController.stop();
      _stopDurationListener();
      timer?.cancel();
      isRecording.value = false;
      await RecordingForeground.stop();

      if (path == null &&
          recordedFilePath != null &&
          File(recordedFilePath!).existsSync()) {
        path = recordedFilePath;
      }

      if (path != null) {
        recordedFilePath = path;
        transcribeController.currentAudioPath.value = path;
        final isContinue = transcribeController.isContinuingRecording;
        final uiSeconds = seconds.value;
        final recordedSeconds = recorderController.recordedDuration.inSeconds;
        final newRecordingSeconds =
            recordedSeconds > 0 ? recordedSeconds : uiSeconds;

        Get.back();
        await processRecording(path, newRecordingSeconds);

        if (!isContinue) {
          if (transcribeController.shouldReplaceNotePageOnFinish.value) {
            Get.offNamed(AppRoutes.recordingNotePage);
          } else {
            Get.toNamed(AppRoutes.recordingNotePage);
          }
        }
      } else {
        Get.snackbar("Error", "Failed to save recording");
      }

      seconds.value = 0;
      timeDisplay.value = "00:00:00";
      transcribeController.prepareNewRecordingSession();
    } finally {
      _stopInProgress.value = false;
    }
  }

  Future<void> processRecording(String path, int newRecordingSeconds) async {
    final isContinue = transcribeController.isContinuingRecording;
    final existingNoteId = transcribeController.thisNoteId.value;

    int targetNoteId;
    if (isContinue && existingNoteId != 0) {
      targetNoteId = existingNoteId;
      final totalDuration =
          transcribeController.recordingDurationSeconds.value +
          newRecordingSeconds;
      transcribeController.recordingDurationSeconds.value = totalDuration;
      await transcribeController.updateDurationSeconds(
        targetNoteId,
        totalDuration,
      );
    } else {
      transcribeController.recordingDurationSeconds.value = newRecordingSeconds;
      aiController.headingText.value = 'Untitled Note';

      final newId = await transcribeController.addNewTranscribe();
      if (newId == null) {
        Get.snackbar(
          'Save failed',
          'Could not create note. Sign out, sign in again, then retry.',
        );
        return;
      }
      targetNoteId = newId;
    }

    await transcribeController.persistAudioPath(targetNoteId, path);

    await aiController.processRecordedAudio(
      File(path),
      appendToExisting: isContinue && existingNoteId != 0,
    );

    final transcript = aiController.transcriptText.value.trim();
    final canUpdate = transcript.isNotEmpty &&
        !transcript.startsWith('Error:') &&
        transcript != 'No transcript found';
    if (canUpdate) {
      await transcribeController.updateTranscribeText(targetNoteId, transcript);
    }
  }

  @override
  void dispose() {
    _stopDurationListener();
    timer?.cancel();
    unawaited(RecordingForeground.stop());
    recorderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTalkingBubbles(),
              SizedBox(height: 3.h),
              Text("Recording", style: AppTextTheme.body1Medium),
              SizedBox(height: 0.2.h),
              Obx(
                () => Text(
                  timeDisplay.value,
                  style: AppTextTheme.h1.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBlack,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Obx(() {
        final isBusy = aiController.isLoading.value || _stopInProgress.value;
        return isBusy
            ? const CircularProgressIndicator()
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildIconButton(Icons.close_rounded, AppColors.primary, () async {
                    await RecordingForeground.stop();
                    Get.back();
                    transcribeController.prepareNewRecordingSession();
                  }),
                  _buildIconButton(
                    Icons.stop_rounded,
                    AppColors.redSecondary,
                    stopRecording,
                    size: 34.sp,
                  ),
                  _buildIconButton(
                    isRecording.value
                        ? Icons.pause_rounded
                        : (seconds.value == 0
                              ? Icons.mic_rounded
                              : Icons.play_arrow_rounded),
                    AppColors.primary,
                    () {
                      if (isRecording.value) {
                        pauseRecording();
                      } else {
                        seconds.value == 0
                            ? startRecording()
                            : resumeRecording();
                      }
                    },
                    size: 30.sp,
                  ),
                ],
              );
      }),
    );
  }

  /// ChatGPT-like 4 jumping talking bubbles
  Widget _buildTalkingBubbles() {
    const bubbleCount = 4;
    final colors = [
      AppColors.cardGrey,
      AppColors.cardGrey,
      AppColors.cardGrey,
      AppColors.cardGrey,
    ];

    return Obx(
      () => SizedBox(
        height: 12.h,
        width: 50.w,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(bubbleCount, (i) {
            final delay = i * 150;
            return isRecording.value
                ? Bounce(
                    infinite: true,
                    delay: Duration(milliseconds: delay),
                    duration: const Duration(milliseconds: 800),
                    from: 10,
                    child: _bubble(colors[i]),
                  )
                : _bubble(colors[i]);
          }),
        ),
      ),
    );
  }

  Widget _bubble(Color color) => Container(
    width: 25.sp,
    height: 25.sp,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: 0.4),
          blurRadius: 10,
          spreadRadius: 3,
        ),
      ],
    ),
  );

  Widget _buildIconButton(
    IconData icon,
    Color color,
    VoidCallback onTap, {
    double? size,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        height: 9.h,
        width: 9.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.white,
          border: Border.all(color: AppColors.borderGrey),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: size ?? 26.sp),
      ),
    );
  }
}
