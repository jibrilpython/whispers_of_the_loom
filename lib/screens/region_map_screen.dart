import 'dart:io' show File;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whispers_of_the_loom/models/hearth_fiber_tool_model.dart';
import 'package:whispers_of_the_loom/providers/project_provider.dart';
import 'package:whispers_of_the_loom/screens/drafting_zone/drafting_zone_physics.dart';
import 'package:whispers_of_the_loom/screens/showcase/thread_field_state.dart';
import 'package:whispers_of_the_loom/screens/showcase/thread_field_layout.dart';
import 'package:whispers_of_the_loom/screens/showcase/thread_field_painter.dart';
import 'package:whispers_of_the_loom/screens/showcase/whorl_node.dart';

class RegionMapScreen extends ConsumerStatefulWidget {
  final bool isActive;
  const RegionMapScreen({super.key, this.isActive = true});

  @override
  ConsumerState<RegionMapScreen> createState() => _RegionMapScreenState();
}

class _RegionMapScreenState extends ConsumerState<RegionMapScreen>
    with TickerProviderStateMixin {
  late Ticker _ticker;
  double _time = 0;
  int? _selectedIndex;
  late AnimationController _panelController;
  late Animation<double> _panelSlide;
  Size _canvasSize = Size.zero;
  final ThreadFieldState _field = ThreadFieldState();
  int? _draggingIndex;

  @override
  void initState() {
    super.initState();
    _panelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _panelSlide = CurvedAnimation(
      parent: _panelController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    _ticker = createTicker((elapsed) {
      _time = elapsed.inMicroseconds / 1000000;
      _field.decay();
      _field.prunePulses(_time);
      if (mounted) setState(() {});
    });
    if (widget.isActive) _ticker.start();
  }

  @override
  void didUpdateWidget(RegionMapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive == oldWidget.isActive) return;
    if (widget.isActive) {
      if (!_ticker.isActive) _ticker.start();
    } else {
      if (_ticker.isActive) _ticker.stop();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _panelController.dispose();
    super.dispose();
  }

  void _selectNode(int index) {
    HapticFeedback.mediumImpact();
    setState(() => _selectedIndex = index);
    _panelController.forward(from: 0);
  }

  void _flickNode(int index) {
    HapticFeedback.selectionClick();
    setState(() => _field.flickNode(index));
  }

  void _windHub() {
    HapticFeedback.lightImpact();
    setState(() {
      _field.windHub();
      for (int i = 0; i < _field.spinBoost.length; i++) {
        _field.spinBoost[i] = (_field.spinBoost[i] + 0.2).clamp(0, 1.0);
      }
    });
  }

  void _canvasPulse(Offset pos) {
    if (_selectedIndex != null) {
      _deselect();
      return;
    }
    HapticFeedback.lightImpact();
    setState(() => _field.addPulse(pos, _time));
  }

  bool _isHubHit(Offset pos) {
    final hub = hubCenter(_canvasSize);
    return (pos - hub).distance < 52;
  }

  void _deselect() {
    _panelController.reverse().then((_) {
      if (mounted) setState(() => _selectedIndex = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(projectProvider).entries;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1812),
      body: Stack(
        fit: StackFit.expand,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              _canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
              _field.sync(entries.length, _canvasSize);
              final positions = _field.positions;

              return GestureDetector(
                onTapUp: (d) {
                  if (_isHubHit(d.localPosition)) {
                    _windHub();
                  } else if (!_hitNode(d.localPosition, positions)) {
                    _canvasPulse(d.localPosition);
                  }
                },
                behavior: HitTestBehavior.translucent,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    SizedBox.expand(
                      child: CustomPaint(
                        painter: ThreadFieldPainter(
                          time: _time,
                          nodePositions: positions,
                          spinBoost: _field.spinBoost,
                          hubBoost: _field.hubBoost,
                          pulses: _field.pulses,
                          bonds: _field.bonds,
                          selectedIndex: _selectedIndex,
                          draggingIndex: _draggingIndex,
                        ),
                      ),
                    ),
                    if (entries.isEmpty)
                      _EmptyConstellation(time: _time)
                    else
                      ...List.generate(entries.length, (i) {
                        final pos = positions[i];
                        final nodeSize = (_selectedIndex == i || _draggingIndex == i)
                            ? 88.0
                            : 72.0;
                        final boost = i < _field.spinBoost.length
                            ? _field.spinBoost[i]
                            : 0.0;

                        return Positioned(
                          left: pos.dx - nodeSize / 2,
                          top: pos.dy - nodeSize / 2,
                          child: GestureDetector(
                            onPanStart: (_) {
                              setState(() => _draggingIndex = i);
                              HapticFeedback.selectionClick();
                            },
                            onPanUpdate: (d) {
                              setState(() {
                                final (snapped, bonded) = _field.applyNodeDrag(
                                  i,
                                  d.delta,
                                  _canvasSize,
                                );
                                if (snapped) {
                                  HapticFeedback.mediumImpact();
                                } else if (bonded) {
                                  HapticFeedback.lightImpact();
                                }
                              });
                            },
                            onPanEnd: (_) {
                              setState(() => _draggingIndex = null);
                              HapticFeedback.lightImpact();
                            },
                            child: WhorlNode(
                              entry: entries[i],
                              time: _time,
                              index: i,
                              selected: _selectedIndex == i,
                              dragging: _draggingIndex == i,
                              spinBoost: boost,
                              onTap: () => _flickNode(i),
                              onLongPress: () => _selectNode(i),
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              );
            },
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(entries.length),
                const Spacer(),
                if (entries.isNotEmpty) _buildHintBar(),
              ],
            ),
          ),
          if (_selectedIndex != null)
            _DetailSheet(
              entry: entries[_selectedIndex!],
              index: _selectedIndex!,
              animation: _panelSlide,
              onClose: _deselect,
              canvasHeight: _canvasSize.height,
            ),
        ],
      ),
    );
  }

  bool _hitNode(Offset pos, List<Offset> positions) {
    for (int i = 0; i < positions.length; i++) {
      if ((positions[i] - pos).distance < 40) return true;
    }
    return false;
  }

  Widget _buildHintBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 108.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: kHearthDark.withAlpha(170),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kRawWoolCream.withAlpha(25)),
        ),
        child: Text(
          'TAP to spin  ·  DRAG to arrange  ·  HOLD for details  ·  PULL HARD to break lace',
          textAlign: TextAlign.center,
          style: GoogleFonts.ibmPlexMono(
            color: kRawWoolCream.withAlpha(120),
            fontSize: 7.5.sp,
            height: 1.4,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(int count) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 0),
      child: Row(
        children: [
          Container(
            width: 7.w,
            height: 7.w,
            decoration: BoxDecoration(
              color: kSpindleAmber,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: kSpindleAmber.withAlpha(80),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Thread Field',
                style: GoogleFonts.lora(
                  color: kRawWoolCream,
                  fontSize: 21.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                count == 0
                    ? 'awaiting first spindle'
                    : '$count ${count == 1 ? 'whorl' : 'whorls'} in orbit',
                style: GoogleFonts.ibmPlexMono(
                  color: kRawWoolCream.withAlpha(90),
                  fontSize: 9.sp,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyConstellation extends StatelessWidget {
  final double time;
  const _EmptyConstellation({required this.time});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: CustomPaint(
              painter: _PulsingHubPainter(time: time),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'THE FIELD IS DARK',
            style: GoogleFonts.ibmPlexMono(
              color: kRawWoolCream.withAlpha(70),
              fontSize: 10.sp,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Catalog a tool to set a whorl in motion.',
            style: GoogleFonts.inter(
              color: kRawWoolCream.withAlpha(45),
              fontSize: 13.sp,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingHubPainter extends CustomPainter {
  final double time;
  _PulsingHubPainter({required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final pulse = 0.7 + 0.3 * (0.5 + 0.5 * math.sin(time * 1.5));
    final r = 36.0 * pulse;

    canvas.drawCircle(
      c,
      r + 20,
      Paint()
        ..color = kSpindleAmber.withAlpha(20)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );

    canvas.drawOval(
      Rect.fromCenter(center: c, width: r * 2, height: r * 1.5),
      Paint()
        ..shader = RadialGradient(
          colors: [
            kRawWoolCream.withAlpha(60),
            kSpindleAmber.withAlpha(100),
            kTeaselBrown.withAlpha(140),
          ],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
    canvas.drawCircle(c, r * 0.12, Paint()..color = kHearthDark);
  }

  @override
  bool shouldRepaint(_PulsingHubPainter old) => old.time != time;
}

class _DetailSheet extends ConsumerWidget {
  final HearthFiberToolModel entry;
  final int index;
  final Animation<double> animation;
  final VoidCallback onClose;
  final double canvasHeight;

  const _DetailSheet({
    required this.entry,
    required this.index,
    required this.animation,
    required this.onClose,
    required this.canvasHeight,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoFile = entry.photoPath.isNotEmpty && File(entry.photoPath).existsSync()
        ? File(entry.photoPath)
        : null;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final slide = (1 - animation.value) * 320;
        return Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              onTap: onClose,
              child: Container(
                color: kHearthDark.withAlpha((animation.value * 160).round()),
              ),
            ),
            Transform.translate(offset: Offset(0, slide), child: child),
          ],
        );
      },
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: canvasHeight > 0 ? canvasHeight * 0.48 : 340,
          ),
          margin: EdgeInsets.fromLTRB(14.w, 0, 14.w, 100.h),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF221C16),
                Color(0xFF14100C),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: kRawWoolCream.withAlpha(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(120),
                blurRadius: 32,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 8.h),
                  width: 32.w,
                  height: 3,
                  decoration: BoxDecoration(
                    color: kRawWoolCream.withAlpha(50),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(18.w, 10.h, 18.w, 14.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: SizedBox(
                            width: 56.w,
                            height: 56.w,
                            child: WhorlNode(
                              entry: entry,
                              time: 0,
                              index: index,
                              selected: true,
                              onTap: () {},
                              onLongPress: () {},
                            ),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          entry.artisanHallmark.isEmpty
                              ? 'Unknown Hallmark'
                              : entry.artisanHallmark,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.lora(
                            color: kRawWoolCream,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          entry.spindleRegistryScroll.isEmpty
                              ? 'UNCATALOGUED'
                              : entry.spindleRegistryScroll,
                          style: GoogleFonts.ibmPlexMono(
                            color: kSpindleAmber.withAlpha(180),
                            fontSize: 8.sp,
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        if (photoFile != null)
                          Container(
                            height: 100.h,
                            width: double.infinity,
                            margin: EdgeInsets.only(bottom: 10.h),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: kRawWoolCream.withAlpha(20)),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.file(photoFile, fit: BoxFit.cover),
                          ),
                        _MetaRow(label: 'Craft', value: entry.craftClassification.label),
                        _MetaRow(label: 'Fiber', value: entry.fiberType.label),
                        _MetaRow(label: 'Region', value: entry.homesteadRegion.label),
                        _MetaRow(
                          label: 'Era',
                          value: entry.era.isEmpty ? '—' : entry.era,
                        ),
                        _MetaRow(
                          label: 'Material',
                          value: entry.timberJoineryComposition.isEmpty
                              ? '—'
                              : entry.timberJoineryComposition,
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            Expanded(
                              child: _SheetButton(
                                label: 'CLOSE',
                                outline: true,
                                onTap: onClose,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              flex: 2,
                              child: _SheetButton(
                                label: 'VIEW RECORD',
                                onTap: () {
                                  onClose();
                                  Navigator.pushNamed(
                                    context,
                                    '/info_screen',
                                    arguments: {'index': index},
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final String label;
  final String value;
  const _MetaRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 56.w,
            child: Text(
              label.toUpperCase(),
              style: GoogleFonts.ibmPlexMono(
                color: kRawWoolCream.withAlpha(90),
                fontSize: 8.sp,
                letterSpacing: 0.3,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                color: kRawWoolCream.withAlpha(220),
                fontSize: 11.sp,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetButton extends StatelessWidget {
  final String label;
  final bool outline;
  final VoidCallback onTap;

  const _SheetButton({
    required this.label,
    required this.onTap,
    this.outline = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: outline ? Colors.transparent : kSpindleAmber,
          borderRadius: BorderRadius.circular(8),
          border: outline
              ? Border.all(color: kRawWoolCream.withAlpha(60))
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.ibmPlexMono(
            color: outline ? kRawWoolCream.withAlpha(160) : kHearthDark,
            fontSize: 9.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
