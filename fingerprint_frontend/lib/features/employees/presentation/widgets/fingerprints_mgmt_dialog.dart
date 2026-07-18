import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fingerprint_frontend/core/shared/shared_core.dart';
import 'package:fingerprint_frontend/core/widgets/shimmer_loading.dart';
import '../bloc/employees_bloc.dart';
import 'package:fingerprint_frontend/core/theme/app_color_scheme.dart';
import 'package:fingerprint_frontend/core/localization/l10n/app_localizations.dart';

class FingerprintsMgmtDialog extends StatefulWidget {
  final EmployeeModel employee;

  const FingerprintsMgmtDialog({super.key, required this.employee});

  @override
  State<FingerprintsMgmtDialog> createState() => _FingerprintsMgmtDialogState();
}

class _FingerprintsMgmtDialogState extends State<FingerprintsMgmtDialog> {
  final _biometricController = TextEditingController();
  final _searchController = TextEditingController();
  final _fingerIndexController = TextEditingController(text: '0');

  @override
  void initState() {
    super.initState();
    context.read<EmployeesBloc>().add(
      LoadFingerprintsEvent(employeeUid: widget.employee.uid),
    );
  }

  @override
  void dispose() {
    _biometricController.dispose();
    _searchController.dispose();
    _fingerIndexController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 560,
        constraints: const BoxConstraints(maxHeight: 600),
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            SizedBox(height: 16),
            _buildAddSection(),
            SizedBox(height: 12),
            _buildSearchSection(),
            SizedBox(height: 12),
            Divider(),
            SizedBox(height: 8),
            Expanded(child: _buildFingerprintsList()),
            SizedBox(height: 12),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context)!.close),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.fingerprint,
          size: 28,
          color: Theme.of(context).colorScheme.primary,
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(
                  context,
                )!.manageFingerprintsFor(widget.employee.name),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                'الرمز: ${widget.employee.employeeID}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddSection() {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: TextField(
            controller: _fingerIndexController,
            keyboardType: TextInputType.number,
            textDirection: .ltr,
            cursorHeight: 20,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.fingerprintNumber,
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: _biometricController,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.biometricTextHint,
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          ),
        ),
        SizedBox(width: 8),
        ElevatedButton.icon(
          icon: Icon(Icons.add, size: 18),
          label: Text(AppLocalizations.of(context)!.addNew),
          onPressed: () {
            final biometric = _biometricController.text.trim();
            if (biometric.isNotEmpty) {
              final fingerIndex =
                  int.tryParse(_fingerIndexController.text.trim()) ?? 0;
              context.read<EmployeesBloc>().add(
                AddFingerprintEvent(
                  entity: EmployeeFingerprintEntity(
                    id: 0,
                    employeeId: widget.employee.uid,
                    biometric: biometric,
                    fingerIndex: fingerIndex,
                  ),
                ),
              );
              _biometricController.clear();
            }
          },
        ),
      ],
    );
  }

  Widget _buildSearchSection() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.searchByFingerprint,
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          ),
        ),
        SizedBox(width: 8),
        ElevatedButton.icon(
          icon: Icon(Icons.search, size: 18),
          label: Text(AppLocalizations.of(context)!.search),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
          onPressed: () {
            final biometric = _searchController.text.trim();
            if (biometric.isNotEmpty) {
              context.read<EmployeesBloc>().add(
                SearchByFingerprintEvent(biometric: biometric),
              );
            }
          },
        ),
        SizedBox(width: 8),
        BlocBuilder<EmployeesBloc, EmployeesState>(
          builder: (context, state) {
            if (state is FingerprintSearchResultState) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: state.result.matched
                      ? Theme.of(
                          context,
                        ).colorScheme.success.withValues(alpha: 0.1)
                      : Theme.of(
                          context,
                        ).colorScheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  state.result.matched
                      ? 'مطابق: ${state.result.employeeName ?? "غير معروف"}'
                      : 'غير مطابق',
                  style: TextStyle(
                    color: state.result.matched
                        ? Theme.of(context).colorScheme.success
                        : Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildFingerprintsList() {
    return BlocBuilder<EmployeesBloc, EmployeesState>(
      builder: (context, state) {
        if (state is EmployeesLoading) {
          return ShimmerLoading.list(items: 5);
        }
        if (state is FingerprintsLoaded) {
          if (state.fingerprints.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.fingerprint,
                    size: 48,
                    color: Colors.grey.shade300,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'لا توجد بصمات مسجلة',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            shrinkWrap: true,
            itemCount: state.fingerprints.length,
            separatorBuilder: (context, index) => Divider(height: 1),
            itemBuilder: (context, index) {
              final fp = state.fingerprints[index];
              return ListTile(
                dense: true,
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                title: Text(
                  fp.biometric.length > 40
                      ? '${fp.biometric.substring(0, 40)}...'
                      : fp.biometric,
                  style: TextStyle(fontSize: 13),
                  textDirection: TextDirection.ltr,
                ),
                subtitle: Text('ID: ${fp.id}', style: TextStyle(fontSize: 11)),
                trailing: IconButton(
                  icon: Icon(
                    Icons.delete,
                    size: 18,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  onPressed: () => _confirmDeleteFingerprint(context, fp),
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _confirmDeleteFingerprint(
    BuildContext context,
    EmployeeFingerprintModel fp,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.confirmDelete),
        content: Text(AppLocalizations.of(context)!.confirmDeleteFingerprint),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              context.read<EmployeesBloc>().add(
                DeleteFingerprintEvent(
                  employeeUid: widget.employee.uid,
                  fingerprintId: fp.id,
                ),
              );
              Navigator.pop(ctx);
            },
            child: Text(
              AppLocalizations.of(context)!.delete,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}


/*
DioException [bad response]: This exception was thrown because the response has a status code of 500 and RequestOptions.validateStatus was configured to throw for this status code.
The status code of 500 has the following meaning: "Server error - the server failed to fulfil an apparently valid request"
Read more about status codes at https://developer.mozilla.org/en-US/docs/Web/HTTP/Status
In order to resolve this exception you typically have either to verify and fix your request code or you have to fix the server code.

*/