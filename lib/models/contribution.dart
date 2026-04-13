/// Represents a single day's contribution data
class ContributionDay {
  final DateTime date;
  final int contributionCount;
  final int contributionLevel; // 0-4 representing intensity

  ContributionDay({
    required this.date,
    required this.contributionCount,
    required this.contributionLevel,
  });

  factory ContributionDay.fromJson(Map<String, dynamic> json) {
    return ContributionDay(
      date: DateTime.parse(json['date'] as String),
      contributionCount: json['contributionCount'] as int,
      contributionLevel: _parseContributionLevel(json['contributionLevel'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'contributionCount': contributionCount,
      'contributionLevel': _levelToString(contributionLevel),
    };
  }

  static int _parseContributionLevel(String level) {
    switch (level) {
      case 'NONE':
        return 0;
      case 'FIRST_QUARTILE':
        return 1;
      case 'SECOND_QUARTILE':
        return 2;
      case 'THIRD_QUARTILE':
        return 3;
      case 'FOURTH_QUARTILE':
        return 4;
      default:
        return 0;
    }
  }

  static String _levelToString(int level) {
    switch (level) {
      case 0:
        return 'NONE';
      case 1:
        return 'FIRST_QUARTILE';
      case 2:
        return 'SECOND_QUARTILE';
      case 3:
        return 'THIRD_QUARTILE';
      case 4:
        return 'FOURTH_QUARTILE';
      default:
        return 'NONE';
    }
  }
}

/// Represents a week of contributions
class ContributionWeek {
  final List<ContributionDay> days;

  ContributionWeek({required this.days});

  factory ContributionWeek.fromJson(Map<String, dynamic> json) {
    final contributionDays = (json['contributionDays'] as List)
        .map((day) => ContributionDay.fromJson(day as Map<String, dynamic>))
        .toList();
    return ContributionWeek(days: contributionDays);
  }

  Map<String, dynamic> toJson() {
    return {
      'contributionDays': days.map((day) => day.toJson()).toList(),
    };
  }
}

/// Represents the full contribution calendar data
class ContributionData {
  final List<ContributionWeek> weeks;
  final int totalContributions;
  final DateTime fetchedAt;

  ContributionData({
    required this.weeks,
    required this.totalContributions,
    DateTime? fetchedAt,
  }) : fetchedAt = fetchedAt ?? DateTime.now();

  factory ContributionData.fromJson(Map<String, dynamic> json) {
    final weeks = (json['weeks'] as List)
        .map((week) => ContributionWeek.fromJson(week as Map<String, dynamic>))
        .toList();
    return ContributionData(
      weeks: weeks,
      totalContributions: json['totalContributions'] as int,
      fetchedAt: json['fetchedAt'] != null 
          ? DateTime.parse(json['fetchedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weeks': weeks.map((week) => week.toJson()).toList(),
      'totalContributions': totalContributions,
      'fetchedAt': fetchedAt.toIso8601String(),
    };
  }

  /// Get all contribution days as a flat list
  List<ContributionDay> get allDays {
    return weeks.expand((week) => week.days).toList();
  }

  /// Get the last N weeks of contributions
  List<ContributionWeek> getLastWeeks(int count) {
    if (weeks.length <= count) return weeks;
    return weeks.sublist(weeks.length - count);
  }

  /// Calculate the current contribution streak (consecutive days with contributions)
  int get currentStreak {
    final days = allDays;
    if (days.isEmpty) return 0;

    // Sort days by date descending (most recent first)
    final sortedDays = List<ContributionDay>.from(days)
      ..sort((a, b) => b.date.compareTo(a.date));

    // Get today's date (without time)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int streak = 0;
    DateTime? expectedDate = today;

    for (final day in sortedDays) {
      final dayDate = DateTime(day.date.year, day.date.month, day.date.day);

      // Skip future days
      if (dayDate.isAfter(today)) continue;

      // If this is the expected date (or we're starting and it's today/yesterday)
      if (expectedDate != null) {
        final difference = expectedDate.difference(dayDate).inDays;

        if (difference == 0) {
          // This is the expected date
          if (day.contributionCount > 0) {
            streak++;
            expectedDate = dayDate.subtract(const Duration(days: 1));
          } else {
            // No contribution on expected date, streak ends
            // But if it's today with 0 contributions, check yesterday
            if (dayDate == today && streak == 0) {
              expectedDate = today.subtract(const Duration(days: 1));
              continue;
            }
            break;
          }
        } else if (difference == 1 && streak == 0) {
          // We're at the start and today has no data yet, check yesterday
          if (day.contributionCount > 0) {
            streak++;
            expectedDate = dayDate.subtract(const Duration(days: 1));
          } else {
            break;
          }
        } else if (difference > 1) {
          // Gap in dates, streak ends
          break;
        }
      }
    }

    return streak;
  }
}
