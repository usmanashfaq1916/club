class MatchRecord {
  final String id;
  final DateTime matchDate;
  final String opponent;
  final String venue;
  final int runs;
  final int wickets;
  final int catches;
  final double strikeRate;
  final double economy;
  final String result;
  final bool isManOfTheMatch;

  MatchRecord({
    required this.id,
    required this.matchDate,
    required this.opponent,
    this.venue = '',
    this.runs = 0,
    this.wickets = 0,
    this.catches = 0,
    this.strikeRate = 0,
    this.economy = 0,
    this.result = '',
    this.isManOfTheMatch = false,
  });

  Map<String, dynamic> toMap() => {
    'match_date': matchDate.toIso8601String().split('T')[0],
    'opponent': opponent,
    'venue': venue,
    'runs': runs,
    'wickets': wickets,
    'catches': catches,
    'strike_rate': strikeRate.toString(),
    'economy': economy.toString(),
    'result': result,
    'is_man_of_the_match': isManOfTheMatch,
  };

  factory MatchRecord.fromMap(Map<String, dynamic> map) => MatchRecord(
    id: map['id']?.toString() ?? '',
    matchDate: DateTime.parse(map['match_date']),
    opponent: map['opponent'] ?? '',
    venue: map['venue'] ?? '',
    runs: map['runs'] ?? 0,
    wickets: map['wickets'] ?? 0,
    catches: map['catches'] ?? 0,
    strikeRate: (map['strike_rate'] ?? 0).toDouble(),
    economy: (map['economy'] ?? 0).toDouble(),
    result: map['result'] ?? '',
    isManOfTheMatch: map['is_man_of_the_match'] ?? false,
  );
}
