import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whispers_of_the_loom/providers/image_provider.dart';
import 'package:whispers_of_the_loom/utils/const.dart';

void photoBottomSheet(
  BuildContext context,
  ImageNotifier imageProv,
  int index,
  WidgetRef ref,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: kCardSurface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      side: BorderSide(color: kOutline),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 40.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 32.w,
              height: 3.h,
              decoration: BoxDecoration(
                color: kOutline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'DOCUMENT TOOL',
            style: GoogleFonts.ibmPlexMono(
              color: kAccent,
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 16.h),
          _buildOption(
            ctx,
            imageProv,
            icon: Icons.camera_alt_outlined,
            label: 'Photograph',
            sublabel: 'Capture whorl face or drive wheel',
            source: ImageSource.camera,
          ),
          SizedBox(height: 8.h),
          _buildOption(
            ctx,
            imageProv,
            icon: Icons.photo_library_outlined,
            label: 'Select from Library',
            sublabel: 'Choose existing documentation',
            source: ImageSource.gallery,
          ),
        ],
      ),
    ),
  );
}

Widget _buildOption(
  BuildContext ctx,
  ImageNotifier imageProv, {
  required IconData icon,
  required String label,
  required String sublabel,
  required ImageSource source,
}) {
  return GestureDetector(
    onTap: () async {
      Navigator.pop(ctx);
      await imageProv.pickImage(source: source);
    },
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: kBackground,
        borderRadius: BorderRadius.circular(kRadiusStandard),
        border: Border.all(color: kOutline),
      ),
      child: Row(
        children: [
          Icon(icon, color: kAccent, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    color: kPrimaryText,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  sublabel,
                  style: GoogleFonts.inter(
                    color: kSecondaryText,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded,
              color: kSecondaryText, size: 14.sp),
        ],
      ),
    ),
  );
}
