import 'dart:io' show File;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whispers_of_the_loom/enum/my_enums.dart';
import 'package:whispers_of_the_loom/models/hearth_fiber_tool_model.dart';
import 'package:whispers_of_the_loom/providers/image_provider.dart';
import 'package:whispers_of_the_loom/providers/input_provider.dart';
import 'package:whispers_of_the_loom/providers/project_provider.dart';
import 'package:whispers_of_the_loom/providers/search_provider.dart';
import 'package:whispers_of_the_loom/utils/const.dart';
import 'package:whispers_of_the_loom/widgets/spindle_whorl_icon.dart';

class CollectionScreen extends ConsumerStatefulWidget {
  const CollectionScreen({super.key});

  @override
  ConsumerState<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends ConsumerState<CollectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final ScrollController _scrollController = ScrollController();
  FiberType? _selectedFiberFilter;
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (mounted) setState(() {});
    });
    _searchFocus.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchProv = ref.watch(searchProvider);
    final projectProv = ref.watch(projectProvider);
    final allEntries = projectProv.entries;

    final filteredByFiber = _selectedFiberFilter == null
        ? allEntries
        : allEntries.where((e) => e.fiberType == _selectedFiberFilter).toList();
    final entries = searchProv.filteredList(filteredByFiber);

    return Scaffold(
      backgroundColor: kBackground,
      body: projectProv.isLoading
          ? _buildLoadingBar()
          : CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildHeader(allEntries.length),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                    child: Column(
                      children: [
                        if (_showSearch) ...[
                          SizedBox(height: 16.h),
                          _buildSearchBar(),
                          SizedBox(height: 16.h),
                        ] else
                          SizedBox(height: 16.h),
                        _buildFiberFilterRow(),
                      ],
                    ),
                  ),
                ),
                entries.isEmpty
                    ? SliverFillRemaining(
                        hasScrollBody: false,
                        child: _buildEmptyState(),
                      )
                    : SliverPadding(
                        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 100.h),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, rowIndex) {
                              final startIndex = rowIndex * 2;
                              if (startIndex >= entries.length) return null;
                              final entry1 = entries[startIndex];
                              final entry2 = startIndex + 1 < entries.length
                                  ? entries[startIndex + 1]
                                  : null;
                              return Padding(
                                padding: EdgeInsets.only(bottom: 12.h),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: IntrinsicHeight(
                                        child: _ToolGridCard(
                                          entry: entry1,
                                          onTap: () {
                                            HapticFeedback.mediumImpact();
                                            Navigator.pushNamed(
                                              context,
                                              '/info_screen',
                                              arguments: {
                                                'index':
                                                    allEntries.indexOf(entry1),
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: entry2 != null
                                          ? IntrinsicHeight(
                                              child: _ToolGridCard(
                                                entry: entry2,
                                                onTap: () {
                                                  HapticFeedback
                                                      .mediumImpact();
                                                  Navigator.pushNamed(
                                                    context,
                                                    '/info_screen',
                                                    arguments: {
                                                      'index': allEntries
                                                          .indexOf(entry2),
                                                    },
                                                  );
                                                },
                                              ),
                                            )
                                          : const SizedBox(),
                                    ),
                                  ],
                                ),
                              );
                            },
                            childCount: (entries.length + 1) ~/ 2,
                          ),
                        ),
                      ),
              ],
            ),
    );
  }

  Widget _buildLoadingBar() {
    return Column(
      children: [
        LinearProgressIndicator(
          minHeight: 2.h,
          color: kAccent,
          backgroundColor: kOutline,
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildHeader(int count) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 52.h, 20.w, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Whispers',
                        style: GoogleFonts.lora(
                          color: kPrimaryText,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w600,
                          height: 1.0,
                        ),
                      ),
                      Text(
                        'of the Loom',
                        style: GoogleFonts.lora(
                          color: kPrimaryText,
                          fontSize: 32.sp,
                          fontWeight: FontWeight.w700,
                          height: 0.95,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    _iconBtn(
                      _showSearch ? Icons.close_rounded : Icons.search_rounded,
                      onTap: () {
                        setState(() {
                          _showSearch = !_showSearch;
                          if (!_showSearch) {
                            _searchController.clear();
                            ref
                                .read(searchProvider.notifier)
                                .clearSearchQuery();
                            _searchFocus.unfocus();
                          } else {
                            _searchFocus.requestFocus();
                          }
                        });
                      },
                    ),
                    SizedBox(width: 8.w),
                    _iconBtn(
                      Icons.add_rounded,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ref.read(inputProvider).prepareNewEntry();
                        ref.read(imageProvider).clearImage();
                        Navigator.pushNamed(context, '/add_screen');
                      },
                      filled: true,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: kCardSurface,
                borderRadius: BorderRadius.circular(kRadiusStandard),
                border: Border.all(color: kOutline),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SpindleWhorlIcon(
                    fiberType: FiberType.wool,
                    soundness: MechanicalSoundness.fullyOperational,
                    size: 14.w,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '${count.toString().padLeft(2, '0')} TOOLS IN COLLECTION',
                    style: GoogleFonts.ibmPlexMono(
                      color: kSecondaryText,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, {VoidCallback? onTap, bool filled = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44.w,
        height: 44.w,
        decoration: BoxDecoration(
          color: filled ? kAccent : kCardSurface,
          borderRadius: BorderRadius.circular(12),
          border: filled ? null : Border.all(color: kOutline),
          boxShadow: filled
              ? [
                  BoxShadow(
                    color: kAccent.withAlpha(40),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          color: filled ? kCardSurface : kPrimaryText,
          size: 20.sp,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    final isFocused = _searchFocus.hasFocus;
    final borderSide = isFocused
        ? const BorderSide(color: kAccent, width: 1.5)
        : const BorderSide(color: kOutline, width: 1.0);
    final outline = OutlineInputBorder(
      borderRadius: BorderRadius.circular(kRadiusPill),
      borderSide: borderSide,
    );
    return SizedBox(
      height: 48.h,
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocus,
        textAlignVertical: TextAlignVertical.center,
        onChanged: (v) => ref.read(searchProvider.notifier).setSearchQuery(v),
        style: GoogleFonts.inter(color: kPrimaryText, fontSize: 16.sp),
        decoration: InputDecoration(
          hintText: 'Search registry, hallmark, homestead...',
          hintStyle: GoogleFonts.inter(
            color: kSecondaryText.withAlpha(120),
            fontSize: 14.sp,
            fontWeight: FontWeight.w300,
          ),
          filled: true,
          fillColor: kCardSurface,
          prefixIcon: Icon(Icons.search_rounded, color: kSecondaryText, size: 20.sp),
          suffixIcon: _searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    ref.read(searchProvider.notifier).clearSearchQuery();
                  },
                  child: Icon(Icons.close_rounded, color: kSecondaryText, size: 18.sp),
                )
              : null,
          border: outline,
          enabledBorder: outline,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(kRadiusPill),
            borderSide: const BorderSide(color: kAccent, width: 1.5),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
        ),
      ),
    );
  }

  Widget _buildFiberFilterRow() {
    return SizedBox(
      height: 36.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _filterChip('All', null),
          ...FiberType.values.map((f) => _filterChip(f.label.split(' /').first, f)),
        ],
      ),
    );
  }

  Widget _filterChip(String label, FiberType? fiber) {
    final isSelected = _selectedFiberFilter == fiber;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedFiberFilter = fiber);
      },
      child: AnimatedContainer(
        duration: kTransitionDuration,
        margin: EdgeInsets.only(right: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: isSelected ? kAccent : kCardSurface,
          borderRadius: BorderRadius.circular(kRadiusPill),
          border: Border.all(color: isSelected ? kAccent : kOutline),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.ibmPlexMono(
            color: isSelected ? kCardSurface : kSecondaryText,
            fontSize: 11.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SpindleWhorlIcon(
            fiberType: FiberType.wool,
            soundness: MechanicalSoundness.unknown,
            size: 48.w,
          ),
          SizedBox(height: 24.h),
          Text(
            'NO TOOLS IN THIS COLLECTION YET.',
            style: GoogleFonts.ibmPlexMono(
              color: kSecondaryText,
              fontSize: 12.sp,
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: () {
              ref.read(inputProvider).prepareNewEntry();
              ref.read(imageProvider).clearImage();
              Navigator.pushNamed(context, '/add_screen');
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: kAccent,
                borderRadius: BorderRadius.circular(kRadiusPill),
              ),
              child: Text(
                'CATALOG FIRST TOOL',
                style: GoogleFonts.ibmPlexMono(
                  color: kCardSurface,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolGridCard extends ConsumerWidget {
  final HearthFiberToolModel entry;
  final VoidCallback onTap;

  const _ToolGridCard({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageProv = ref.watch(imageProvider);
    final photoPath = imageProv.getImagePath(entry.photoPath);
    final photoFile =
        photoPath != null && entry.photoPath.isNotEmpty ? File(photoPath) : null;
    final craftColor = getCraftColor(entry.craftClassification);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: kCardSurface,
          borderRadius: BorderRadius.circular(14),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 85.h,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ColoredBox(
                        color: kActiveBg,
                        child: photoFile != null && photoFile.existsSync()
                            ? Image.file(photoFile, fit: BoxFit.cover)
                            : Center(
                                child: SpindleWhorlIcon(
                                  fiberType: entry.fiberType,
                                  soundness: entry.mechanicalSoundness,
                                  size: 34.w,
                                ),
                              ),
                      ),
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        child: Container(width: 4.w, color: craftColor),
                      ),
                      Positioned(
                        top: 6.w,
                        right: 6.w,
                        child: _CardPill(
                          label: entry.fiberType.label.split(' /').first,
                        ),
                      ),
                      if (entry.era.isNotEmpty)
                        Positioned(
                          bottom: 6.w,
                          left: 6.w,
                          child: _CardPill(
                            label: entry.era,
                            filled: true,
                            color: kAccent,
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(10.w, 10.w, 10.w, 10.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          entry.artisanHallmark.isEmpty
                              ? 'Unknown Hallmark'
                              : entry.artisanHallmark,
                          style: GoogleFonts.lora(
                            color: kPrimaryText,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8.h),
                        Container(height: 1, color: kOutline.withAlpha(80)),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Icon(
                              Icons.place_outlined,
                              size: 11.sp,
                              color: kHerbGreen.withAlpha(180),
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Text(
                                entry.homesteadRegion.label,
                                style: GoogleFonts.inter(
                                  color: kSecondaryText,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            Flexible(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: craftColor.withAlpha(20),
                                  borderRadius:
                                      BorderRadius.circular(kRadiusPill),
                                ),
                                child: Text(
                                  entry.craftClassification.label,
                                  style: GoogleFonts.inter(
                                    color: craftColor,
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            SizedBox(width: 6.w),
                            SpindleWhorlIcon(
                              fiberType: entry.fiberType,
                              soundness: entry.mechanicalSoundness,
                              size: 16.w,
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          entry.spindleRegistryScroll.isEmpty
                              ? 'UNCATALOGUED'
                              : entry.spindleRegistryScroll,
                          style: GoogleFonts.ibmPlexMono(
                            color: kAccent.withAlpha(140),
                            fontSize: 7.sp,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: kOutline),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardPill extends StatelessWidget {
  final String label;
  final bool filled;
  final Color? color;

  const _CardPill({
    required this.label,
    this.filled = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? kPrimaryText;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: filled ? c.withAlpha(220) : kCardSurface.withAlpha(230),
        borderRadius: BorderRadius.circular(kRadiusPill),
        border: Border.all(color: filled ? Colors.transparent : kOutline),
      ),
      child: Text(
        label,
        style: GoogleFonts.ibmPlexMono(
          color: filled ? kCardSurface : kPrimaryText,
          fontSize: 8.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
