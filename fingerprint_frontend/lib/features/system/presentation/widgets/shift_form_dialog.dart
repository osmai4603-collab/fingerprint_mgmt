import 'package:fingerprint_frontend/core/localization/l10n/app_localizations.dart';
import 'package:fingerprint_frontend/core/services/date_time_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fingerprint_frontend/core/shared/shared_core.dart';
import '../bloc/shifts_bloc.dart';
import '../bloc/shifts_event.dart';
import '../bloc/shifts_state.dart';
import 'package:fingerprint_frontend/core/theme/app_color_scheme.dart';

class ShiftFormDialog extends StatefulWidget {
  final ShiftEntity? shift;

  const ShiftFormDialog({super.key, this.shift});

  @override
  State<ShiftFormDialog> createState() => _ShiftFormDialogState();
}

class _ShiftFormDialogState extends State<ShiftFormDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  final Set<int> _selectedWeekendDays = {};

  TimeOfDay? startTime,
      endTime,
      beforeStartTime,
      afterStartTime,
      maxAttendanceTime,
      beforeEndTime,
      afterEndTime;

  bool _isNightShift = false;
  bool _acceptOvertime = true;

  bool get _isEditing => widget.shift != null;
  bool _isSaving = false;
  String? _errorMessage;

  late final AnimationController _animController;
  late final Animation<double> _fadeIn;
  late final List<Animation<Offset>> _slideUps;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.shift?.name ?? '');
    if (widget.shift?.startTime != null) {
      startTime = TimeOfDay.fromDateTime(widget.shift!.startTime);
    }
    if (widget.shift?.endTime != null) {
      endTime = TimeOfDay.fromDateTime(widget.shift!.endTime);
    }
    if (widget.shift?.beforeStartTime != null) {
      beforeStartTime = TimeOfDay.fromDateTime(widget.shift!.beforeStartTime);
    }
    if (widget.shift?.afterStartTime != null) {
      afterStartTime = TimeOfDay.fromDateTime(widget.shift!.afterStartTime);
    }
    if (widget.shift?.beforeEndTime != null) {
      beforeEndTime = TimeOfDay.fromDateTime(widget.shift!.beforeEndTime);
    }
    if (widget.shift?.afterEndTime != null) {
      afterEndTime = TimeOfDay.fromDateTime(widget.shift!.afterEndTime);
    }
    if (widget.shift?.maxAttendanceTime != null) {
      maxAttendanceTime = TimeOfDay.fromDateTime(
        widget.shift!.maxAttendanceTime,
      );
    }
    if (widget.shift?.weekendDays != null) {
      _selectedWeekendDays.addAll(
        widget.shift!.weekendDays!.map((d) => d.value),
      );
    }

    if (widget.shift != null) {
      _isNightShift = widget.shift!.isNightShift;
      _acceptOvertime = widget.shift!.acceptOvertime;
    }

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);

    _slideUps = List.generate(9, (i) {
      final start = (i * 0.07).clamp(0.0, 1.0);
      final end = (start + 0.4).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, 0.15),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animController,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<TimeOfDay?> _pickTime(TimeOfDay initalTime) async {
    return await showTimePicker(context: context, initialTime: initalTime);
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;
    if (_isSaving) return;

    final weekendDays = _selectedWeekendDays.isEmpty
        ? null
        : WeekDays.fromValues(_selectedWeekendDays.toList());

    setState(() {
      _errorMessage = null;
      _isSaving = true;
    });

    final shift = ShiftEntity(
      id: widget.shift?.id ?? 0,
      name: _nameController.text.trim(),
      startTime: toDateTimeFromTimeOfDay(startTime ?? TimeOfDay.now()),
      endTime: toDateTimeFromTimeOfDay(endTime ?? TimeOfDay.now()),
      beforeStartTime: toDateTimeFromTimeOfDay(
        beforeStartTime ?? TimeOfDay.now(),
      ),
      afterStartTime: toDateTimeFromTimeOfDay(
        afterStartTime ?? TimeOfDay.now(),
      ),
      beforeEndTime: toDateTimeFromTimeOfDay(beforeEndTime ?? TimeOfDay.now()),
      afterEndTime: toDateTimeFromTimeOfDay(afterEndTime ?? TimeOfDay.now()),
      maxAttendanceTime: toDateTimeFromTimeOfDay(
        maxAttendanceTime ?? TimeOfDay.now(),
      ),
      weekendDays: weekendDays,
      isNightShift: _isNightShift,
      acceptOvertime: _acceptOvertime,
    );

    if (_isEditing) {
      context.read<ShiftsBloc>().add(UpdateShiftEvent(shift: shift));
    } else {
      context.read<ShiftsBloc>().add(CreateShiftEvent(shift: shift));
    }
  }

  Widget _buildAnimatedField(int index, Widget child) {
    return SlideTransition(
      position: _slideUps[index],
      child: FadeTransition(opacity: _fadeIn, child: child),
    );
  }

  Widget _buildTimeCard({
    required TimeOfDay? time,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4, right: 4),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Card(
          color: ColorScheme.of(context).surfaceContainerLowest,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(icon, color: Theme.of(context).colorScheme.primary),
                  SizedBox(width: 16),
                  Text(
                    time != null ? formatTimeOfDay(time) : '--:--',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (time == null)
          Padding(
            padding: const EdgeInsets.only(top: 4, right: 16),
            child: Text(
              'مطلوب',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return BlocListener<ShiftsBloc, ShiftsState>(
      listener: (context, state) {
        if (state is ShiftsOperationSuccess) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: SelectableText(state.message),
              backgroundColor: Theme.of(context).colorScheme.success,
            ),
          );
        }
        if (state is ShiftsError) {
          setState(() {
            _isSaving = false;
            _errorMessage = state.message;
          });
        }
      },
      child: Dialog(
        insetPadding: EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SizedBox(
          width: 450,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 28, horizontal: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withAlpha(180),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: FadeTransition(
                  opacity: _fadeIn,
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.white24,
                        child: Icon(
                          _isEditing
                              ? Icons.edit_calendar_rounded
                              : Icons.add_task_rounded,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        _isEditing
                            ? AppLocalizations.of(context)!.editShift
                            : AppLocalizations.of(context)!.addNewShift,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        _isEditing
                            ? AppLocalizations.of(context)!.editShiftData
                            : AppLocalizations.of(context)!.addShiftData,
                        style: TextStyle(fontSize: 13, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(24, 20, 24, 8),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      spacing: 16,
                      children: [
                        _buildAnimatedField(
                          0,
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: localization.shiftName,
                              prefixIcon: Align(
                                widthFactor: 1,
                                child: Icon(Icons.filter_tilt_shift_rounded),
                              ),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? localization.shiftNameRequired
                                : null,
                          ),
                        ),
                        _buildAnimatedField(
                          1,
                          Row(
                            children: [
                              Expanded(
                                child: _buildTimeCard(
                                  time: startTime,
                                  label: localization.startTime,
                                  icon: Icons.access_time,
                                  onTap: onTapStartTime,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: _buildTimeCard(
                                  time: endTime,
                                  label: localization.endTime,
                                  icon: Icons.access_time,
                                  onTap: onTapEndTime,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildAnimatedField(
                          2,
                          Row(
                            children: [
                              Expanded(
                                child: _buildTimeCard(
                                  time: beforeStartTime,
                                  label: localization.earlyEntryBefore,
                                  icon: Icons.timelapse,
                                  onTap: onTapBeforeStartTime,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: _buildTimeCard(
                                  time: afterStartTime,
                                  label: localization.lateEntryAfter,
                                  icon: Icons.timelapse,
                                  onTap: onTapAfterStartTime,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildAnimatedField(
                          3,
                          Row(
                            children: [
                              Expanded(
                                child: _buildTimeCard(
                                  time: beforeEndTime,
                                  label: localization.earlyExitBefore,
                                  icon: Icons.timelapse,
                                  onTap: onTapBeforeEndTime,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: _buildTimeCard(
                                  time: afterEndTime,
                                  label: localization.lateExitAfter,
                                  icon: Icons.timelapse,
                                  onTap: onTapAfterEndTime,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildAnimatedField(
                          4,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTimeCard(
                                time: maxAttendanceTime,
                                label: localization.maxAttendanceTime,
                                icon: Icons.access_time_filled,
                                onTap: onTapMaxAttendanceTime,
                              ),
                              SizedBox(height: 16),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  'أيام العطلة',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                alignment: WrapAlignment.start,
                                runAlignment: WrapAlignment.start,
                                children: List.generate(7, (i) {
                                  final dayValue = i + 1;
                                  final isSelected = _selectedWeekendDays
                                      .contains(dayValue);
                                  return FilterChip(
                                    label: Text(
                                      getDayNameByNumber(
                                        dayValue == 0 ? 7 : dayValue,
                                      ),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: isSelected
                                                ? Theme.of(context)
                                                      .colorScheme
                                                      .onPrimaryContainer
                                                : null,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : null,
                                          ),
                                    ),
                                    selected: isSelected,
                                    selectedColor: Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer,
                                    checkmarkColor: Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                                    onSelected: (selected) {
                                      setState(() {
                                        if (selected) {
                                          _selectedWeekendDays.add(dayValue);
                                        } else {
                                          _selectedWeekendDays.remove(dayValue);
                                        }
                                      });
                                    },
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12),
                        _buildAnimatedField(
                          5,
                          Row(
                            children: [
                              Expanded(
                                child: SwitchListTile(
                                  title: Text(
                                    'وردية ليلية',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  value: _isNightShift,
                                  onChanged: (val) {
                                    setState(() {
                                      _isNightShift = val;
                                    });
                                  },
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: SwitchListTile(
                                  title: Text(
                                    'احتساب الإضافي',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  value: _acceptOvertime,
                                  onChanged: (val) {
                                    setState(() {
                                      _acceptOvertime = val;
                                    });
                                  },
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.fromLTRB(24, 0, 24, 8),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.error.withAlpha(80),
                    ),
                  ),
                  child: SelectableText(
                    _errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 13,
                    ),
                    textDirection: TextDirection.ltr,
                  ),
                ),
              FadeTransition(
                opacity: _fadeIn,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24, 0, 24, 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isSaving
                              ? null
                              : () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(AppLocalizations.of(context)!.cancel),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          icon: _isSaving
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(
                                  _isEditing
                                      ? Icons.save_rounded
                                      : Icons.add_task_rounded,
                                  size: 20,
                                ),
                          label: Text(
                            _isSaving
                                ? AppLocalizations.of(context)!.saving
                                : (_isEditing
                                      ? AppLocalizations.of(context)!.save
                                      : AppLocalizations.of(context)!.addNew),
                          ),
                          onPressed: _isSaving ? null : _onSubmit,
                          style: FilledButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onPrimary,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
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
      ),
    );
  }

  void onTapMaxAttendanceTime() async {
    final result = await pickTimeOfDay(maxAttendanceTime);
    setState(() => maxAttendanceTime = result);
  }

  void onTapAfterEndTime() async {
    final result = await pickTimeOfDay(afterEndTime);
    setState(() => afterEndTime = result);
  }

  void onTapBeforeEndTime() async {
    final result = await pickTimeOfDay(beforeEndTime);
    setState(() => beforeEndTime = result);
  }

  void onTapAfterStartTime() async {
    final result = await pickTimeOfDay(afterStartTime);
    setState(() => afterStartTime = result);
  }

  void onTapBeforeStartTime() async {
    final result = await pickTimeOfDay(beforeStartTime);
    setState(() => beforeStartTime = result);
  }

  void onTapEndTime() async {
    final result = await pickTimeOfDay(endTime);
    setState(() => endTime = result);
  }

  void onTapStartTime() async {
    final result = await pickTimeOfDay(startTime);
    setState(() => startTime = result);
  }

  Future<TimeOfDay?> pickTimeOfDay(TimeOfDay? time) async {
    final result = await _pickTime(time ?? TimeOfDay.now());
    return result ?? time;
  }
}
