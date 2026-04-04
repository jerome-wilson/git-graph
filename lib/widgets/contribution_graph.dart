import 'package:flutter/material.dart';
import '../models/contribution.dart';

/// GitHub contribution colors (dark theme)
class GitHubColors {
  static const Color background = Color(0xFF161b22);
  static const Color level0 = Color(0xFF161b22); // No contributions
  static const Color level1 = Color(0xFF0e4429); // First quartile
  static const Color level2 = Color(0xFF006d32); // Second quartile
  static const Color level3 = Color(0xFF26a641); // Third quartile
  static const Color level4 = Color(0xFF39d353); // Fourth quartile
  static const Color border = Color(0xFF30363d);
  static const Color text = Color(0xFF8b949e);

  static Color getColorForLevel(int level) {
    switch (level) {
      case 0:
        return level0;
      case 1:
        return level1;
      case 2:
        return level2;
      case 3:
        return level3;
      case 4:
        return level4;
      default:
        return level0;
    }
  }
}

/// A widget that displays the GitHub contribution graph
class ContributionGraph extends StatelessWidget {
  final ContributionData? data;
  final int weeksToShow;
  final double cellSize;
  final double cellSpacing;
  final double borderRadius;
  final bool showMonthLabels;
  final bool showDayLabels;

  const ContributionGraph({
    super.key,
    this.data,
    this.weeksToShow = 52,
    this.cellSize = 10,
    this.cellSpacing = 3,
    this.borderRadius = 2,
    this.showMonthLabels = true,
    this.showDayLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return _buildEmptyGraph();
    }

    final weeks = data!.getLastWeeks(weeksToShow);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GitHubColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: GitHubColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showMonthLabels) ...[
            _buildMonthLabels(weeks),
            const SizedBox(height: 4),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showDayLabels) ...[
                _buildDayLabels(),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: _buildGrid(weeks),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildEmptyGraph() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GitHubColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: GitHubColors.border),
      ),
      child: const Center(
        child: Text(
          'No contribution data',
          style: TextStyle(color: GitHubColors.text),
        ),
      ),
    );
  }

  Widget _buildMonthLabels(List<ContributionWeek> weeks) {
    final months = <String>[];
    final monthPositions = <int>[];
    String? lastMonth;

    for (int i = 0; i < weeks.length; i++) {
      if (weeks[i].days.isNotEmpty) {
        final date = weeks[i].days.first.date;
        final monthName = _getMonthName(date.month);
        if (monthName != lastMonth) {
          months.add(monthName);
          monthPositions.add(i);
          lastMonth = monthName;
        }
      }
    }

    return SizedBox(
      height: 15,
      child: Row(
        children: [
          if (showDayLabels) SizedBox(width: 28),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final totalWidth = constraints.maxWidth;
                final weekWidth = cellSize + cellSpacing;
                
                return Stack(
                  children: List.generate(months.length, (index) {
                    final position = monthPositions[index] * weekWidth;
                    if (position > totalWidth - 30) return const SizedBox();
                    
                    return Positioned(
                      left: position,
                      child: Text(
                        months[index],
                        style: const TextStyle(
                          color: GitHubColors.text,
                          fontSize: 10,
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayLabels() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: cellSize + cellSpacing), // Mon (skip)
        _buildDayLabel(''), // Tue
        SizedBox(height: cellSize + cellSpacing),
        _buildDayLabel('Wed'),
        SizedBox(height: cellSize + cellSpacing),
        _buildDayLabel(''), // Thu
        SizedBox(height: cellSize + cellSpacing),
        _buildDayLabel('Fri'),
        SizedBox(height: cellSize + cellSpacing),
        _buildDayLabel(''), // Sat
      ],
    );
  }

  Widget _buildDayLabel(String label) {
    return SizedBox(
      height: cellSize,
      width: 24,
      child: Text(
        label,
        style: const TextStyle(
          color: GitHubColors.text,
          fontSize: 9,
        ),
      ),
    );
  }

  Widget _buildGrid(List<ContributionWeek> weeks) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: weeks.map((week) => _buildWeekColumn(week)).toList(),
      ),
    );
  }

  Widget _buildWeekColumn(ContributionWeek week) {
    // Ensure we have 7 days, padding with empty cells if needed
    final days = List<ContributionDay?>.filled(7, null);
    for (final day in week.days) {
      final weekday = day.date.weekday - 1; // 0 = Monday, 6 = Sunday
      if (weekday >= 0 && weekday < 7) {
        days[weekday] = day;
      }
    }

    return Padding(
      padding: EdgeInsets.only(right: cellSpacing),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: days.map((day) => _buildCell(day)).toList(),
      ),
    );
  }

  Widget _buildCell(ContributionDay? day) {
    final level = day?.contributionLevel ?? 0;
    final color = GitHubColors.getColorForLevel(level);

    return Padding(
      padding: EdgeInsets.only(bottom: cellSpacing),
      child: Tooltip(
        message: day != null
            ? '${day.contributionCount} contributions on ${_formatDate(day.date)}'
            : 'No data',
        child: Container(
          width: cellSize,
          height: cellSize,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Text(
          'Less',
          style: TextStyle(
            color: GitHubColors.text,
            fontSize: 10,
          ),
        ),
        const SizedBox(width: 4),
        ...List.generate(5, (index) {
          return Padding(
            padding: const EdgeInsets.only(left: 2),
            child: Container(
              width: cellSize,
              height: cellSize,
              decoration: BoxDecoration(
                color: GitHubColors.getColorForLevel(index),
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
          );
        }),
        const SizedBox(width: 4),
        const Text(
          'More',
          style: TextStyle(
            color: GitHubColors.text,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  String _formatDate(DateTime date) {
    return '${_getMonthName(date.month)} ${date.day}, ${date.year}';
  }
}

/// A compact version of the contribution graph for widgets
class CompactContributionGraph extends StatelessWidget {
  final List<List<int>>? weeklyLevels;
  final double cellSize;
  final double cellSpacing;
  final double borderRadius;

  const CompactContributionGraph({
    super.key,
    this.weeklyLevels,
    this.cellSize = 8,
    this.cellSpacing = 2,
    this.borderRadius = 2,
  });

  @override
  Widget build(BuildContext context) {
    if (weeklyLevels == null || weeklyLevels!.isEmpty) {
      return Container(
        color: GitHubColors.background,
        child: const Center(
          child: Text(
            'No data',
            style: TextStyle(color: GitHubColors.text, fontSize: 10),
          ),
        ),
      );
    }

    return Container(
      color: GitHubColors.background,
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: weeklyLevels!.map((week) => _buildWeekColumn(week)).toList(),
      ),
    );
  }

  Widget _buildWeekColumn(List<int> levels) {
    // Ensure we have 7 days
    final paddedLevels = List<int>.filled(7, 0);
    for (int i = 0; i < levels.length && i < 7; i++) {
      paddedLevels[i] = levels[i];
    }

    return Padding(
      padding: EdgeInsets.only(right: cellSpacing),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: paddedLevels.map((level) {
          return Padding(
            padding: EdgeInsets.only(bottom: cellSpacing),
            child: Container(
              width: cellSize,
              height: cellSize,
              decoration: BoxDecoration(
                color: GitHubColors.getColorForLevel(level),
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}