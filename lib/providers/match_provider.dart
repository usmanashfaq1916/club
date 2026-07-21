import 'package:flutter/material.dart';
import '../models/match_record.dart';
import '../services/api_client.dart';

class MatchProvider extends ChangeNotifier {
  List<MatchRecord> _matches = [];
  bool _isLoading = false;
  String? _error;

  List<MatchRecord> get matches => _matches;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMatches() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await ApiClient.get('/matches/');
      final results = data['results'] ?? data ?? [];
      _matches = (results as List)
          .map((j) => MatchRecord.fromMap(Map<String, dynamic>.from(j)))
          .toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addMatch(MatchRecord match) async {
    _isLoading = true;
    notifyListeners();
    try {
      await ApiClient.post('/matches/', body: {
        'match_date': match.matchDate.toIso8601String().split('T')[0],
        'opponent': match.opponent,
        'runs': match.runs,
        'wickets': match.wickets,
        'catches': match.catches,
        'strike_rate': match.strikeRate,
        'economy': match.economy,
        'result': match.result,
        'is_man_of_the_match': match.isManOfTheMatch,
      });
      _isLoading = false;
      await loadMatches();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteMatch(String id) async {
    try {
      await ApiClient.delete('/matches/$id/');
      await loadMatches();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
