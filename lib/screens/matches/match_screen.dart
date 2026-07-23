import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/match_provider.dart';
import '../../models/match_record.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _opponentCtrl = TextEditingController();
  final _venueCtrl = TextEditingController();
  final _runsCtrl = TextEditingController();
  final _wicketsCtrl = TextEditingController();
  final _catchesCtrl = TextEditingController();
  final _strikeRateCtrl = TextEditingController();
  final _economyCtrl = TextEditingController();
  String _result = 'Win';
  bool _isMOTM = false;
  DateTime _matchDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MatchProvider>().loadMatches();
    });
  }

  @override
  void dispose() {
    _opponentCtrl.dispose();
    _venueCtrl.dispose();
    _runsCtrl.dispose();
    _wicketsCtrl.dispose();
    _catchesCtrl.dispose();
    _strikeRateCtrl.dispose();
    _economyCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final match = MatchRecord(
      id: const Uuid().v4(),
      matchDate: _matchDate,
      opponent: _opponentCtrl.text.trim(),
      venue: _venueCtrl.text.trim(),
      runs: int.tryParse(_runsCtrl.text) ?? 0,
      wickets: int.tryParse(_wicketsCtrl.text) ?? 0,
      catches: int.tryParse(_catchesCtrl.text) ?? 0,
      strikeRate: double.tryParse(_strikeRateCtrl.text) ?? 0,
      economy: double.tryParse(_economyCtrl.text) ?? 0,
      result: _result,
      isManOfTheMatch: _isMOTM,
    );

    final success = await context.read<MatchProvider>().addMatch(match);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Match record added'),
            backgroundColor: Colors.green),
      );
      _opponentCtrl.clear();
      _venueCtrl.clear();
      _runsCtrl.clear();
      _wicketsCtrl.clear();
      _catchesCtrl.clear();
      _strikeRateCtrl.clear();
      _economyCtrl.clear();
      setState(() {
        _result = 'Win';
        _isMOTM = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Match Records')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Add New Match',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _opponentCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Opponent *',
                            prefixIcon: Icon(Icons.sports)),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _venueCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Venue',
                            prefixIcon: Icon(Icons.location_on)),
                      ),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(child: TextFormField(
                            controller: _runsCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: 'Runs',
                                prefixIcon: Icon(Icons.score)))),
                        const SizedBox(width: 12),
                        Expanded(child: TextFormField(
                            controller: _wicketsCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: 'Wickets',
                                prefixIcon: Icon(Icons.sports_baseball)))),
                      ]),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(child: TextFormField(
                            controller: _catchesCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: 'Catches',
                                prefixIcon: Icon(Icons.pan_tool)))),
                        const SizedBox(width: 12),
                        Expanded(child: TextFormField(
                            controller: _strikeRateCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: 'Strike Rate',
                                prefixIcon: Icon(Icons.trending_up)))),
                      ]),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(child: TextFormField(
                            controller: _economyCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: 'Economy',
                                prefixIcon: Icon(Icons.speed)))),
                        const SizedBox(width: 12),
                        Expanded(child: DropdownButtonFormField<String>(
                            value: _result,
                            decoration: const InputDecoration(
                                labelText: 'Result',
                                prefixIcon: Icon(Icons.emoji_events)),
                            items: AppConstants.matchResults.map((r) =>
                                DropdownMenuItem(value: r, child: Text(r)))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _result = v!))),
                      ]),
                      const SizedBox(height: 12),
                      CheckboxListTile(
                        title: const Text('Man of the Match'),
                        value: _isMOTM,
                        onChanged: (v) =>
                            setState(() => _isMOTM = v ?? false),
                        activeColor: AppTheme.gold,
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _save,
                          child: const Text('Save Match Record'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Consumer<MatchProvider>(
              builder: (context, mp, _) {
                if (mp.matches.isEmpty) return const SizedBox();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Match History',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...mp.matches.map((m) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: m.result == 'Win'
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : AppTheme.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                m.result == 'Win'
                                    ? Icons.emoji_events
                                    : Icons.sports_esports,
                                color: m.result == 'Win'
                                    ? Colors.green
                                    : AppTheme.red,
                              ),
                            ),
                            title: Text('vs ${m.opponent}'),
                            subtitle: Text([
                              if (m.venue.isNotEmpty) m.venue,
                              'Runs: ${m.runs} | Wkts: ${m.wickets}',
                            ].join(' • ')),
                            trailing: Text(m.result,
                                style: TextStyle(
                                  color: m.result == 'Win'
                                      ? Colors.green
                                      : AppTheme.red,
                                  fontWeight: FontWeight.bold,
                                )),
                          ),
                        )),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
