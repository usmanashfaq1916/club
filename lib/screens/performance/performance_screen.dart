import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:uuid/uuid.dart';
import '../../providers/performance_provider.dart';
import '../../models/performance.dart';
import '../../config/theme.dart';

class PerformanceScreen extends StatefulWidget {
  final String studentId;

  const PerformanceScreen({super.key, required this.studentId});

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {
  int _batting = 5;
  int _bowling = 5;
  int _fielding = 5;
  int _fitness = 5;
  int _discipline = 5;
  final _remarksCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLatest();
  }

  void _loadLatest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final perf = context.read<PerformanceProvider>();
      final latest = perf.getLatestPerformance(widget.studentId);
      if (latest != null) {
        setState(() {
          _batting = latest.battingRating;
          _bowling = latest.bowlingRating;
          _fielding = latest.fieldingRating;
          _fitness = latest.fitnessRating;
          _discipline = latest.disciplineRating;
          _remarksCtrl.text = latest.coachRemarks ?? '';
        });
      }
    });
  }

  Future<void> _save() async {
    final performance = Performance(
      id: const Uuid().v4(),
      studentId: widget.studentId,
      date: DateTime.now(),
      battingRating: _batting,
      bowlingRating: _bowling,
      fieldingRating: _fielding,
      fitnessRating: _fitness,
      disciplineRating: _discipline,
      coachRemarks:
          _remarksCtrl.text.isNotEmpty ? _remarksCtrl.text : null,
      overallRating: (_batting + _bowling + _fielding + _fitness + _discipline) /
          5.0,
    );

    final success =
        await context.read<PerformanceProvider>().addPerformance(performance);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Performance saved' : 'Failed to save'),
        backgroundColor: success ? Colors.green : AppTheme.red,
      ),
    );
  }

  @override
  void dispose() {
    _remarksCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final overall =
        (_batting + _bowling + _fielding + _fitness + _discipline) / 5.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _save,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Overall Rating',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: RadarChart(
                        RadarChartData(
                          radarShape: RadarShape.polygon,
                          tickCount: 5,
                          dataSets: [
                            RadarDataSet(
                              fillColor:
                                  AppTheme.primaryGreen.withValues(alpha: 0.2),
                              borderColor: AppTheme.primaryGreen,
                              entryRadius: 4,
                              dataEntries: [
                                RadarEntry(value: _batting.toDouble()),
                                RadarEntry(value: _bowling.toDouble()),
                                RadarEntry(value: _fielding.toDouble()),
                                RadarEntry(value: _fitness.toDouble()),
                                RadarEntry(value: _discipline.toDouble()),
                              ],
                            ),
                          ],
                          getTitle: (index, angle) {
                            const titles = [
                              'Batting',
                              'Bowling',
                              'Fielding',
                              'Fitness',
                              'Discipline'
                            ];
                            return RadarChartTitle(
                              text: titles[index],
                              angle: angle,
                            );
                          },
                          titleTextStyle: TextStyle(
                            color: isDark ? Colors.white : AppTheme.black,
                            fontSize: 12,
                          ),
                          ticksTextStyle:
                              const TextStyle(color: Colors.transparent),
                          gridBorderData: BorderSide(
                            color: Colors.grey.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${overall.toStringAsFixed(1)} / 10',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryGreen,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildRatingSlider('Batting', _batting, (v) {
              setState(() => _batting = v);
            }),
            _buildRatingSlider('Bowling', _bowling, (v) {
              setState(() => _bowling = v);
            }),
            _buildRatingSlider('Fielding', _fielding, (v) {
              setState(() => _fielding = v);
            }),
            _buildRatingSlider('Fitness', _fitness, (v) {
              setState(() => _fitness = v);
            }),
            _buildRatingSlider('Discipline', _discipline, (v) {
              setState(() => _discipline = v);
            }),
            const SizedBox(height: 12),
            TextField(
              controller: _remarksCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Coach Remarks',
                prefixIcon: Icon(Icons.notes),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text('Save Performance',
                    style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSlider(
      String label, int value, ValueChanged<int> onChanged) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.w500)),
            ),
            Expanded(
              child: Slider(
                value: value.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                activeColor: AppTheme.primaryGreen,
                onChanged: (v) => onChanged(v.round()),
              ),
            ),
            SizedBox(
              width: 30,
              child: Text(
                '$value',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
