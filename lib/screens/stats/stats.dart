import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// Constants for Firestore collection and field names
const String _reportsCollection = 'reports';
const String _statusField = 'status';
const String _riskLevelField = 'riskLevel';

// Constants for statistics map keys
const String _totalReportsKey = 'totalReports';
const String _reportsByStatusKey = 'reportsByStatus';
const String _reportsByRiskLevelKey = 'reportsByRiskLevel';

class AdminStatsScreen extends StatefulWidget {
  const AdminStatsScreen({Key? key}) : super(key: key);

  @override
  _AdminStatsScreenState createState() => _AdminStatsScreenState();
}

class _AdminStatsScreenState extends State<AdminStatsScreen> {
  static const List<Color> _chartColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.amber,
    Colors.cyan,
    Colors.indigo,
  ];

  Future<Map<String, dynamic>> _fetchReportStatistics() async {
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection(_reportsCollection).get();

    if (snapshot.docs.isEmpty) {
      return {
        _totalReportsKey: 0,
        _reportsByStatusKey: <String, int>{},
        _reportsByRiskLevelKey: <int, int>{},
      };
    }

    int totalReports = snapshot.docs.length;
    Map<String, int> reportsByStatus = {};
    Map<int, int> reportsByRiskLevel = {};

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;

      // Status statistics
      final status = data[_statusField] as String?;
      if (status != null) {
        reportsByStatus[status] = (reportsByStatus[status] ?? 0) + 1;
      }

      // Risk level statistics
      final riskLevel = data[_riskLevelField] as int?;
      if (riskLevel != null) {
        reportsByRiskLevel[riskLevel] =
            (reportsByRiskLevel[riskLevel] ?? 0) + 1;
      }
    }

    return {
      _totalReportsKey: totalReports,
      _reportsByStatusKey: reportsByStatus,
      _reportsByRiskLevelKey: reportsByRiskLevel,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estatísticas do Administrador'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchReportStatistics(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Nenhum dado encontrado.'));
          }

          final stats = snapshot.data!;
          final int totalReports = stats[_totalReportsKey];
          final Map<String, int> reportsByStatus = stats[_reportsByStatusKey];
          final Map<int, int> reportsByRiskLevel =
              stats[_reportsByRiskLevelKey];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                _buildStatCard(
                  title: 'Total de Denúncias',
                  value: totalReports.toString(),
                  icon: Icons.assessment,
                ),
                const SizedBox(height: 16),
                _buildSectionTitle('Denúncias por Estado'),
                if (reportsByStatus.isEmpty)
                  const Center(child: Text('Nenhum dado de estado disponível.'))
                else
                  SizedBox(
                      height: 250,
                      child: _buildStatusPieChart(reportsByStatus)),
                const SizedBox(height: 16),
                _buildSectionTitle('Denúncias por Nível de Risco'),
                if (reportsByRiskLevel.isEmpty)
                  const Center(
                      child: Text('Nenhum dado de nível de risco disponível.'))
                else
                  SizedBox(
                      height: 250,
                      child: _buildRiskLevelBarChart(reportsByRiskLevel)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStatCard(
      {required String title, required String value, IconData? icon}) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: icon != null
            ? Icon(icon, color: Theme.of(context).primaryColor)
            : null,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildStatusPieChart(Map<String, int> reportsByStatus) {
    final List<PieChartSectionData> sections = [];
    final List<MapEntry<String, int>> entries =
        reportsByStatus.entries.toList();
    final double totalValue =
        entries.fold(0.0, (prev, element) => prev + element.value.toDouble());

    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final status = entry.key;
      final count = entry.value;

      const fontSize = 13.0; // Static font size
      const radius = 60.0; // Static radius

      String titleText;
      if (totalValue > 0 && (count / totalValue) < 0.07 && count > 0) {
        // If slice is small
        titleText = count.toString(); // Show only count for small slices
      } else {
        titleText = '$status\n($count)';
      }

      sections.add(PieChartSectionData(
        color: _chartColors[i % _chartColors.length],
        value: count.toDouble(),
        title: titleText,
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white, // Ensure good contrast
          shadows: [const Shadow(color: Colors.black54, blurRadius: 3)],
        ),
      ));
    }

    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(
          enabled: false, // Disable touch interactions
        ),
        borderData: FlBorderData(show: false),
        sectionsSpace: 3, // Adjusted space for a cleaner look
        centerSpaceRadius: 50, // Creates a "donut" chart, often cleaner
        sections: sections.isEmpty
            ? [
                // Fallback for empty data to prevent errors and show a placeholder
                PieChartSectionData(
                    color: Colors.grey[300],
                    value: 1,
                    title: 'N/A',
                    radius: 60,
                    titleStyle:
                        TextStyle(fontSize: 14, color: Colors.grey[700]))
              ]
            : sections,
      ),
    );
  }

  Widget _buildRiskLevelBarChart(Map<int, int> reportsByRiskLevel) {
    final List<BarChartGroupData> barGroups = [];
    int colorIndex = 0;
    final sortedKeys = reportsByRiskLevel.keys.toList()..sort();

    double maxYFromData = 0;
    if (reportsByRiskLevel.values.isNotEmpty) {
      maxYFromData =
          reportsByRiskLevel.values.reduce((a, b) => a > b ? a : b).toDouble();
    }
    // Ensure a minimum maxY for the chart axis, especially if all data points are 0.
    double maxYForAxis = (maxYFromData == 0 && reportsByRiskLevel.isNotEmpty)
        ? 10.0
        : maxYFromData;
    if (reportsByRiskLevel.isEmpty)
      maxYForAxis = 10.0; // Default if called with empty data

    final chartMaxY = maxYForAxis + (maxYForAxis * 0.2); // Add 20% padding

    for (var riskLevel in sortedKeys) {
      final count = reportsByRiskLevel[riskLevel]!;
      barGroups.add(
        BarChartGroupData(
          x: riskLevel,
          barRods: [
            BarChartRodData(
              toY: count.toDouble(),
              gradient: LinearGradient(
                // Apply gradient for better visuals
                colors: [
                  _chartColors[colorIndex % _chartColors.length].withAlpha(180),
                  _chartColors[colorIndex % _chartColors.length],
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              width: 20, // Slightly wider bars
              borderRadius: const BorderRadius.only(
                // Rounded top corners
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
          ],
          // showingTooltipIndicators: [0], // Handled by BarTouchData
        ),
      );
      colorIndex++;
    }

    final double yAxisInterval =
        maxYForAxis > 5 ? (maxYForAxis / 5).ceilToDouble() : 1;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: chartMaxY,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            // Note: tooltipBgColor availability and other tooltip styling options
            // might vary based on your fl_chart version.
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                'Nível ${group.x.toInt()}\n${rod.toY.toInt()} Denúncias',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            },
          ),
          handleBuiltInTouches: true,
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0), // Increased padding
                  child: Text('Nível ${value.toInt()}',
                      style: const TextStyle(fontSize: 10)),
                );
              },
              reservedSize: 32, // Adjusted reserved size
            ),
          ),
          leftTitles: AxisTitles(
              sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 36, // Adjusted for label space
            interval: yAxisInterval,
            getTitlesWidget: (double value, TitleMeta meta) {
              if (value == meta.max && maxYFromData > 0)
                return const SizedBox.shrink(); // Avoid clutter at top
              if (value == 0 &&
                  maxYFromData == 0 &&
                  reportsByRiskLevel.isNotEmpty)
                return Text(value.toInt().toString(),
                    style: const TextStyle(fontSize: 10));
              if (value == 0) return const SizedBox.shrink();
              return Text(value.toInt().toString(),
                  style: const TextStyle(fontSize: 10));
            },
          )),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
            // Subtle border for the chart area
            show: true,
            border: Border(
              bottom: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1),
              left: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1),
            )),
        barGroups: barGroups,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: yAxisInterval,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.2), // Lighter grid lines
              strokeWidth: 1,
            );
          },
        ),
      ),
    );
  }
}
