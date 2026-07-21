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
    'id': id,
    'studentId': studentId,
    'date': date.toIso8601String(),
    'battingRating': battingRating,
    'bowlingRating': bowlingRating,
    'fieldingRating': fieldingRating,
    'fitnessRating': fitnessRating,
    'disciplineRating': disciplineRating,
    'coachRemarks': coachRemarks,
    'overallRating': overallRating,
  };

  factory Performance.fromMap(Map<String, dynamic> map) => Performance(
    id: map['id'] ?? '',
    studentId: map['studentId'] ?? '',
    date: DateTime.parse(map['date']),
    battingRating: map['battingRating'] ?? 5,
    bowlingRating: map['bowlingRating'] ?? 5,
    fieldingRating: map['fieldingRating'] ?? 5,
    fitnessRating: map['fitnessRating'] ?? 5,
    disciplineRating: map['disciplineRating'] ?? 5,
    coachRemarks: map['coachRemarks'],
    overallRating: (map['overallRating'] ?? 5).toDouble(),
  );
}
