/// Extensions to [Object].
extension ObjectExtension on Object {
  /// Returns the Object as the specified [T] type.
  T? as<T>() => this is T ? this as T : null;
}

/// Extensions to [String].
extension StringExtension on String {
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
  );

  /// Whether this string is a valid email.
  bool get isValidEmail => isNotEmpty && _emailRegExp.hasMatch(this);
}
