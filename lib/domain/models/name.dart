enum NameGender { male, female, neutral }

class Name {
  final String id;
  final String display;
  final NameGender gender;
  final List<String> variants;
  final bool isCustom;

  const Name({
    required this.id,
    required this.display,
    required this.gender,
    this.variants = const [],
    this.isCustom = false,
  });

  static NameGender genderFromCode(String code) => switch (code) {
        'm' => NameGender.male,
        'f' => NameGender.female,
        _ => NameGender.neutral,
      };

  static String genderToCode(NameGender gender) => switch (gender) {
        NameGender.male => 'm',
        NameGender.female => 'f',
        NameGender.neutral => 'n',
      };
}
