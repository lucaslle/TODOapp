/// French day and month names.
///
/// The app ships in one language, so the labels are held here rather than
/// pulled from locale data at runtime — it keeps the bundle small and the
/// startup free of locale initialisation.
abstract final class FrenchCalendar {
  static const List<String> weekdayInitials = <String>[
    'L',
    'M',
    'M',
    'J',
    'V',
    'S',
    'D',
  ];

  static const List<String> weekdayNames = <String>[
    'lundi',
    'mardi',
    'mercredi',
    'jeudi',
    'vendredi',
    'samedi',
    'dimanche',
  ];

  static const List<String> monthNames = <String>[
    'janvier',
    'février',
    'mars',
    'avril',
    'mai',
    'juin',
    'juillet',
    'août',
    'septembre',
    'octobre',
    'novembre',
    'décembre',
  ];

  /// "Mardi 15 septembre"
  static String longDate(DateTime date) {
    final String weekday = _capitalize(weekdayNames[date.weekday - 1]);
    return '$weekday ${date.day} ${monthNames[date.month - 1]}';
  }

  /// "Septembre 2026"
  static String monthAndYear({required int year, required int month}) =>
      '${_capitalize(monthNames[month - 1])} $year';

  /// Monday is 0, Sunday is 6.
  static String weekdayName(int weekdayIndex) => weekdayNames[weekdayIndex % 7];

  static String _capitalize(String word) =>
      word[0].toUpperCase() + word.substring(1);
}
