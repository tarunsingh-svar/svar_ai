import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:svar_ai/core/routing/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  late final RecorderController recorderController;
  final RxBool isRecording = false.obs;
  final RxInt seconds = 0.obs;
  final RxString timeDisplay = "00:00:00".obs;
  Timer? timer;
  String? recordedFilePath;

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

  Future<String> _getPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return "${dir.path}/record_${DateTime.now().millisecondsSinceEpoch}.m4a";
  }

  void _startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      seconds.value++;
      final h = (seconds.value ~/ 3600).toString().padLeft(2, '0');
      final m = ((seconds.value % 3600) ~/ 60).toString().padLeft(2, '0');
      final s = (seconds.value % 60).toString().padLeft(2, '0');
      timeDisplay.value = "$h:$m:$s";
    });
  }

  Future<void> startRecording() async {
    if (await recorderController.checkPermission()) {
      final path = await _getPath();
      recordedFilePath = path;
      await recorderController.record(path: path);
      isRecording.value = true;
      _startTimer();
    } else {
      Get.snackbar("Permission denied", "Please allow microphone access");
    }
  }

  Future<void> pauseRecording() async {
    await recorderController.pause();
    isRecording.value = false;
    timer?.cancel();
  }

  Future<void> resumeRecording() async {
    await recorderController.record();
    isRecording.value = true;
    _startTimer();
  }

  Future<void> stopRecording() async {
    final path = await recorderController.stop();
    timer?.cancel();
    isRecording.value = false;

    if (path != null) {
      recordedFilePath = path;
      // Get.snackbar("Recording Saved", "File: ${path.split('/').last}");
      // Get.back();
      Get.back();
      Get.toNamed(AppRoutes.notePage);
    } else {
      Get.snackbar("Error", "Failed to save recording");
    }

    seconds.value = 0;
    timeDisplay.value = "00:00:00";
  }

  @override
  void dispose() {
    timer?.cancel();
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
      floatingActionButton: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildIconButton(Icons.close_rounded, AppColors.primary, () {
              Get.back();
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
                  seconds.value == 0 ? startRecording() : resumeRecording();
                }
              },
              size: 30.sp,
            ),
          ],
        ),
      ),
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
      // AppColors.primary.withValues(alpha: 0.8),
      // AppColors.primary.withValues(alpha: 0.6),
      // AppColors.primary.withValues(alpha: 0.4),
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
