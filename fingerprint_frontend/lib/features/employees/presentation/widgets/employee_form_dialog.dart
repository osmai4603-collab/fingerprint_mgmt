import 'dart:math';

import 'package:fingerprint_frontend/core/services/date_time_format.dart';
import 'package:fingerprint_frontend/core/widgets/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:fingerprint_frontend/core/shared/shared_core.dart';
import 'package:fingerprint_frontend/core/repositories/interfaces/employee_repository.dart';
import 'package:fingerprint_frontend/core/repositories/interfaces/shifts_repository.dart';
import 'package:fingerprint_frontend/core/localization/l10n/app_localizations.dart';

class EmployeeFormDialog extends StatefulWidget {
  final EmployeeEntity? employee;
  const EmployeeFormDialog({super.key, this.employee});

  static Future<EmployeeModel?> show(BuildContext context) {
    return showDialog<EmployeeModel>(
      context: context,
      builder: (_) => const EmployeeFormDialog(),
    );
  }

  @override
  State<EmployeeFormDialog> createState() => _EmployeeFormDialogState();
}

class _EmployeeFormDialogState extends State<EmployeeFormDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _userIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cardNoController = TextEditingController();

  EmployeeRole _selectedRole = EmployeeRole.user;
  int? _selectedShiftId;
  List<ShiftModel> _shifts = [];
  bool _isLoadingShifts = true;
  bool _isSaving = false;

  bool get _isEditing => widget.employee != null;

  late final AnimationController _animController;
  late final Animation<double> _fadeIn;
  late final List<Animation<Offset>> _slideUps;

  @override
  void initState() {
    super.initState();
    _prefillFields();
    _fetchShifts();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);

    _slideUps = List.generate(7, (i) {
      final start = (i * 0.08).clamp(0.0, 1.0);
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
    _userIdController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _cardNoController.dispose();
    super.dispose();
  }

  Future<void> _fetchShifts() async {
    final repo = GetIt.instance<ShiftsRepository>();
    final result = await repo.get();
    result.fold((_) {}, (shifts) {
      if (mounted) setState(() => _shifts = shifts.cast());
    });
    if (mounted) setState(() => _isLoadingShifts = false);
  }

  void _prefillFields() {
    final e = widget.employee;
    if (e == null) return;
    _userIdController.text = e.employeeID;
    _nameController.text = e.name;
    _passwordController.text = e.password ?? '';
    _cardNoController.text = e.cardNo?.toString() ?? '';
    _selectedRole = e.role;
    _selectedShiftId = e.defaultShiftId;
  }

  void _generateUserId() {
    final random = Random.secure();
    final code = (random.nextInt(900000) + 100000).toString();
    setState(() => _userIdController.text = code);
  }

  Future<void> _onConfirm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final repo = GetIt.instance<EmployeeRepository>();
    final entity = EmployeeEntity(
      uid: widget.employee?.uid ?? 0,
      employeeID: _userIdController.text.trim(),
      name: _nameController.text.trim(),
      role: _selectedRole,
      cardNo: int.tryParse(_cardNoController.text) ?? 0,
      defaultShiftId: _selectedShiftId,
      isActive: widget.employee?.isActive ?? true,
      createdAt: widget.employee?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final result = _isEditing
        ? await repo.update(entity)
        : await repo.create(entity);

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      },
      (_) {
        Navigator.of(context).pop(entity);
      },
    );
  }

  Widget _buildAnimatedField(int index, Widget child) {
    return SlideTransition(
      position: _slideUps[index],
      child: FadeTransition(opacity: _fadeIn, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        width: 460,
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
                            ? Icons.edit_rounded
                            : Icons.person_add_rounded,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      _isEditing ? 'تعديل بيانات الموظف' : 'إضافة موظف جديد',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _isEditing
                          ? 'تعديل بيانات ${widget.employee!.name}'
                          : 'أدخل بيانات الموظف لإضافته للنظام',
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
                    children: [
                      _buildAnimatedField(
                        0,
                        TextFormField(
                          controller: _userIdController,
                          textDirection: TextDirection.ltr,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(
                              context,
                            )!.employeeUserId,
                            hintText: AppLocalizations.of(
                              context,
                            )!.employeeUserIdHint,
                            prefixIcon: const Align(
                              child: Icon(Icons.perm_identity_rounded),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.autorenew),
                              tooltip: AppLocalizations.of(
                                context,
                              )!.generateUniqueId,
                              onPressed: _isSaving ? null : _generateUserId,
                            ),
                          ),
                          enabled: !_isSaving,
                        ),
                      ),
                      SizedBox(height: 12),
                      _buildAnimatedField(
                        1,
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.name,
                            prefixIcon: Align(
                              child: Icon(Icons.person_2_rounded),
                            ),
                          ),
                          enabled: !_isSaving,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? AppLocalizations.of(context)!.nameRequired
                              : null,
                        ),
                      ),
                      SizedBox(height: 12),
                      _buildAnimatedField(
                        2,
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.password,
                            prefixIcon: Align(
                              child: Icon(Icons.password_rounded),
                            ),
                          ),
                          obscureText: true,
                          enabled: !_isSaving,
                        ),
                      ),
                      SizedBox(height: 12),
                      _buildAnimatedField(
                        3,
                        TextFormField(
                          controller: _cardNoController,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.cardNo,
                            prefixIcon: Align(
                              child: Icon(Icons.card_membership_rounded),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          enabled: !_isSaving,
                        ),
                      ),
                      SizedBox(height: 12),
                      _buildAnimatedField(
                        4,
                        DropdownButtonFormField<EmployeeRole>(
                          initialValue: _selectedRole,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.role,
                            prefixIcon: Align(
                              child: Icon(Icons.admin_panel_settings_rounded),
                            ),
                          ),
                          items: EmployeeRole.values
                              .map(
                                (r) => DropdownMenuItem(
                                  value: r,
                                  child: Text(
                                    r.displayName(null),
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(fontWeight: .bold),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: _isSaving
                              ? null
                              : (v) {
                                  if (v != null) {
                                    setState(() => _selectedRole = v);
                                  }
                                },
                        ),
                      ),
                      SizedBox(height: 12),
                      _buildAnimatedField(
                        5,
                        _isLoadingShifts
                            ? ShimmerLoading.box(height: 56)
                            : DropdownButtonFormField<int>(
                                initialValue: _selectedShiftId,
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(
                                    context,
                                  )!.shifts,
                                  prefixIcon: Align(
                                    child: Icon(
                                      Icons.filter_tilt_shift_rounded,
                                    ),
                                  ),
                                ),
                                items: [
                                  DropdownMenuItem(
                                    value: null,
                                    child: Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.withoutShift,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(fontWeight: .bold),
                                    ),
                                  ),
                                  ..._shifts.map(
                                    (s) => DropdownMenuItem(
                                      value: s.id,
                                      alignment: .centerStart,
                                      child: Text(
                                        '${s.name} من ${formatTime(s.startTime)} إالى ${formatTime(s.endTime)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(fontWeight: .bold),
                                      ),
                                    ),
                                  ),
                                ],
                                onChanged: _isSaving
                                    ? null
                                    : (v) {
                                        setState(() => _selectedShiftId = v);
                                      },
                              ),
                      ),
                    ],
                  ),
                ),
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
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                ),
                              )
                            : Icon(Icons.save_rounded, size: 20),
                        label: Text(
                          _isEditing
                              ? AppLocalizations.of(context)!.update
                              : AppLocalizations.of(context)!.addNew,
                        ),
                        onPressed: _isSaving ? null : _onConfirm,
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
    );
  }
}
