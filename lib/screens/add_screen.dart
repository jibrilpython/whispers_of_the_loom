import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whispers_of_the_loom/common/photo_bottom_sheet.dart';
import 'package:whispers_of_the_loom/enum/my_enums.dart';
import 'package:whispers_of_the_loom/providers/image_provider.dart';
import 'package:whispers_of_the_loom/providers/input_provider.dart';
import 'package:whispers_of_the_loom/providers/project_provider.dart';
import 'package:whispers_of_the_loom/utils/const.dart';

class AddScreen extends ConsumerStatefulWidget {
  final bool isEdit;
  final int currentIndex;
  const AddScreen({super.key, this.isEdit = false, this.currentIndex = 0});

  @override
  ConsumerState<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends ConsumerState<AddScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  late TextEditingController _scrollCtrl;
  late TextEditingController _hallmarkCtrl;
  late TextEditingController _eraCtrl;
  late TextEditingController _orificeCtrl;
  late TextEditingController _timberCtrl;
  late TextEditingController _teethCtrl;
  late TextEditingController _proportionsCtrl;
  late TextEditingController _homesteadCtrl;
  late TextEditingController _tempCtrl;
  late TextEditingController _facilityCtrl;
  late TextEditingController _notesCtrl;
  late TextEditingController _tagsCtrl;

  @override
  void initState() {
    super.initState();
    final p = ref.read(inputProvider);
    _scrollCtrl = TextEditingController(text: p.spindleRegistryScroll);
    _hallmarkCtrl = TextEditingController(text: p.artisanHallmark);
    _eraCtrl = TextEditingController(text: p.era);
    _orificeCtrl = TextEditingController(text: p.orificeWhorlGeometry);
    _timberCtrl = TextEditingController(text: p.timberJoineryComposition);
    _teethCtrl = TextEditingController(text: p.teethCountDensity);
    _proportionsCtrl = TextEditingController(text: p.physicalProportions);
    _homesteadCtrl = TextEditingController(text: p.homesteadGroundZero);
    _tempCtrl = TextEditingController(text: p.temperatureRange);
    _facilityCtrl = TextEditingController(text: p.calibrationFacility);
    _notesCtrl = TextEditingController(text: p.notes);
    _tagsCtrl = TextEditingController(text: p.tags.join(', '));
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final c in [
      _scrollCtrl, _hallmarkCtrl, _eraCtrl, _orificeCtrl, _timberCtrl,
      _teethCtrl, _proportionsCtrl, _homesteadCtrl, _tempCtrl,
      _facilityCtrl, _notesCtrl, _tagsCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  bool _validateStep(int step) {
    final p = ref.read(inputProvider);
    if (step == 0) {
      if (p.artisanHallmark.trim().isEmpty) {
        _showError('Artisan hallmark is required.');
        return false;
      }
    }
    return true;
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.inter(color: kCardSurface)),
        backgroundColor: kError,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _nextStep() {
    if (!_validateStep(_currentStep)) return;
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: kTransitionDuration,
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    } else {
      _save();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: kTransitionDuration,
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep--);
    }
  }

  Future<void> _save() async {
    final p = ref.read(inputProvider);
    if (p.artisanHallmark.trim().isEmpty) {
      _showError('Artisan hallmark is required.');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _SavingDialog(),
    );
    await Future.delayed(const Duration(milliseconds: 600));

    if (widget.isEdit) {
      ref.read(projectProvider).editEntry(ref, widget.currentIndex);
    } else {
      ref.read(projectProvider).addEntry(ref);
    }

    if (mounted) {
      Navigator.pop(context);
      Navigator.pop(context);
      ref.read(inputProvider).clearAll();
      ref.read(imageProvider).clearImage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = ref.watch(inputProvider);
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: kSecondaryText, size: 22.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.isEdit ? 'Edit Archive Entry' : 'Catalog New Tool'),
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1(p),
                _buildStep2(p),
                _buildStep3(p),
              ],
            ),
          ),
          _buildNavButtons(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    const labels = ['Identity', 'Craft', 'Provenance'];
    const icons = [
      Icons.fingerprint_rounded,
      Icons.precision_manufacturing_outlined,
      Icons.map_outlined,
    ];
    final progress = (_currentStep + 1) / 3;

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'STEP ${_currentStep + 1} OF 3',
                style: GoogleFonts.ibmPlexMono(
                  color: kSecondaryText,
                  fontSize: 9.sp,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).round()}%',
                style: GoogleFonts.ibmPlexMono(
                  color: kAccent,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(kRadiusPill),
            child: SizedBox(
              height: 4.h,
              child: Stack(
                children: [
                  Container(color: kOutline),
                  AnimatedFractionallySizedBox(
                    duration: kTransitionDuration,
                    curve: Curves.easeOutCubic,
                    widthFactor: progress,
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [kAccent, kHerbGreen.withAlpha(200)],
                        ),
                        borderRadius: BorderRadius.circular(kRadiusPill),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              for (int i = 0; i < 3; i++) ...[
                _stepNode(i, labels[i], icons[i]),
                if (i < 2)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 18.h),
                      child: AnimatedContainer(
                        duration: kTransitionDuration,
                        height: 2.h,
                        margin: EdgeInsets.symmetric(horizontal: 6.w),
                        decoration: BoxDecoration(
                          color: i < _currentStep ? kHerbGreen : kOutline,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _stepNode(int i, String label, IconData icon) {
    final active = i == _currentStep;
    final done = i < _currentStep;
    return Column(
      children: [
        AnimatedContainer(
          duration: kTransitionDuration,
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
            color: done
                ? kHerbGreen
                : active
                    ? kAccent
                    : kCardSurface,
            shape: BoxShape.circle,
            border: Border.all(
              color: done || active ? Colors.transparent : kOutline,
              width: 1.5,
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: kAccent.withAlpha(50),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            done ? Icons.check_rounded : icon,
            color: done || active ? kCardSurface : kSecondaryText,
            size: 16.sp,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.ibmPlexMono(
            color: active
                ? kAccent
                : done
                    ? kHerbGreen
                    : kSecondaryText,
            fontSize: 8.sp,
            fontWeight: active ? FontWeight.w700 : FontWeight.w400,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }

  Widget _buildNavButtons() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 32.h),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: GestureDetector(
                onTap: _prevStep,
                child: Container(
                  height: 50.h,
                  decoration: BoxDecoration(
                    color: kCardSurface,
                    borderRadius: BorderRadius.circular(kRadiusPill),
                    border: Border.all(color: kOutline),
                  ),
                  child: Center(
                    child: Text(
                      'BACK',
                      style: GoogleFonts.ibmPlexMono(
                        color: kSecondaryText,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) SizedBox(width: 12.w),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: _nextStep,
              child: Container(
                height: 50.h,
                decoration: BoxDecoration(
                  color: kAccent,
                  borderRadius: BorderRadius.circular(kRadiusPill),
                ),
                child: Center(
                  child: Text(
                    _currentStep < 2 ? 'CONTINUE' : 'COMMIT TO ARCHIVE',
                    style: GoogleFonts.ibmPlexMono(
                      color: kCardSurface,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1(InputNotifier p) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
      children: [
        _buildPhotoModule(),
        SizedBox(height: 24.h),
        _sectionHeader('SPINDLE REGISTRY'),
        _buildModule([
          _field(
            label: 'Registry Scroll',
            ctrl: _scrollCtrl,
            hint: 'WOL-FIBER-4421-WOOL-S',
            isMono: true,
            readOnly: !widget.isEdit,
            onChanged: (v) => p.spindleRegistryScroll = v,
          ),
          _field(
            label: 'Artisan Hallmark',
            ctrl: _hallmarkCtrl,
            hint: 'HearthSide Woodworks',
            onChanged: (v) => p.artisanHallmark = v,
          ),
          _chipPicker<CraftClassification>(
            label: 'Craft Classification',
            values: CraftClassification.values,
            selected: p.craftClassification,
            labelOf: (v) => v.label,
            onSelect: (v) => p.craftClassification = v,
            color: kAccent,
          ),
          SizedBox(height: 16.h),
          _chipPicker<FiberType>(
            label: 'Fiber Specification',
            values: FiberType.values,
            selected: p.fiberType,
            labelOf: (v) => v.label,
            onSelect: (v) {
              p.fiberType = v;
              if (!widget.isEdit) {
                p.spindleRegistryScroll = generateRegistryScroll(v);
                _scrollCtrl.text = p.spindleRegistryScroll;
              }
            },
            color: kHerbGreen,
            mono: true,
          ),
        ]),
      ],
    );
  }

  Widget _buildStep2(InputNotifier p) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
      children: [
        _sectionHeader('MECHANICAL SPECIFICATION'),
        _buildModule([
          _field(
            label: 'Orifice & Whorl Geometry',
            ctrl: _orificeCtrl,
            hint: '3:1 pulley ratio, weighted soapstone whorl',
            isMono: true,
            maxLines: 2,
            onChanged: (v) => p.orificeWhorlGeometry = v,
          ),
          _field(
            label: 'Timber & Joinery Composition',
            ctrl: _timberCtrl,
            hint: 'Mortise-and-tenon seasoned white oak',
            maxLines: 2,
            onChanged: (v) => p.timberJoineryComposition = v,
          ),
          _field(
            label: 'Teeth Count & Density',
            ctrl: _teethCtrl,
            hint: '72 teeth-per-square-inch, fine flax wire array',
            isMono: true,
            onChanged: (v) => p.teethCountDensity = v,
          ),
          _field(
            label: 'Physical Proportions',
            ctrl: _proportionsCtrl,
            hint: 'Drive wheel 86 cm dia., 2,400 g total',
            isMono: true,
            onChanged: (v) => p.physicalProportions = v,
          ),
          _field(
            label: 'Period / Era',
            ctrl: _eraCtrl,
            hint: '1780s',
            isMono: true,
            inputFormatters: const [_EraInputFormatter()],
            onChanged: (v) => p.era = v,
          ),
        ]),
      ],
    );
  }

  Widget _buildStep3(InputNotifier p) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
      children: [
        _sectionHeader('HOMESTEAD & CONDITION'),
        _buildModule([
          _chipPicker<HomesteadRegion>(
            label: 'Craft Tradition Region',
            values: HomesteadRegion.values,
            selected: p.homesteadRegion,
            labelOf: (v) => v.label,
            onSelect: (v) => p.homesteadRegion = v,
            color: kAccent,
          ),
          SizedBox(height: 16.h),
          _field(
            label: 'Homestead Ground Zero',
            ctrl: _homesteadCtrl,
            hint: 'Shenandoah Valley settlement farm',
            maxLines: 2,
            onChanged: (v) => p.homesteadGroundZero = v,
          ),
          _field(
            label: 'Calibration Facility',
            ctrl: _facilityCtrl,
            hint: 'Colonial iron foundry, ceramic kiln',
            onChanged: (v) => p.calibrationFacility = v,
          ),
          _field(
            label: 'Temperature Range',
            ctrl: _tempCtrl,
            hint: '15–28 °C operating range',
            isMono: true,
            onChanged: (v) => p.temperatureRange = v,
          ),
          _chipPicker<MechanicalSoundness>(
            label: 'Mechanical Soundness',
            values: MechanicalSoundness.values,
            selected: p.mechanicalSoundness,
            labelOf: (v) => v.label,
            onSelect: (v) => p.mechanicalSoundness = v,
            color: kHerbGreen,
          ),
          SizedBox(height: 16.h),
          _field(
            label: 'Archival Notes',
            ctrl: _notesCtrl,
            hint: 'Condition observations, restoration history...',
            maxLines: 3,
            onChanged: (v) => p.notes = v,
          ),
          _field(
            label: 'Subject Keywords',
            ctrl: _tagsCtrl,
            hint: 'pioneer, flax, Appalachian',
            isMono: true,
            onChanged: (v) => p.tags = v
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList(),
          ),
        ]),
      ],
    );
  }

  Widget _buildPhotoModule() {
    final imageProv = ref.watch(imageProvider);
    final displayPath = imageProv.getImagePath(imageProv.resultImage);
    return GestureDetector(
      onTap: () => photoBottomSheet(context, ref.read(imageProvider), 0, ref),
      child: Container(
        height: 180.h,
        decoration: BoxDecoration(
          color: kCardSurface,
          borderRadius: BorderRadius.circular(kRadiusStandard),
          border: Border.all(color: kOutline),
        ),
        clipBehavior: Clip.antiAlias,
        child: displayPath != null && File(displayPath).existsSync()
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(File(displayPath), fit: BoxFit.cover),
                  Positioned(
                    right: 8.w,
                    top: 8.w,
                    child: Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: kCardSurface.withAlpha(200),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.edit_rounded, color: kPrimaryText, size: 16.sp),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_outlined, color: kSecondaryText, size: 32.sp),
                  SizedBox(height: 8.h),
                  Text('Document Tool',
                      style: GoogleFonts.inter(color: kPrimaryText, fontSize: 15.sp)),
                  Text('Whorl face or drive wheel forward',
                      style: GoogleFonts.inter(
                          color: kSecondaryText,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w300)),
                ],
              ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h, left: 2.w),
      child: Text(
        title,
        style: GoogleFonts.ibmPlexMono(
          color: kSecondaryText,
          fontSize: 9.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildModule(List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: kCardSurface,
        borderRadius: BorderRadius.circular(kRadiusStandard),
        border: Border.all(color: kOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController ctrl,
    required Function(String) onChanged,
    String? hint,
    int maxLines = 1,
    bool isMono = false,
    bool readOnly = false,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  color: kSecondaryText,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600)),
          SizedBox(height: 4.h),
          TextField(
            controller: ctrl,
            onChanged: onChanged,
            maxLines: maxLines,
            readOnly: readOnly,
            inputFormatters: inputFormatters,
            keyboardType:
                maxLines > 1 ? TextInputType.multiline : TextInputType.text,
            style: isMono
                ? GoogleFonts.ibmPlexMono(color: kPrimaryText, fontSize: 13.sp)
                : GoogleFonts.inter(color: kPrimaryText, fontSize: 14.sp),
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder:
                  const UnderlineInputBorder(borderSide: BorderSide(color: kAccent)),
              contentPadding: EdgeInsets.symmetric(vertical: 6.h),
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chipPicker<T>({
    required String label,
    required List<T> values,
    required T selected,
    required String Function(T) labelOf,
    required void Function(T) onSelect,
    required Color color,
    bool mono = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                color: kSecondaryText,
                fontSize: 11.sp,
                fontWeight: FontWeight.w600)),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 6.w,
          runSpacing: 6.h,
          children: values.map((v) {
            final isSel = v == selected;
            return GestureDetector(
              onTap: () => onSelect(v),
              child: AnimatedContainer(
                duration: kTransitionDuration,
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: isSel ? color.withAlpha(31) : kBackground,
                  borderRadius: BorderRadius.circular(kRadiusPill),
                  border: Border.all(color: isSel ? color : kOutline),
                ),
                child: Text(
                  labelOf(v),
                  style: mono
                      ? GoogleFonts.ibmPlexMono(
                          color: isSel ? color : kSecondaryText,
                          fontSize: 10.sp,
                        )
                      : GoogleFonts.inter(
                          color: isSel ? color : kSecondaryText,
                          fontSize: 11.sp,
                        ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _EraInputFormatter extends TextInputFormatter {
  const _EraInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;
    if (!RegExp(r'^[\ds]*$').hasMatch(text)) return oldValue;

    final digits = text.replaceAll('s', '');
    if (digits.length > 4) return oldValue;
    if (text.contains('s') && !text.endsWith('s')) return oldValue;
    if ('s'.allMatches(text).length > 1) return oldValue;

    return newValue;
  }
}

class _SavingDialog extends StatelessWidget {
  const _SavingDialog();
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: kCardSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kRadiusStandard),
        side: const BorderSide(color: kOutline),
      ),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 24,
              height: 24,
              child: LinearProgressIndicator(color: kAccent, minHeight: 2),
            ),
            SizedBox(height: 16.h),
            Text(
              'RECORDING TOOL...',
              style: GoogleFonts.ibmPlexMono(
                color: kPrimaryText,
                fontSize: 10.sp,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
