import 'package:fingerprint_frontend/core/localization/l10n/app_localizations.dart';
import 'package:fingerprint_frontend/core/widgets/icon_button_widget.dart';
import 'package:fingerprint_frontend/core/widgets/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fingerprint_frontend/core/shared/shared_core.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../bloc/users_bloc.dart';
import '../bloc/users_event.dart';
import '../bloc/users_state.dart';
import '../widgets/user_form_dialog.dart';
import '../widgets/change_password_dialog.dart';
import '../../../../core/widgets/table_widget.dart';
import 'package:fingerprint_frontend/core/theme/app_color_scheme.dart';

class UsersListPage extends StatefulWidget {
  const UsersListPage({super.key});

  @override
  State<UsersListPage> createState() => _UsersListPageState();
}

class _UsersListPageState extends State<UsersListPage> {
  int? get _currentUserId {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      return authState.user.id;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    context.read<UsersBloc>().add(const LoadUsersEvent());
  }

  void _onAddNewUser() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const UserFormDialog(),
    );
    if (result != null && mounted) {
      context.read<UsersBloc>().add(
        CreateUserEvent(
          user: UserEntity(
            id: 0,
            username: result['username'] as String,
            passwordHash: result['password'] as String,
            role: UserRole.of(result['role'] as String? ?? 'viewer'),
            employeeId: result['employee_id'] as int?,
            isActive: result['is_active'] as bool? ?? true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ),
      );
    }
  }

  void _showEditUserDialog(UserModel user) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => UserFormDialog(user: user),
    );
    if (result != null && mounted) {
      context.read<UsersBloc>().add(
        UpdateUserEvent(
          id: user.id,
          username: result['username'] as String,
          role: result['role'] as String?,
          isActive: result['is_active'] as bool? ?? user.isActive,
        ),
      );
    }
  }

  void _showChangePasswordDialog(UserModel user) async {
    final newPassword = await showDialog<String>(
      context: context,
      builder: (_) => ChangePasswordDialog(username: user.username),
    );
    if (newPassword != null && mounted) {
      context.read<UsersBloc>().add(
        ChangePasswordEvent(userId: user.id, newPassword: newPassword),
      );
    }
  }

  void _confirmDeleteUser(UserModel user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.confirmDelete),
        content: Text(AppLocalizations.of(context)!.confirmDeleteUser(user.username)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<UsersBloc>().add(DeleteUserEvent(userId: user.id));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text(AppLocalizations.of(context)!.deleteUser),
          ),
        ],
      ),
    );
  }
 
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UsersBloc, UsersState>(
      listener: (context, state) {
        if (state is UsersOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: SelectableText(state.message),
              backgroundColor: Theme.of(context).colorScheme.success,
            ),
          );
        }
        if (state is UsersError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: SelectableText(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: 10,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.usersManagement,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButtonWidget(
                      icon: (Icons.refresh_rounded),
                      iconSize: 20,
                      tooltip: AppLocalizations.of(context)!.reload,
                      onPressed: () =>
                          context.read<UsersBloc>().add(const LoadUsersEvent()),
                    ),
                    ElevatedButton.icon(
                      onPressed: _onAddNewUser,
                      icon: Icon(Icons.add),
                      label: Text(AppLocalizations.of(context)!.addUser),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Expanded(child: _buildUsersTable(state)),
              ],
            ),
          ),
        );
      },
    );
  }

  final _columns = const {
    0: FlexTableWidgetColumnWidth(
      1,
      alignment: AlignmentDirectional.centerStart,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    ),
    1: FlexTableWidgetColumnWidth(
      3,
      alignment: AlignmentDirectional.centerStart,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    ),
    2: FlexTableWidgetColumnWidth(
      2,
      alignment: AlignmentDirectional.centerStart,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    ),
    3: FlexTableWidgetColumnWidth(
      2,
      alignment: AlignmentDirectional.centerStart,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    ),
    4: FlexTableWidgetColumnWidth(
      3,
      alignment: AlignmentDirectional.center,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    ),
  };

  List<String> get _headers => [AppLocalizations.of(context)!.tableNo, AppLocalizations.of(context)!.username, AppLocalizations.of(context)!.role, AppLocalizations.of(context)!.status, AppLocalizations.of(context)!.actions];

  Widget _buildUsersTable(UsersState state) {
    if (state is UsersLoading && state is! UsersLoaded) {
      return ShimmerLoading.table(rows: 20, columns: 5);
    }

    if (state is UsersLoaded && state.users.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context)!.noUsers));
    }

    final users = state is UsersLoaded ? state.users : <UserModel>[];
    final currentUserId = _currentUserId;
    final style = TextTheme.of(context).bodySmall!.copyWith(fontWeight: .bold);
    final colors = ColorScheme.of(context);

    return TableWidget<UserModel>(
      columns: _columns,
      header: _headers,
      items: users,
      minWidth: 700,
      paintRowColorWhen: (user, _) => user.id == currentUserId,
      rowColor: colors.primaryContainer.withAlpha(25),
      builder: (context, user, index) {
        final isSelf = user.id == currentUserId;
        return [
          Text(user.id.toString(), style: style),
          Text(user.username, style: style),
          _buildRoleChip(user.role),
          Text(user.isActive ? AppLocalizations.of(context)!.active : AppLocalizations.of(context)!.inactive),
          _buildActionButtons(user, isSelf),
        ];
      },
    );
  }

  Widget _buildRoleChip(UserRole role) {
    final color = switch (role.name) {
      'admin' => Theme.of(context).colorScheme.error,
      'hr' => Theme.of(context).colorScheme.success,
      _ => Theme.of(context).colorScheme.secondary,
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        role.displayName(null),
        style: TextStyle(color: color, fontSize: 12),
      ),
    );
  }

  Widget _buildStatusToggle(UserModel user, bool isSelf) {
    return Tooltip(
      message: isSelf ? AppLocalizations.of(context)!.cannotDisableCurrentUser : '',
      child: Switch(
        value: user.isActive,
        activeTrackColor: Theme.of(context).colorScheme.success,
        onChanged: isSelf
            ? null
            : (value) {
                context.read<UsersBloc>().add(
                  ToggleUserStatusEvent(userId: user.id, isActive: value),
                );
              },
      ),
    );
  }

  Widget _buildActionButtons(UserModel user, bool isSelf) {
    return Row(
      mainAxisAlignment: .center,
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButtonWidget(
          icon: (Icons.edit_outlined),
          iconColor: isSelf ? Theme.of(context).colorScheme.outline : null,
          tooltip: isSelf ? AppLocalizations.of(context)!.cannotEditCurrentUser : 'تعديل',
          onPressed: isSelf ? null : () => _showEditUserDialog(user),
        ),
        IconButtonWidget(
          icon: (Icons.lock_outline),
          iconColor: isSelf ? Theme.of(context).colorScheme.outline : null,
          tooltip: isSelf
              ? AppLocalizations.of(context)!.cannotEditCurrentUser
              : AppLocalizations.of(context)!.changePassword,
          onPressed: isSelf ? null : () => _showChangePasswordDialog(user),
        ),
        IconButtonWidget(
          icon: Icons.delete_outline,
          iconColor: isSelf
              ? Theme.of(context).colorScheme.outline
              : Theme.of(context).colorScheme.error,
          tooltip: isSelf ? AppLocalizations.of(context)!.cannotDeleteCurrentUser : AppLocalizations.of(context)!.deleteUser,
          onPressed: isSelf ? null : () => _confirmDeleteUser(user),
        ),
      ],
    );
  }
}
