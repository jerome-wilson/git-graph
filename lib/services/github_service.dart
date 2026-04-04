import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/contribution.dart';

class GitHubService {
  static const String _baseUrl = 'https://api.github.com/graphql';
  static const String _usernameKey = 'github_username';
  static const String _tokenKey = 'github_token';
  static const String _cachedDataKey = 'cached_contribution_data';

  /// GraphQL query to fetch contribution data
  static String _getContributionQuery(String username) => '''
    query {
      user(login: "$username") {
        contributionsCollection {
          contributionCalendar {
            totalContributions
            weeks {
              contributionDays {
                date
                contributionCount
                contributionLevel
              }
            }
          }
        }
      }
    }
  ''';

  /// Save GitHub credentials
  static Future<void> saveCredentials(String username, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, username);
    await prefs.setString(_tokenKey, token);
  }

  /// Get saved username
  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  /// Get saved token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Check if credentials are saved
  static Future<bool> hasCredentials() async {
    final username = await getUsername();
    final token = await getToken();
    return username != null && username.isNotEmpty && token != null && token.isNotEmpty;
  }

  /// Clear saved credentials
  static Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usernameKey);
    await prefs.remove(_tokenKey);
    await prefs.remove(_cachedDataKey);
  }

  /// Fetch contribution data from GitHub API
  static Future<ContributionData> fetchContributions({
    String? username,
    String? token,
  }) async {
    // Use provided credentials or fall back to saved ones
    final effectiveUsername = username ?? await getUsername();
    final effectiveToken = token ?? await getToken();

    if (effectiveUsername == null || effectiveUsername.isEmpty) {
      throw Exception('GitHub username is required');
    }

    if (effectiveToken == null || effectiveToken.isEmpty) {
      throw Exception('GitHub token is required');
    }

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $effectiveToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'query': _getContributionQuery(effectiveUsername),
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch contributions: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      // Check for GraphQL errors
      if (data.containsKey('errors')) {
        final errors = data['errors'] as List;
        throw Exception('GraphQL Error: ${errors.first['message']}');
      }

      // Parse the response
      final user = data['data']?['user'];
      if (user == null) {
        throw Exception('User not found: $effectiveUsername');
      }

      final calendar = user['contributionsCollection']['contributionCalendar'];
      final contributionData = ContributionData(
        totalContributions: calendar['totalContributions'] as int,
        weeks: (calendar['weeks'] as List).map((week) {
          return ContributionWeek(
            days: (week['contributionDays'] as List).map((day) {
              return ContributionDay(
                date: DateTime.parse(day['date'] as String),
                contributionCount: day['contributionCount'] as int,
                contributionLevel: _parseLevel(day['contributionLevel'] as String),
              );
            }).toList(),
          );
        }).toList(),
      );

      // Cache the data
      await _cacheData(contributionData);

      return contributionData;
    } catch (e) {
      // Try to return cached data if available
      final cachedData = await getCachedData();
      if (cachedData != null) {
        return cachedData;
      }
      rethrow;
    }
  }

  /// Parse contribution level string to int
  static int _parseLevel(String level) {
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

  /// Cache contribution data locally
  static Future<void> _cacheData(ContributionData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cachedDataKey, jsonEncode(data.toJson()));
  }

  /// Get cached contribution data
  static Future<ContributionData?> getCachedData() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedJson = prefs.getString(_cachedDataKey);
    if (cachedJson == null) return null;

    try {
      final data = jsonDecode(cachedJson) as Map<String, dynamic>;
      return ContributionData.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  /// Validate credentials by making a test API call
  static Future<bool> validateCredentials(String username, String token) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'query': '''
            query {
              user(login: "$username") {
                login
              }
            }
          ''',
        }),
      );

      if (response.statusCode != 200) return false;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['data']?['user'] != null;
    } catch (e) {
      return false;
    }
  }
}