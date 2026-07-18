import 'package:fingerprint_frontend/core/localization/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:fingerprint_frontend/core/shared/shared_core.dart';

class UserFormDialog extends StatefulWidget {
  final UserModel? user;

  const UserFormDialog({super.key, this.user});

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  UserRole _selectedRole = UserRole.viewer;
  bool _isActive = true;

  bool get _isEditing => widget.user != null;

  late final AnimationController _animController;
  late final Animation<double> _fadeIn;
  late final List<Animation<Offset>> _slideUps;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(
      text: widget.user?.username ?? '',
    );
    _passwordController = TextEditingController();
    if (widget.user != null) {
      _selectedRole = widget.user!.role;
      _isActive = widget.user!.isActive;
    }

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);

    _slideUps = List.generate(4, (i) {
      final start = (i * 0.1).clamp(0.0, 1.0);
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
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop({
        'username': _usernameController.text.trim(),
        'password': _isEditing ? null : _passwordController.text,
        'role': _selectedRole,
        'is_active': _isActive,
      });
    }
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
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 28, horizontal: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withAlpha(180)],
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
                            ? Icons.manage_accounts_rounded
                            : Icons.person_add_rounded,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      _isEditing ? AppLocalizations.of(context)!.editUser : AppLocalizations.of(context)!.addUser,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _isEditing
                          ? AppLocalizations.of(context)!.editUserDataPermissions
                          : AppLocalizations.of(context)!.addUserDataPrompt,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      spacing: 16,
                      children: [
                        _buildAnimatedField(
                          0,
                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.username,
                              prefixIcon: Align(
                                child: Icon(Icons.person_outline_rounded),
                              ),
                            ),

                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return AppLocalizations.of(context)!.usernameRequired;
                              }
                              return null;
                            },
                          ),
                        ),
                        if (!_isEditing) ...[
                          _buildAnimatedField(
                            1,
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!.password,
                                prefixIcon: Align(
                                  child: Icon(Icons.password_rounded),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppLocalizations.of(context)!.passwordRequired;
                                }
                                if (value.length < 6) {
                                  return AppLocalizations.of(context)!.passwordMinLength;
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                        _buildAnimatedField(
                          _isEditing ? 1 : 2,
                          DropdownButtonFormField<UserRole>(
                            initialValue: _selectedRole,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(fontWeight: .bold),
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.role,
                              prefixIcon: Align(
                                child: Icon(
                                  Icons.admin_panel_settings_outlined,
                                ),
                              ),
                            ),
                            items: UserRole.values.map((role) {
                              return DropdownMenuItem(
                                value: role,
                                child: Text(role.displayName(null)),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _selectedRole = value);
                              }
                            },
                          ),
                        ),
                        if (_isEditing) ...[
                          _buildAnimatedField(
                            2,
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceContainer,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Theme.of(context).colorScheme.outline),
                              ),
                              child: SwitchListTile(
                                title: Text(AppLocalizations.of(context)!.status),
                                subtitle: Text(_isActive ? AppLocalizations.of(context)!.enabled : AppLocalizations.of(context)!.disabled),
                                value: _isActive,
                                onChanged: (value) {
                                  setState(() => _isActive = value);
                                },
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
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
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Theme.of(context).colorScheme.outline),
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
                        icon: Icon(
                          _isEditing
                              ? Icons.save_rounded
                              : Icons.person_add_rounded,
                          size: 20,
                        ),
                        label: Text(_isEditing ? AppLocalizations.of(context)!.save : AppLocalizations.of(context)!.addNew),
                        onPressed: _onSubmit,
                        style: FilledButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
