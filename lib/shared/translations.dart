String? formatOpeningHours(String? input, String locale) {
  if (input == null) return null;
  final Map<String, Map<String, String>> dayTranslations = {
    'de': {
      'Mo': 'Mo',
      'Tu': 'Di',
      'We': 'Mi',
      'Th': 'Do',
      'Fr': 'Fr',
      'Sa': 'Sa',
      'Su': 'So',
    },
    'en': {
      'Mo': 'Mon',
      'Tu': 'Tue',
      'We': 'Wed',
      'Th': 'Thu',
      'Fr': 'Fri',
      'Sa': 'Sat',
      'Su': 'Sun',
    },
    'es': {
      'Mo': 'Lun',
      'Tu': 'Mar',
      'We': 'Mié',
      'Th': 'Jue',
      'Fr': 'Vie',
      'Sa': 'Sáb',
      'Su': 'Dom',
    },
    'fr': {
      'Mo': 'Lun',
      'Tu': 'Mar',
      'We': 'Mer',
      'Th': 'Jeu',
      'Fr': 'Ven',
      'Sa': 'Sam',
      'Su': 'Dim',
    },
    'it': {
      'Mo': 'Lun',
      'Tu': 'Mar',
      'We': 'Mer',
      'Th': 'Gio',
      'Fr': 'Ven',
      'Sa': 'Sab',
      'Su': 'Dom',
    },
    'pl': {
      'Mo': 'Pon',
      'Tu': 'Wt',
      'We': 'Śr',
      'Th': 'Czw',
      'Fr': 'Pt',
      'Sa': 'Sob',
      'Su': 'Niedz',
    },
  };

  final translations = dayTranslations[locale] ?? dayTranslations['en']!;
  input = translations.entries.fold(input, (updated, entry) {
    return updated.replaceAll(entry.key, entry.value);
  });
  return input.split(";").map((k) => k.trim()).join("\n");
}
