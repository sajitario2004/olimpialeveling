import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../models/player.dart';
import '../../models/daily_quest.dart';
import '../../models/muscle.dart';

class ServerSyncService {
  static const String defaultBaseUrl = 'http://127.0.0.1:8000';
  String baseUrl;

  ServerSyncService({this.baseUrl = defaultBaseUrl});

  Future<bool> checkServerOnline() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/health')).timeout(const Duration(seconds: 2));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>?> fetchIntervals() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/intervals')).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final List list = jsonDecode(utf8.decode(response.bodyBytes));
        return list.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      debugPrint('SyncService: Offline or could not fetch intervals: $e');
    }
    return null;
  }

  Future<List<DailyQuest>?> generateDailyQuestsForLevel(int totalLevel, String date) async {
    final intervals = await fetchIntervals();
    if (intervals != null && intervals.isNotEmpty) {
      // Find matching interval
      Map<String, dynamic>? matched;
      for (var interval in intervals) {
        final minL = interval['min_level'] as int;
        final maxL = interval['max_level'] as int;
        if (totalLevel >= minL && totalLevel <= maxL) {
          matched = interval;
          break;
        }
      }
      matched ??= intervals.first;

      final questsRaw = matched['quests'] as List;
      final quests = <DailyQuest>[];
      for (int i = 0; i < questsRaw.length; i++) {
        final q = questsRaw[i];
        quests.add(DailyQuest(
          id: 'quest_${date}_$i',
          name: q['name'],
          target: (q['target'] as num).toDouble(),
          current: 0.0,
          unit: q['unit'],
          date: date,
        ));
      }
      return quests;
    }

    // Default fallback if server is not running
    if (totalLevel >= 5 && totalLevel <= 20) {
      return [
        DailyQuest(id: 'quest_${date}_0', name: 'Flexiones', target: 20.0, unit: 'reps', date: date),
        DailyQuest(id: 'quest_${date}_1', name: 'Recorrido a pie o corriendo', target: 5.0, unit: 'km', date: date),
      ];
    } else if (totalLevel < 5) {
      return [
        DailyQuest(id: 'quest_${date}_0', name: 'Flexiones', target: 10.0, unit: 'reps', date: date),
        DailyQuest(id: 'quest_${date}_1', name: 'Caminata', target: 2.0, unit: 'km', date: date),
      ];
    } else {
      return [
        DailyQuest(id: 'quest_${date}_0', name: 'Flexiones estrictas', target: 40.0, unit: 'reps', date: date),
        DailyQuest(id: 'quest_${date}_1', name: 'Sentadillas libres', target: 50.0, unit: 'reps', date: date),
        DailyQuest(id: 'quest_${date}_2', name: 'Carrera continua', target: 6.0, unit: 'km', date: date),
      ];
    }
  }

  Future<void> syncPlayerState(Player player, {List<Muscle> muscles = const []}) async {
    try {
      final musclesMap = {
        for (var m in muscles)
          m.id: {
            'name': m.name,
            'level': m.level,
            'current_xp': m.currentXp,
            'category': m.category,
          }
      };

      await http.post(
        Uri.parse('$baseUrl/api/player/sync'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'player_id': player.id,
          'total_level': player.totalLevel,
          'rank': player.rank.id,
          'muscles': musclesMap,
          'completed_daily_date': player.completedDailyDate,
          'last_sync_date': DateTime.now().toIso8601String(),
        }),
      ).timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('SyncService: Sincronización en segundo plano no disponible: $e');
    }
  }
}
