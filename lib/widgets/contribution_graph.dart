import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/contribution.dart';

/// GitHub contribution colors (dark theme)
class GitHubColors {
  static const Color background = Color(0xFF161b22);
  static const Color level0 = Color(0xFF21262d); // No contributions (visible gray)
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
class ContributionGraph extends StatefulWidget {
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
  State<ContributionGraph> createState() => _ContributionGraphState();
}

class _ContributionGraphState extends State<ContributionGraph> {
  ContributionDay? _selectedDay;

  void _onCellTap(ContributionDay day) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedDay = _selectedDay == day ? null : day;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data == null) {
      return _buildEmptyGraph();
    }

    final weeks = widget.data!.getLastWeeks(widget.weeksToShow);
    
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
          if (widget.showMonthLabels) ...[
            _buildMonthLabels(weeks),
            const SizedBox(height: 4),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.showDayLabels) ...[
                _buildDayLabels(),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: _buildGrid(weeks),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Show selected day details
          _buildSelectedDayInfo(),
          const SizedBox(height: 8),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildSelectedDayInfo() {
    if (_selectedDay == null) {
      return const SizedBox(
        height: 20,
        child: Center(
          child: Text(
            'Tap a cell to see details',
            style: TextStyle(
              color: GitHubColors.text,
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    final count = _selectedDay!.contributionCount;
    final date = _selectedDay!.date;
    final formattedDate = _formatDate(date);
    final contributionText = count == 1 ? 'contribution' : 'contributions';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF21262d),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: GitHubColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: GitHubColors.getColorForLevel(_selectedDay!.contributionLevel),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$count $contributionText on $formattedDate',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
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
          if (widget.showDayLabels) SizedBox(width: 28),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final totalWidth = constraints.maxWidth;
                final weekWidth = widget.cellSize + widget.cellSpacing;
                
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
        SizedBox(height: widget.cellSize + widget.cellSpacing), // Mon (skip)
        _buildDayLabel(''), // Tue
        SizedBox(height: widget.cellSize + widget.cellSpacing),
        _buildDayLabel('Wed'),
        SizedBox(height: widget.cellSize + widget.cellSpacing),
        _buildDayLabel(''), // Thu
        SizedBox(height: widget.cellSize + widget.cellSpacing),
        _buildDayLabel('Fri'),
        SizedBox(height: widget.cellSize + widget.cellSpacing),
        _buildDayLabel(''), // Sat
      ],
    );
  }

  Widget _buildDayLabel(String label) {
    return SizedBox(
      height: widget.cellSize,
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
    // GitHub layout: Sunday at top (index 0), Saturday at bottom (index 6)
    final days = List<ContributionDay?>.filled(7, null);
    for (final day in week.days) {
      // Convert weekday: Sunday=0, Monday=1, ..., Saturday=6
      final weekday = day.date.weekday % 7; // Sunday=7%7=0, Monday=1, ..., Saturday=6
      if (weekday >= 0 && weekday < 7) {
        days[weekday] = day;
      }
    }

    return Padding(
      padding: EdgeInsets.only(right: widget.cellSpacing),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: days.map((day) => _buildCell(day)).toList(),
      ),
    );
  }

  Widget _buildCell(ContributionDay? day) {
    // Don't show future days - make them transparent/invisible
    if (day == null) {
      return Padding(
        padding: EdgeInsets.only(bottom: widget.cellSpacing),
        child: SizedBox(width: widget.cellSize, height: widget.cellSize),
      );
    }
    
    // Check if this day is in the future
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dayDate = DateTime(day.date.year, day.date.month, day.date.day);
    
    if (dayDate.isAfter(today)) {
      // Future day - show empty/transparent
      return Padding(
        padding: EdgeInsets.only(bottom: widget.cellSpacing),
        child: SizedBox(width: widget.cellSize, height: widget.cellSize),
      );
    }
    
    final level = day.contributionLevel;
    final color = GitHubColors.getColorForLevel(level);
    final isSelected = _selectedDay == day;

    return Padding(
      padding: EdgeInsets.only(bottom: widget.cellSpacing),
      child: GestureDetector(
        onTap: () => _onCellTap(day),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: widget.cellSize,
          height: widget.cellSize,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: isSelected
                ? Border.all(color: Colors.white, width: 1.5)
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.6),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
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
              width: widget.cellSize,
              height: widget.cellSize,
              decoration: BoxDecoration(
                color: GitHubColors.getColorForLevel(index),
                borderRadius: BorderRadius.circular(widget.borderRadius),
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
    // Ensure we have 7 days - GitHub layout: Sunday at top, Saturday at bottom
    final paddedLevels = List<int>.filled(7, 0);
    for (int i = 0; i < levels.length && i < 7; i++) {
      // Reorder: input is Mon-Sun (0-6), output should be Sun-Sat (0-6)
      // So we shift: Sunday (index 6 in input) goes to index 0
      final newIndex = (i + 1) % 7; // Mon(0)->1, Tue(1)->2, ..., Sat(5)->6, Sun(6)->0
      paddedLevels[newIndex] = levels[i];
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