class Performance {
  final String id;
  final String studentId;
  final DateTime date;
  final int battingRating;
  final int bowlingRating;
  final int fieldingRating;
  final int fitnessRating;
  final int disciplineRating;
  final String? coachRemarks;
  final double overallRating;

  Performance({
    required this.id,
    required this.studentId,
    required this.date,
    this.battingRating = 5,
    this.bowlingRating = 5,
    this.fieldingRating = 5,
    this.fitnessRating = 5,
    this.disciplineRating = 5,
    this.coachRemarks,
    this.overallRating = 5,
  });

  Map<String, dynamic> toMap() => {
    'student': studentId,
    'batting_rating': battingRating,
    'bowling_rating': bowlingRating,
    'fielding_rating': fieldingRating,
    'fitness_rating': fitnessRating,
    'discipline_rating': disciplineRating,
    'coach_remarks': coachRemarks,
  };

  factory Performance.fromMap(Map<String, dynamic> map) => Performance(
    id: map['id']?.toString() ?? '',
    studentId: map['student']?.toString() ?? '',
    date: DateTime.parse(map['date']),
    battingRating: map['batting_rating'] ?? 5,
    bowlingRating: map['bowling_rating'] ?? 5,
    fieldingRating: map['fielding_rating'] ?? 5,
    fitnessRating: map['fitness_rating'] ?? 5,
    disciplineRating: map['discipline_rating'] ?? 5,
    coachRemarks: map['coach_remarks'],
    overallRating: (map['overall_rating'] ?? 5).toDouble(),
  );
}
