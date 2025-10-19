import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:svar_ai/core/constants/app_colors.dart';
import 'package:svar_ai/widgets/tag_card.dart';

class TagInputRow extends StatelessWidget {
  TagInputRow({super.key});

  final RxList<Map<String, dynamic>> tags = <Map<String, dynamic>>[
    // {"text": "All", "color": AppColors.cardYellow},
  ].obs;

  final RxBool showInput = false.obs;
  final TextEditingController tagController = TextEditingController();

  final List<Color> tagColors = [
    AppColors.cardYellow,
    AppColors.cardGreen,
    AppColors.darkGreen,
    AppColors.cardPurple,
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Wrap(
        spacing: 2.w,
        runSpacing: 1.h,
        children: [
          // existing tags
          ...tags.map((t) => TagCard(text: t["text"], color: t["color"])),

          // show input field when "+" pressed
          if (showInput.value)
            SizedBox(
              width: 35.w,
              height: 4.h,
              child: TextField(
                controller: tagController,
                autofocus: true,
                style: TextStyle(fontSize: 15.sp, color: AppColors.textBlack),
                decoration: InputDecoration(
                  hintText: "New tag",
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10.sp,
                    vertical: 8.sp,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.sp),
                    borderSide: BorderSide(color: AppColors.grey400, width: 1),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.check_rounded,
                      color: AppColors.primary,
                      size: 18.sp,
                    ),
                    onPressed: () {
                      if (tagController.text.trim().isNotEmpty) {
                        final color =
                            tagColors[tags.length %
                                tagColors.length]; // rotate colors
                        tags.add({
                          "text": tagController.text.trim(),
                          "color": color,
                        });
                      }
                      tagController.clear();
                      showInput.value = false;
                    },
                  ),
                ),
              ),
            )
          else
            // "+" add button
            InkWell(
              onTap: () => showInput.value = true,
              borderRadius: BorderRadius.circular(8.sp),
              child: Container(
                height: 3.8.h,
                width: 3.8.h,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.grey400, width: 1),
                  borderRadius: BorderRadius.circular(8.sp),
                ),
                child: Icon(
                  Icons.add_rounded,
                  size: 18.sp,
                  color: AppColors.grey600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
