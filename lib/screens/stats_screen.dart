import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whispers_of_the_loom/enum/my_enums.dart';
import 'package:whispers_of_the_loom/models/hearth_fiber_tool_model.dart';
import 'package:whispers_of_the_loom/providers/project_provider.dart';
import 'package:whispers_of_the_loom/utils/const.dart';
import 'package:whispers_of_the_loom/widgets/spindle_whorl_icon.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _countUp;

  String? _filterFiber;
  String? _filterCraft;
  String? _filterRegion;
  String? _filterHallmark;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _countUp = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      _filterFiber = null;
      _filterCraft = null;
      _filterRegion = null;
      _filterHallmark = null;
    });
  }

  List<HearthFiberToolModel> _filtered(List<HearthFiberToolModel> all) {
    return all.where((e) {
      if (_filterFiber != null &&
          e.fiberType.label.split(' /').first != _filterFiber &&
          e.fiberType.label != _filterFiber) {
        return false;
      }
      if (_filterCraft != null &&
          e.craftClassification.label != _filterCraft) {
        return false;
      }
      if (_filterRegion != null && e.homesteadRegion.label != _filterRegion) {
        return false;
      }
      if (_filterHallmark != null && e.artisanHallmark != _filterHallmark) {
        return false;
      }
      return true;
    }).toList();
  }

  bool get _hasActiveFilter =>
      _filterFiber != null ||
      _filterCraft != null ||
      _filterRegion != null ||
      _filterHallmark != null;

  @override
  Widget build(BuildContext context) {
    final allEntries = ref.watch(projectProvider).entries;
    final displayEntries =
        _hasActiveFilter ? _filtered(allEntries) : allEntries;

    return Scaffold(
      backgroundColor: kBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildHeader(),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 120.h),
            sliver: allEntries.isEmpty
                ? SliverFillRemaining(
                    hasScrollBody: false,
                    child: _emptyState(),
                  )
                : SliverList(
                    delegate: SliverChildListDelegate([
                      _OverviewHero(entries: allEntries, countUp: _countUp),
                      if (_hasActiveFilter) ...[
                        SizedBox(height: 16.h),
                        _ActiveFilterBar(
                          fiber: _filterFiber,
                          craft: _filterCraft,
                          region: _filterRegion,
                          hallmark: _filterHallmark,
                          onClear: _clearFilters,
                          resultCount: displayEntries.length,
                        ),
                        SizedBox(height: 16.h),
                      ] else
                        SizedBox(height: 28.h),
                      _FiberBreakdown(
                        entries: allEntries,
                        selected: _filterFiber,
                        onSelect: (label) => setState(() {
                          _filterFiber =
                              _filterFiber == label ? null : label;
                        }),
                      ),
                      SizedBox(height: 20.h),
                      _CraftBreakdown(
                        entries: allEntries,
                        selected: _filterCraft,
                        onSelect: (label) => setState(() {
                          _filterCraft =
                              _filterCraft == label ? null : label;
                        }),
                      ),
                      SizedBox(height: 20.h),
                      _RegionBreakdown(
                        entries: allEntries,
                        selected: _filterRegion,
                        onSelect: (label) => setState(() {
                          _filterRegion =
                              _filterRegion == label ? null : label;
                        }),
                      ),
                      SizedBox(height: 20.h),
                      _HallmarkRanking(
                        entries: allEntries,
                        selected: _filterHallmark,
                        onSelect: (hallmark) => setState(() {
                          _filterHallmark =
                              _filterHallmark == hallmark ? null : hallmark;
                        }),
                      ),
                      if (_hasActiveFilter && displayEntries.isNotEmpty) ...[
                        SizedBox(height: 24.h),
                        _FilteredPreview(entries: displayEntries),
                      ],
                    ]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final count = ref.watch(projectProvider).entries.length;
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 52.h, 20.w, 8.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Archive',
                        style: GoogleFonts.lora(
                          color: kPrimaryText,
                          fontSize: 32.sp,
                          fontWeight: FontWeight.w700,
                          height: 1.0,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'COLLECTION METRICS',
                        style: GoogleFonts.ibmPlexMono(
                          color: kSecondaryText,
                          fontSize: 10.sp,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [kAccent, kAccent.withAlpha(180)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(kRadiusPill),
                    boxShadow: [
                      BoxShadow(
                        color: kAccent.withAlpha(40),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    '$count',
                    style: GoogleFonts.lora(
                      color: kCardSurface,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            Container(
              height: 3.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: LinearGradient(
                  colors: [
                    kAccent,
                    kHerbGreen.withAlpha(180),
                    kAccent.withAlpha(0),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Text(
        'NO TOOLS IN THIS COLLECTION YET.',
        style: GoogleFonts.ibmPlexMono(
          color: kSecondaryText,
          fontSize: 13.sp,
        ),
      ),
    );
  }
}

Color _fiberColor(FiberType type) {
  switch (type) {
    case FiberType.wool:
      return kAccent;
    case FiberType.flax:
      return kHerbGreen;
    case FiberType.silk:
      return const Color(0xFF8B6F5E);
    case FiberType.cotton:
      return const Color(0xFF6B5B4E);
    case FiberType.bastFiber:
      return const Color(0xFF5C7A62);
    case FiberType.blended:
      return kSecondaryText;
  }
}

class _ActiveFilterBar extends StatelessWidget {
  final String? fiber;
  final String? craft;
  final String? region;
  final String? hallmark;
  final VoidCallback onClear;
  final int resultCount;

  const _ActiveFilterBar({
    this.fiber,
    this.craft,
    this.region,
    this.hallmark,
    required this.onClear,
    required this.resultCount,
  });

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[
      if (fiber != null) _filterChip(fiber!, kHerbGreen),
      if (craft != null) _filterChip(craft!, kAccent),
      if (region != null) _filterChip(region!, kPrimaryText),
      if (hallmark != null) _filterChip(hallmark!, kSecondaryText),
    ];

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: kActiveBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kAccent.withAlpha(40)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_alt_rounded,
            color: kAccent.withAlpha(180),
            size: 14.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ...chips,
                  SizedBox(width: 6.w),
                  Text(
                    '$resultCount result${resultCount == 1 ? '' : 's'}',
                    style: GoogleFonts.ibmPlexMono(
                      color: kSecondaryText,
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: onClear,
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: kCardSurface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: kOutline),
              ),
              child: Icon(
                Icons.close_rounded,
                color: kSecondaryText,
                size: 14.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, Color color) {
    return Container(
      margin: EdgeInsets.only(right: 4.w),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Text(
        label,
        style: GoogleFonts.ibmPlexMono(
          color: color,
          fontSize: 9.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _FilteredPreview extends ConsumerWidget {
  final List<HearthFiberToolModel> entries;
  const _FilteredPreview({required this.entries});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(projectProvider).entries;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: Text(
            'MATCHING ENTRIES',
            style: GoogleFonts.ibmPlexMono(
              color: kSecondaryText,
              fontSize: 9.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...entries.map((e) => _MiniEntryCard(entry: e, all: all)),
      ],
    );
  }
}

class _MiniEntryCard extends StatelessWidget {
  final HearthFiberToolModel entry;
  final List<HearthFiberToolModel> all;
  const _MiniEntryCard({required this.entry, required this.all});

  @override
  Widget build(BuildContext context) {
    final soundnessColor = getSoundnessColor(entry.mechanicalSoundness);
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        final idx = all.indexOf(entry);
        if (idx >= 0) {
          Navigator.pushNamed(
            context,
            '/info_screen',
            arguments: {'index': idx},
          );
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.fromLTRB(12.w, 12.w, 16.w, 12.w),
        decoration: BoxDecoration(
          color: kCardSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kOutline),
        ),
        child: Row(
          children: [
            SpindleWhorlIcon(
              fiberType: entry.fiberType,
              soundness: entry.mechanicalSoundness,
              size: 20.w,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.artisanHallmark.isEmpty
                        ? 'Unknown Hallmark'
                        : entry.artisanHallmark,
                    style: GoogleFonts.inter(
                      color: kPrimaryText,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    entry.spindleRegistryScroll.isEmpty
                        ? 'UNCATALOGUED'
                        : entry.spindleRegistryScroll,
                    style: GoogleFonts.ibmPlexMono(
                      color: kSecondaryText,
                      fontSize: 10.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                color: soundnessColor,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 8.w),
            Icon(
              Icons.chevron_right_rounded,
              color: kSecondaryText,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewHero extends StatelessWidget {
  final List<HearthFiberToolModel> entries;
  final Animation<double> countUp;
  const _OverviewHero({required this.entries, required this.countUp});

  String _eraSpan() {
    final years = <int>[];
    for (final e in entries) {
      final digits = e.era.replaceAll(RegExp(r'[^0-9]'), '');
      if (digits.length >= 4) {
        years.add(int.tryParse(digits.substring(0, 4)) ?? 0);
      }
    }
    if (years.isEmpty) return '---';
    final min = years.reduce((a, b) => a < b ? a : b);
    final max = years.reduce((a, b) => a > b ? a : b);
    if (min == max) return '$min';
    return '$min\u2013$max';
  }

  int _operationalCount() => entries
      .where((e) => e.mechanicalSoundness.isUsable)
      .length;

  @override
  Widget build(BuildContext context) {
    final hallmarkCount = entries
        .map((e) => e.artisanHallmark)
        .where((m) => m.isNotEmpty)
        .toSet()
        .length;
    final total = entries.length;
    final eraText = _eraSpan();
    final operational = _operationalCount();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kCardSurface, kActiveBg],
        ),
        border: Border.all(color: kOutline),
        boxShadow: [
          BoxShadow(
            color: kAccent.withAlpha(12),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20.w, 22.w, 20.w, 18.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [kAccent.withAlpha(18), Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                AnimatedBuilder(
                  animation: countUp,
                  builder: (context, _) {
                    final display = (countUp.value * total).round();
                    return Text(
                      '$display',
                      style: GoogleFonts.lora(
                        color: kAccent,
                        fontSize: 56.sp,
                        fontWeight: FontWeight.w700,
                        height: 1.0,
                      ),
                    );
                  },
                ),
                SizedBox(height: 4.h),
                Text(
                  'TOOLS ARCHIVED',
                  style: GoogleFonts.ibmPlexMono(
                    color: kSecondaryText,
                    fontSize: 10.sp,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 14.w),
            child: Row(
              children: [
                Expanded(
                  child: _StatTile(
                    icon: Icons.draw_outlined,
                    value: '$hallmarkCount',
                    label: 'Hallmarks',
                    color: kAccent,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _StatTile(
                    icon: Icons.schedule_outlined,
                    value: eraText,
                    label: 'Era span',
                    color: kHerbGreen,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _StatTile(
                    icon: Icons.settings_suggest_outlined,
                    value: '$operational',
                    label: 'Operational',
                    color: const Color(0xFF8B6914),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: kCardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color.withAlpha(180), size: 14.sp),
          SizedBox(height: 6.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: GoogleFonts.lora(
                color: kPrimaryText,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                height: 1.0,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: GoogleFonts.ibmPlexMono(
              color: kSecondaryText,
              fontSize: 8.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accentColor;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.child,
    this.icon = Icons.insights_outlined,
    this.accentColor = kAccent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kCardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kOutline),
        boxShadow: [
          BoxShadow(
            color: accentColor.withAlpha(10),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(16.w, 14.w, 16.w, 12.w),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: kOutline.withAlpha(100)),
              ),
              gradient: LinearGradient(
                colors: [accentColor.withAlpha(12), Colors.transparent],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 28.w,
                  height: 28.w,
                  decoration: BoxDecoration(
                    color: accentColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: accentColor, size: 14.sp),
                ),
                SizedBox(width: 10.w),
                Text(
                  title,
                  style: GoogleFonts.ibmPlexMono(
                    color: kPrimaryText,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _FiberBreakdown extends StatelessWidget {
  final List<HearthFiberToolModel> entries;
  final String? selected;
  final ValueChanged<String> onSelect;

  const _FiberBreakdown({
    required this.entries,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final counts = <FiberType, int>{};
    for (final e in entries) {
      counts[e.fiberType] = (counts[e.fiberType] ?? 0) + 1;
    }

    final total = entries.length;
    final types = FiberType.values.where((t) => (counts[t] ?? 0) > 0).toList();
    if (types.isEmpty) {
      return _SectionCard(
        title: 'FIBER TYPE BREAKDOWN',
        child: Text(
          'No fiber data recorded.',
          style: GoogleFonts.inter(
            color: kSecondaryText,
            fontSize: 14.sp,
            fontWeight: FontWeight.w300,
          ),
        ),
      );
    }

    return _SectionCard(
      title: 'FIBER TYPE BREAKDOWN',
      icon: Icons.waves_outlined,
      accentColor: kHerbGreen,
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 88.w,
                height: 88.w,
                child: CustomPaint(
                  painter: _DonutChartPainter(
                    segments: types
                        .map(
                          (t) => _DonutSegment(
                            color: _fiberColor(t),
                            value: (counts[t] ?? 0).toDouble(),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  children: types.map((type) {
                    final count = counts[type] ?? 0;
                    final pct = total > 0 ? count / total : 0.0;
                    final color = _fiberColor(type);
                    return Padding(
                      padding: EdgeInsets.only(bottom: 6.h),
                      child: Row(
                        children: [
                          Container(
                            width: 6.w,
                            height: 6.w,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: Text(
                              type.label.split(' /').first,
                              style: GoogleFonts.inter(
                                color: kSecondaryText,
                                fontSize: 11.sp,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${(pct * 100).round()}%',
                            style: GoogleFonts.ibmPlexMono(
                              color: color,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _spectrumBar(types, counts, total),
          SizedBox(height: 16.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: types.map((type) {
              final count = counts[type] ?? 0;
              final label = type.label.split(' /').first;
              final isSelected = selected == label || selected == type.label;
              final color = _fiberColor(type);
              return GestureDetector(
                onTap: () => onSelect(label),
                child: AnimatedContainer(
                  duration: kTransitionDuration,
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? color.withAlpha(20) : kBackground,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? color : kOutline,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        label,
                        style: GoogleFonts.inter(
                          color: isSelected ? kPrimaryText : kSecondaryText,
                          fontSize: 12.sp,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '$count',
                        style: GoogleFonts.ibmPlexMono(
                          color: isSelected ? color : kSecondaryText,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          if (selected != null) ...[SizedBox(height: 12.h), _filterHint()],
        ],
      ),
    );
  }

  Widget _spectrumBar(
    List<FiberType> types,
    Map<FiberType, int> counts,
    int total,
  ) {
    return Container(
      height: 28.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: kPrimaryText.withAlpha(12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: types.map((type) {
          final count = counts[type] ?? 0;
          final pct = total > 0 ? count / total : 0.0;
          final color = _fiberColor(type);
          return Expanded(
            flex: (pct * 100).round().clamp(1, 100),
            child: Container(
              color: color,
              child: Center(
                child: pct > 0.08
                    ? Text(
                        '${(pct * 100).toInt()}%',
                        style: GoogleFonts.ibmPlexMono(
                          color: kCardSurface,
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _filterHint() {
    return Row(
      children: [
        Icon(
          Icons.touch_app_rounded,
          color: kAccent.withAlpha(120),
          size: 12.sp,
        ),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            'Tap another chip to refine, or tap again to clear',
            style: GoogleFonts.ibmPlexMono(
              color: kSecondaryText,
              fontSize: 9.sp,
            ),
          ),
        ),
      ],
    );
  }
}

class _CraftBreakdown extends StatelessWidget {
  final List<HearthFiberToolModel> entries;
  final String? selected;
  final ValueChanged<String> onSelect;

  const _CraftBreakdown({
    required this.entries,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final counts = <CraftClassification, int>{};
    for (final e in entries) {
      counts[e.craftClassification] =
          (counts[e.craftClassification] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxVal = sorted.isEmpty ? 1 : sorted.first.value;

    return _SectionCard(
      title: 'CRAFT CLASSIFICATION',
      icon: Icons.handyman_outlined,
      accentColor: kAccent,
      child: Column(
        children: [
          ...sorted.map((e) {
            final pct = e.value / maxVal;
            final isSelected = selected == e.key.label;
            final color = getCraftColor(e.key);
            return GestureDetector(
              onTap: () => onSelect(e.key.label),
              child: AnimatedContainer(
                duration: kTransitionDuration,
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: isSelected ? color.withAlpha(12) : kBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? color.withAlpha(80) : kOutline,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            e.key.label,
                            style: GoogleFonts.inter(
                              color: isSelected ? kPrimaryText : kPrimaryText.withAlpha(200),
                              fontSize: 13.sp,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          '${e.value}',
                          style: GoogleFonts.ibmPlexMono(
                            color: color,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(kRadiusPill),
                      child: SizedBox(
                        height: 6.h,
                        child: Stack(
                          children: [
                            Container(color: kOutline),
                            FractionallySizedBox(
                              widthFactor: pct,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [color, color.withAlpha(140)],
                                  ),
                                  borderRadius: BorderRadius.circular(kRadiusPill),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _DonutSegment {
  final Color color;
  final double value;
  const _DonutSegment({required this.color, required this.value});
}

class _DonutChartPainter extends CustomPainter {
  final List<_DonutSegment> segments;

  _DonutChartPainter({required this.segments});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final stroke = radius * 0.28;
    final total = segments.fold<double>(0, (s, e) => s + e.value);
    if (total == 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - stroke / 2),
        0,
        math.pi * 2,
        false,
        Paint()
          ..color = kOutline
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke,
      );
      return;
    }

    var start = -math.pi / 2;
    for (final seg in segments) {
      if (seg.value <= 0) continue;
      final sweep = (seg.value / total) * math.pi * 2;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - stroke / 2),
        start,
        sweep,
        false,
        Paint()
          ..color = seg.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round,
      );
      start += sweep;
    }

    canvas.drawCircle(center, radius * 0.42, Paint()..color = kCardSurface);
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter old) => true;
}

class _RegionBreakdown extends StatelessWidget {
  final List<HearthFiberToolModel> entries;
  final String? selected;
  final ValueChanged<String> onSelect;

  const _RegionBreakdown({
    required this.entries,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final counts = <HomesteadRegion, int>{};
    for (final e in entries) {
      counts[e.homesteadRegion] = (counts[e.homesteadRegion] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxVal = sorted.isEmpty ? 1 : sorted.first.value;

    return _SectionCard(
      title: 'HOMESTEAD REGION',
      icon: Icons.place_outlined,
      accentColor: kHerbGreen,
      child: Column(
        children: [
          ...sorted.map((e) {
            final pct = e.value / maxVal;
            final isSelected = selected == e.key.label;
            return GestureDetector(
              onTap: () => onSelect(e.key.label),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: kOutline.withAlpha(60),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 110.w,
                      child: Text(
                        e.key.label,
                        style: GoogleFonts.inter(
                          color: isSelected
                              ? kPrimaryText
                              : kPrimaryText.withAlpha(180),
                          fontSize: 14.sp,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: Container(
                          height: 8.h,
                          color: kOutline,
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: pct,
                            child: Container(
                              color: isSelected
                                  ? kHerbGreen
                                  : kHerbGreen.withAlpha(120),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    SizedBox(
                      width: 24.w,
                      child: Text(
                        '${e.value}',
                        textAlign: TextAlign.right,
                        style: GoogleFonts.ibmPlexMono(
                          color: isSelected ? kPrimaryText : kSecondaryText,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _HallmarkRanking extends StatelessWidget {
  final List<HearthFiberToolModel> entries;
  final String? selected;
  final ValueChanged<String> onSelect;

  const _HallmarkRanking({
    required this.entries,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final counts = <String, int>{};
    for (final e in entries) {
      if (e.artisanHallmark.isNotEmpty) {
        counts[e.artisanHallmark] = (counts[e.artisanHallmark] ?? 0) + 1;
      }
    }
    if (counts.isEmpty) {
      return _SectionCard(
        title: 'ARTISAN HALLMARK RANKING',
        child: Text(
          'No hallmark data recorded.',
          style: GoogleFonts.inter(
            color: kSecondaryText,
            fontSize: 14.sp,
            fontWeight: FontWeight.w300,
          ),
        ),
      );
    }

    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxVal = sorted.first.value;
    const shown = 5;
    final top = sorted.take(shown).toList();
    final rest = sorted.skip(shown).toList();
    final othersTools = rest.fold<int>(0, (sum, e) => sum + e.value);

    return _SectionCard(
      title: 'ARTISAN HALLMARK RANKING',
      icon: Icons.military_tech_outlined,
      accentColor: kAccent,
      child: Column(
        children: [
          ...List.generate(top.length, (i) {
            final e = top[i];
            final pct = e.value / maxVal;
            final isSelected = selected == e.key;
            return GestureDetector(
              onTap: () => onSelect(e.key),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: kOutline.withAlpha(60), width: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20.w,
                      child: Text(
                        '${i + 1}',
                        style: GoogleFonts.ibmPlexMono(
                          color: kSecondaryText.withAlpha(120),
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        e.key,
                        style: GoogleFonts.inter(
                          color: isSelected
                              ? kPrimaryText
                              : kPrimaryText.withAlpha(180),
                          fontSize: 14.sp,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: Container(
                        width: 60.w,
                        height: 8.h,
                        color: kOutline,
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: pct,
                          child: Container(
                            color: isSelected ? kAccent : kAccent.withAlpha(120),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    SizedBox(
                      width: 24.w,
                      child: Text(
                        '${e.value}',
                        textAlign: TextAlign.right,
                        style: GoogleFonts.ibmPlexMono(
                          color: isSelected ? kPrimaryText : kSecondaryText,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          if (rest.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Row(
                children: [
                  SizedBox(width: 20.w),
                  Expanded(
                    child: Text(
                      'Others…',
                      style: GoogleFonts.inter(
                        color: kSecondaryText,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  Text(
                    '${rest.length} more · $othersTools',
                    style: GoogleFonts.ibmPlexMono(
                      color: kSecondaryText.withAlpha(160),
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
