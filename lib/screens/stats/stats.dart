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
  int _touchedIndex = -1; // For pie chart interaction
  Future<Map<String, dynamic>>? _statisticsFuture;
  // Define a list of colors for chart sections
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

  @override
  void initState() {
    super.initState();
    _statisticsFuture = _fetchReportStatistics();
  }

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
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _statisticsFuture,
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

  List<PieChartSectionData> _generatePieChartSections(
    Map<String, int> reportsByStatus,
    int touchedIndex,
  ) {
    final List<MapEntry<String, int>> entries =
        reportsByStatus.entries.toList();
    // This case should ideally be handled before calling _generatePieChartSections,
    // as _buildStatusPieChart is only called when reportsByStatus is not empty.
    // However, it's a good safeguard.
    if (entries.isEmpty) {
      return [
        PieChartSectionData(
            color: Colors.grey[300],
            value: 1,
            title: 'N/A',
            radius: 60,
            titleStyle: TextStyle(fontSize: 14, color: Colors.grey[700]))
      ];
    }

    final double totalValue =
        entries.fold(0.0, (prev, element) => prev + element.value.toDouble());
    List<PieChartSectionData> sections = [];

    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final status = entry.key;
      final count = entry.value;

      final bool isTouched = i == touchedIndex;
      final double fontSize = isTouched ? 15.0 : 13.0;
      final double radius = isTouched ? 70.0 : 60.0;
      final Color color = _chartColors[i % _chartColors.length];

      String titleText;
      if (isTouched || totalValue == 0) {
        // If touched or no total value, show full details
        titleText = '$status\n($count)';
      } else {
        // Original logic for small slices when not touched
        if ((count / totalValue) < 0.07 && count > 0) {
          titleText = count.toString();
        } else {
          titleText = '$status\n($count)';
        }
      }

      sections.add(PieChartSectionData(
        color: color,
        value: count.toDouble(),
        title: titleText,
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [const Shadow(color: Colors.black54, blurRadius: 3)],
        ),
      ));
    }
    return sections;
  }

  Widget _buildStatusPieChart(Map<String, int> reportsByStatus) {
    final List<MapEntry<String, int>> entries =
        reportsByStatus.entries.toList();

    // The parent widget (in build method) already ensures reportsByStatus is not empty.
    // So, an explicit empty check here is redundant but harmless if _generatePieChartSections handles it.

    return Row(
      children: <Widget>[
        Expanded(
          flex: 2, // Give more space to the chart
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      _touchedIndex = -1;
                      return;
                    }
                    _touchedIndex =
                        pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections:
                  _generatePieChartSections(reportsByStatus, _touchedIndex),
            ),
          ),
        ),
        const SizedBox(width: 18), // Space between chart and legend
        Expanded(
          flex: 1, // Space for the legend
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(entries.length, (i) {
              final entry = entries[i];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: _Indicator(
                  color: _chartColors[i % _chartColors.length],
                  text: entry.key,
                  isSquare: true,
                  textColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white70
                      : Colors.black87,
                ),
              );
            }).toList(),
          ),
        ),
      ],
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

// Simplified Indicator widget (inspired by the example)
class _Indicator extends StatelessWidget {
  const _Indicator({
    Key? key,
    required this.color,
    required this.text,
    this.isSquare = true,
    this.size = 16,
    this.textColor,
  }) : super(key: key);

  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Flexible(
          // Added Flexible to prevent overflow if text is long
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12, // Adjusted for potentially smaller legend space
              fontWeight: FontWeight.bold,
              color: textColor ?? Theme.of(context).textTheme.bodyLarge?.color,
            ),
            overflow: TextOverflow.ellipsis, // Handle long text
          ),
        )
      ],
    );
  }
}
