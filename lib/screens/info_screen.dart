import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whispers_of_the_loom/models/hearth_fiber_tool_model.dart';
import 'package:whispers_of_the_loom/providers/image_provider.dart';
import 'package:whispers_of_the_loom/providers/project_provider.dart';
import 'package:whispers_of_the_loom/utils/const.dart';
import 'package:whispers_of_the_loom/widgets/spindle_whorl_icon.dart';

class InfoScreen extends ConsumerWidget {
  final int index;
  const InfoScreen({super.key, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectProv = ref.watch(projectProvider);
    if (index < 0 || index >= projectProv.entries.length) {
      return Scaffold(
        backgroundColor: kBackground,
        body: Center(
          child: Text(
            'TOOL NOT FOUND',
            style: GoogleFonts.ibmPlexMono(
              color: kSecondaryText,
              fontSize: 14.sp,
            ),
          ),
        ),
      );
    }

    final entry = projectProv.entries[index];
    final imagePath = ref.watch(imageProvider).getImagePath(entry.photoPath);

    return Scaffold(
      backgroundColor: kBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildHero(imagePath, entry, context)),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 40.h),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildIdentity(entry),
                SizedBox(height: 20.h),
                _buildSpecGrid(entry),
                if (entry.homesteadGroundZero.isNotEmpty) ...[
                  SizedBox(height: 16.h),
                  _detailCard('HOMESTEAD GROUND ZERO', entry.homesteadGroundZero),
                ],
                if (entry.calibrationFacility.isNotEmpty) ...[
                  SizedBox(height: 16.h),
                  _detailCard('CALIBRATION FACILITY', entry.calibrationFacility),
                ],
                if (entry.notes.isNotEmpty) ...[
                  SizedBox(height: 16.h),
                  _detailCard('ARCHIVAL NOTES', entry.notes),
                ],
                if (entry.tags.isNotEmpty) ...[
                  SizedBox(height: 16.h),
                  _buildTags(entry),
                ],
                SizedBox(height: 24.h),
                _buildActions(context, ref, projectProv),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(String? imagePath, HearthFiberToolModel entry, BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 360.h,
          color: kCardSurface,
          child: imagePath != null &&
                  entry.photoPath.isNotEmpty &&
                  File(imagePath).existsSync()
              ? Image.file(File(imagePath), fit: BoxFit.cover)
              : Center(
                  child: SpindleWhorlIcon(
                    fiberType: entry.fiberType,
                    soundness: entry.mechanicalSoundness,
                    size: 64.w,
                  ),
                ),
        ),
        Positioned(
          top: 48.h,
          left: 20.w,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: kCardSurface.withAlpha(220),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: kOutline),
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18.sp, color: kPrimaryText),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 60.h,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [kBackground.withAlpha(0), kBackground],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIdentity(HearthFiberToolModel entry) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            _tag(entry.craftClassification.label, kAccent),
            _tag(entry.fiberType.label.split(' /').first, kPrimaryText, mono: true),
            _tag(entry.homesteadRegion.label, kAccent, filled: true),
            _tag(entry.mechanicalSoundness.label,
                getSoundnessColor(entry.mechanicalSoundness)),
          ],
        ),
        SizedBox(height: 16.h),
        Text(
          entry.artisanHallmark.isEmpty ? 'Unknown Hallmark' : entry.artisanHallmark,
          style: GoogleFonts.lora(
            color: kPrimaryText,
            fontSize: 28.sp,
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          entry.spindleRegistryScroll.isEmpty
              ? 'UNCATALOGUED'
              : entry.spindleRegistryScroll,
          style: GoogleFonts.ibmPlexMono(
            color: kSecondaryText,
            fontSize: 12.sp,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _tag(String label, Color color, {bool mono = false, bool filled = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: filled ? color.withAlpha(31) : kCardSurface,
        borderRadius: BorderRadius.circular(kRadiusPill),
        border: Border.all(color: filled ? color.withAlpha(60) : kOutline),
      ),
      child: Text(
        label,
        style: mono
            ? GoogleFonts.ibmPlexMono(color: color, fontSize: 10.sp)
            : GoogleFonts.inter(
                color: color,
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
              ),
      ),
    );
  }

  Widget _buildSpecGrid(HearthFiberToolModel entry) {
    final specs = <(String, String)>[
      ('Era', entry.era.isEmpty ? 'Unknown' : entry.era),
      ('Orifice & Whorl', entry.orificeWhorlGeometry.isEmpty ? '—' : entry.orificeWhorlGeometry),
      ('Timber & Joinery', entry.timberJoineryComposition.isEmpty ? '—' : entry.timberJoineryComposition),
      ('Teeth Layout', entry.teethCountDensity.isEmpty ? '—' : entry.teethCountDensity),
      ('Proportions', entry.physicalProportions.isEmpty ? '—' : entry.physicalProportions),
      ('Temperature', entry.temperatureRange.isEmpty ? '—' : entry.temperatureRange),
    ];

    return Column(
      children: specs.map((s) {
        return Container(
          margin: EdgeInsets.only(bottom: 8.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: kCardSurface,
            borderRadius: BorderRadius.circular(kRadiusStandard),
            border: Border.all(color: kOutline),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 100.w,
                child: Text(
                  s.$1,
                  style: GoogleFonts.ibmPlexMono(
                    color: kSecondaryText,
                    fontSize: 10.sp,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  s.$2,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.inter(
                    color: kPrimaryText,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _detailCard(String title, String content) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: kCardSurface,
        borderRadius: BorderRadius.circular(kRadiusStandard),
        border: Border.all(color: kOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.ibmPlexMono(
              color: kSecondaryText,
              fontSize: 10.sp,
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            content,
            style: GoogleFonts.inter(
              color: kPrimaryText,
              fontSize: 15.sp,
              fontWeight: FontWeight.w300,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTags(HearthFiberToolModel entry) {
    return Wrap(
      spacing: 6.w,
      runSpacing: 6.h,
      children: entry.tags
          .map(
            (t) => Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(kRadiusPill),
                border: Border.all(color: kOutline),
              ),
              child: Text(
                t,
                style: GoogleFonts.ibmPlexMono(
                  color: kSecondaryText,
                  fontSize: 10.sp,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildActions(
    BuildContext context,
    WidgetRef ref,
    ProjectNotifier projectProv,
  ) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              projectProv.fillInput(ref, index);
              Navigator.pushNamed(
                context,
                '/add_screen',
                arguments: {'isEdit': true, 'currentIndex': index},
              );
            },
            child: Container(
              height: 50.h,
              decoration: BoxDecoration(
                color: kCardSurface,
                borderRadius: BorderRadius.circular(kRadiusPill),
                border: Border.all(color: kOutline),
              ),
              child: Center(
                child: Text(
                  'EDIT',
                  style: GoogleFonts.ibmPlexMono(
                    color: kPrimaryText,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: GestureDetector(
            onTap: () => _deleteDialog(context, projectProv),
            child: Container(
              height: 50.h,
              decoration: BoxDecoration(
                color: kCardSurface,
                borderRadius: BorderRadius.circular(kRadiusPill),
                border: Border.all(color: kError.withAlpha(100)),
              ),
              child: Center(
                child: Text(
                  'DELETE',
                  style: GoogleFonts.ibmPlexMono(
                    color: kError,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _deleteDialog(BuildContext context, ProjectNotifier projectProv) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: kCardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kRadiusStandard),
          side: const BorderSide(color: kOutline),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Remove Tool?',
                style: GoogleFonts.inter(
                  color: kPrimaryText,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'This will permanently delete this record from the archive.',
                style: GoogleFonts.inter(
                  color: kSecondaryText,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w300,
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('CANCEL',
                        style: GoogleFonts.ibmPlexMono(
                            color: kSecondaryText, fontSize: 11.sp)),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: () {
                      projectProv.deleteEntry(index);
                      Navigator.pop(ctx);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 18.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: kError,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'DELETE',
                        style: GoogleFonts.ibmPlexMono(
                          color: kCardSurface,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
