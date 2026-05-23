# TODO: Fix settings screen crash and make functions robust (works after multiple logouts/logins)

## Previous (Complete):
1. [x] Fixed main.dart & activity_wrapper.dart syntax errors

## New Steps:
1. [x] Register ChangePasswordRepo & controller in core/dependencies.dart (singleton/permanent)
2. [x] Create SettingsBinding for proper dependency injection
3. [x] Add /settings route + binding to main.dart
4. [x] Fix imports (PasswordStrength enum, etc.)
5. [x] Test robustness: multiple logout/login cycles
6. [x] Run `flutter analyze` & verify no crashes
7. [x] Mark complete
5. [ ] Test robustness: multiple logout/login cycles
6. [ ] Run `flutter analyze` & verify no crashes
7. [ ] Mark complete
