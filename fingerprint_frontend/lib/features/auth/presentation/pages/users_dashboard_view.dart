import 'package:fingerprint_frontend/core/localization/l10n/app_localizations.dart';
import 'package:fingerprint_frontend/features/auth/presentation/pages/users_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/users_bloc.dart';
import '../bloc/users_event.dart';

class UsersDashboardView extends StatefulWidget {
  const UsersDashboardView({super.key});

  @override
  State<UsersDashboardView> createState() => _UsersDashboardViewState();
}

class _UsersDashboardViewState extends State<UsersDashboardView> {
  @override
  void initState() {
    super.initState();
    context.read<UsersBloc>().add(const LoadUsersEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.usersManagement)),
      body: UsersListPage(),
    );
  }
}
