import 'package:flutter_test/flutter_test.dart';
import 'package:young_fighters_academy/models/performance.dart';

void main() {
  group('Performance', () {
    test('fromMap creates instance correctly', () {
      final json = {
        'id': '1',
        'studentId': '1',
        'date': '2026-07-20T00:00:00.000',
        'battingRating': 8,
        'bowlingRating': 7,
        'fieldingRating': 9,
        'fitnessRating': 8,
        'disciplineRating': 9,
        'coachRemarks': 'Good improvement',
        'overallRating': 8.2,
      };
      final perf = Performance.fromMap(json);

      expect(perf.id, '1');
      expect(perf.studentId, '1');
      expect(perf.battingRating, 8);
      expect(perf.bowlingRating, 7);
      expect(perf.fieldingRating, 9);
      expect(perf.fitnessRating, 8);
      expect(perf.disciplineRating, 9);
      expect(perf.coachRemarks, 'Good improvement');
      expect(perf.overallRating, 8.2);
    });

    test('toMap produces correct map', () {
      final perf = Performance(
        id: '2',
        studentId: '2',
        date: DateTime(2026, 7, 19),
        battingRating: 6,
        bowlingRating: 6,
        fieldingRating: 7,
        fitnessRating: 5,
        disciplineRating: 8,
        coachRemarks: null,
        overallRating: 6.4,
      );
      final map = perf.toMap();

      expect(map['id'], '2');
      expect(map['battingRating'], 6);
      expect(map['coachRemarks'], null);
    });

    test('default values are applied', () {
      final perf = Performance(
        id: '3',
        studentId: '3',
        date: DateTime(2026, 7, 18),
      );
      expect(perf.battingRating, 5);
      expect(perf.bowlingRating, 5);
      expect(perf.fieldingRating, 5);
      expect(perf.fitnessRating, 5);
      expect(perf.disciplineRating, 5);
      expect(perf.overallRating, 5);
    });

    test('toMap and fromMap round trip', () {
      final original = Performance(
        id: '4',
        studentId: '1',
        date: DateTime(2026, 7, 22),
        battingRating: 9,
        bowlingRating: 8,
        fieldingRating: 7,
        fitnessRating: 9,
        disciplineRating: 10,
        coachRemarks: 'Excellent',
        overallRating: 8.6,
      );
      final map = original.toMap();
      final reconstructed = Performance.fromMap(map);

      expect(reconstructed.id, original.id);
      expect(reconstructed.overallRating, original.overallRating);
      expect(reconstructed.coachRemarks, original.coachRemarks);
    });
  });
}
