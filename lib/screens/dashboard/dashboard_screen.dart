import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/dashboard_provider.dart';
import '../../config/theme.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/loading_widget.dart';
import '../students/student_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<DashboardProvider>().loadDashboardData(),
          ),
        ],
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, dash, _) {
          if (dash.isLoading) {
            return const LoadingWidget(message: 'Loading dashboard...');
          }

          return RefreshIndicator(
            onRefresh: dash.loadDashboardData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeCard(context, isDark),
                  const SizedBox(height: 16),
                  _buildStatsGrid(context, dash, isDark),
                  const SizedBox(height: 16),
                  _buildChart(context, dash, isDark),
                  const SizedBox(height: 16),
                  _buildRecentActivities(context, dash, isDark),
                  const SizedBox(height: 16),
                  _buildFeeDueList(context, dash, isDark),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryGreen, AppTheme.darkGreen],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.sports_cricket, color: AppTheme.gold, size: 28),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.trending_up, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text('Live',
                        style: TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Young Fighters Academy',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Cricket Academy Management System',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, DashboardProvider dash, bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Total Students',
                value: dash.totalStudents.toString(),
                icon: Icons.people,
                color: AppTheme.primaryGreen,
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const StudentListScreen()));
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'Active',
                value: dash.activeStudents.toString(),
                icon: Icons.person_pin,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: "Today's Attendance",
                value: '${dash.attendancePercentage.toStringAsFixed(1)}%',
                icon: Icons.check_circle,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'Fee Collected',
                value: 'Rs.${dash.feeCollected.toStringAsFixed(0)}',
                icon: Icons.account_balance_wallet,
                color: AppTheme.gold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Net Profit',
                value: 'Rs.${dash.netProfit.toStringAsFixed(0)}',
                icon: Icons.trending_up,
                color: dash.netProfit >= 0 ? Colors.green : AppTheme.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'Pending Fees',
                value: 'Rs.${dash.pendingFees.toStringAsFixed(0)}',
                icon: Icons.warning_amber,
                color: AppTheme.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChart(BuildContext context, DashboardProvider dash, bool isDark) {
    final income = dash.monthlyIncome;
    final expenses = dash.monthlyExpenses;
    final profit = dash.netProfit;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Monthly Overview',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
            const SizedBox(height: 24),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (income > expenses ? income : expenses) * 1.3,
                  barGroups: [
                    _makeBarGroup(0, 'Income', income, AppTheme.primaryGreen),
                    _makeBarGroup(1, 'Expenses', expenses, AppTheme.red),
                    _makeBarGroup(2, 'Profit', profit >= 0 ? profit : 0,
                        profit >= 0 ? Colors.green : AppTheme.orange),
                  ],
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const titles = ['Income', 'Expenses', 'Profit'];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(titles[value.toInt()],
                                style: const TextStyle(fontSize: 11)),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: income > 1000 ? 1000 : 100,
                  ),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, String label, double value, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: value,
          color: color,
          width: 28,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivities(
      BuildContext context, DashboardProvider dash, bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, size: 20,
                    color: isDark ? Colors.white : AppTheme.black),
                const SizedBox(width: 8),
                Text('Recent Activities',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        )),
              ],
            ),
            const SizedBox(height: 12),
            if (dash.recentActivities.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('No recent activities',
                    style: TextStyle(color: Colors.grey[500])),
              )
            else
              ...dash.recentActivities.map((a) => ListTile(
                    dense: true,
                    leading: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.circle,
                          size: 8, color: AppTheme.primaryGreen),
                    ),
                    title: Text(a['action'] ?? '',
                        style: const TextStyle(fontSize: 14)),
                    subtitle: Text(a['details'] ?? '',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey[600])),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeDueList(
      BuildContext context, DashboardProvider dash, bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, size: 20, color: AppTheme.orange),
                const SizedBox(width: 8),
                Text('Upcoming Fee Due',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        )),
              ],
            ),
            const SizedBox(height: 12),
            if (dash.feeDueList.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('No pending fees',
                    style: TextStyle(color: Colors.grey[500])),
              )
            else
              ...dash.feeDueList.map((f) => ListTile(
                    dense: true,
                    leading: const Icon(Icons.person,
                        color: AppTheme.primaryGreen),
                    title: Text('Student: ${f['studentId'] ?? ''}',
                        style: const TextStyle(fontSize: 14)),
                    subtitle: Text(
                        'Due: Rs.${f['monthlyFee'] ?? 0} | ${f['month'] ?? ''}',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey[600])),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Pending',
                          style: TextStyle(
                              color: AppTheme.red,
                              fontSize: 11,
                              fontWeight: FontWeight.w500)),
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}
