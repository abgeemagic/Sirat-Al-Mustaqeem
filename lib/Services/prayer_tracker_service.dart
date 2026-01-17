import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:molvi/Models/prayer_log.dart';

class PrayerTrackerService {
  // Helper to get today's date key (e.g. "2025-01-17")
  String get _today => DateFormat('yyyy-MM-dd').format(DateTime.now());

  // LOAD TODAY'S LOG
  Future<PrayerLog> getTodayLog() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('prayer_$_today');

    if (data != null) {
      return PrayerLog.fromJson(data);
    } else {
      // Create fresh log for today
      return PrayerLog(date: _today);
    }
  }

  // TOGGLE A PRAYER & SAVE
  Future<PrayerLog> togglePrayer(String prayerName) async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Get current state
    PrayerLog log = await getTodayLog();

    // 2. Update the specific prayer
    switch (prayerName) {
      case 'Fajr':
        log.fajr = !log.fajr;
        break;
      case 'Dhuhr':
        log.dhuhr = !log.dhuhr;
        break;
      case 'Asr':
        log.asr = !log.asr;
        break;
      case 'Maghrib':
        log.maghrib = !log.maghrib;
        break;
      case 'Isha':
        log.isha = !log.isha;
        break;
    }

    // 3. Save back to storage
    await prefs.setString('prayer_$_today', log.toJson());
    return log;
  }

  // CALCULATE STREAK
  Future<int> calculateStreak() async {
    final prefs = await SharedPreferences.getInstance();
    int streak = 0;

    // Start checking from yesterday
    DateTime checkDate = DateTime.now().subtract(const Duration(days: 1));

    while (true) {
      String dateKey = DateFormat('yyyy-MM-dd').format(checkDate);
      String? data = prefs.getString('prayer_$dateKey');

      if (data != null) {
        PrayerLog log = PrayerLog.fromJson(data);
        if (_isDayComplete(log)) {
          streak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else {
          break; // Streak broken
        }
      } else {
        break; // No data for this day
      }
    }
    return streak;
  }

  bool _isDayComplete(PrayerLog log) {
    return log.fajr && log.dhuhr && log.asr && log.maghrib && log.isha;
  }
}
