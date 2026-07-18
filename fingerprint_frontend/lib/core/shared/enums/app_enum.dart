/// Base class for advanced enums used across the project.
abstract class AppEnum {
  const AppEnum();

  String get name;
  int get index;

  /// Provide a human-friendly display name. `localization` is intentionally
  /// typed as `dynamic` to avoid forcing a dependency on any particular
  /// localization package; callers may pass their `AppLocalizations`.
  String displayName(dynamic localization);

  @override
  String toString() => name;
}
