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
}