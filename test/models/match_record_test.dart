import 'package:flutter_test/flutter_test.dart';
import 'package:young_fighters_academy/models/match_record.dart';

void main() {
  group('MatchRecord', () {
    test('fromMap creates instance correctly', () {
      final json = {
        'id': '1',
        'matchDate': '2026-07-15T00:00:00.000',
        'opponent': 'Mumbai Academy',
        'runs': 85,
        'wickets': 2,
        'catches': 1,
        'strikeRate': 125.5,
        'economy': 4.5,
        'result': 'Win',
        'isManOfTheMatch': true,
      };
      final match = MatchRecord.fromMap(json);

      expect(match.id, '1');
      expect(match.opponent, 'Mumbai Academy');
      expect(match.runs, 85);
      expect(match.wickets, 2);
      expect(match.result, 'Win');
      expect(match.isManOfTheMatch, true);
    });

    test('toMap produces correct map', () {
      final match = MatchRecord(
        id: '2',
        matchDate: DateTime(2026, 7, 10),
        opponent: 'Delhi Academy',
        runs: 45,
        wickets: 0,
        catches: 2,
        strikeRate: 90.0,
        economy: 6.0,
        result: 'Loss',
        isManOfTheMatch: false,
      );
      final map = match.toMap();

      expect(map['id'], '2');
      expect(map['opponent'], 'Delhi Academy');
      expect(map['result'], 'Loss');
      expect(map['isManOfTheMatch'], false);
    });

    test('default values are applied', () {
      final match = MatchRecord(
        id: '3',
        matchDate: DateTime(2026, 7, 1),
        opponent: 'Test Team',
      );
      expect(match.runs, 0);
      expect(match.wickets, 0);
      expect(match.catches, 0);
      expect(match.strikeRate, 0);
      expect(match.economy, 0);
      expect(match.result, '');
      expect(match.isManOfTheMatch, false);
    });

    test('toMap and fromMap round trip', () {
      final original = MatchRecord(
        id: '4',
        matchDate: DateTime(2026, 7, 22),
        opponent: 'Chennai Academy',
        runs: 102,
        wickets: 3,
        catches: 2,
        strikeRate: 140.0,
        economy: 3.2,
        result: 'Win',
        isManOfTheMatch: true,
      );
      final map = original.toMap();
      final reconstructed = MatchRecord.fromMap(map);

      expect(reconstructed.id, original.id);
      expect(reconstructed.runs, original.runs);
      expect(reconstructed.isManOfTheMatch, original.isManOfTheMatch);
    });
  });
}
