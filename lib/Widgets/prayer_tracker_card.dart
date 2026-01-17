import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Haptic
import 'package:google_fonts/google_fonts.dart';
import 'package:molvi/Services/prayer_tracker_service.dart';
import 'package:molvi/Models/prayer_log.dart'; // Make sure this imports your NEW model (not the old Hive one)

class PrayerTrackerCard extends StatefulWidget {
  const PrayerTrackerCard({super.key});

  @override
  State<PrayerTrackerCard> createState() => _PrayerTrackerCardState();
}

class _PrayerTrackerCardState extends State<PrayerTrackerCard> {
  final _tracker = PrayerTrackerService();

  // Make this nullable (?) so we don't need 'late' and can check if it exists
  PrayerLog? _todayLog;
  int _streak = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // 1. Fetch data from Service
    PrayerLog log = await _tracker.getTodayLog();
    int streak = await _tracker.calculateStreak();

    // 2. Update UI safely
    if (mounted) {
      setState(() {
        _todayLog = log;
        _streak = streak;
        _isLoading = false;
      });
    }
  }

  Future<void> _togglePrayer(String prayer) async {
    HapticFeedback.mediumImpact(); // Satisfying vibration
    await _tracker.togglePrayer(prayer);
    await _loadData(); // Reload to get the updated status and potentially updated streak
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Loading State: Show a nice skeleton or loader
    if (_isLoading || _todayLog == null) {
      return Container(
        height: 160,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      // margin: const EdgeInsets.symmetric(horizontal: 20), // Added margin for better spacing
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white10
              : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // HEADER: Title + Streak
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Daily Prayers",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Text("🔥", style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      "$_streak Day Streak",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[800],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),

          const SizedBox(height: 20),

          // PRAYER BUTTONS ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // We use ! here safely because we checked for null at the top of build()
              _buildPrayerItem("Fajr", _todayLog!.fajr),
              _buildPrayerItem("Dhuhr", _todayLog!.dhuhr),
              _buildPrayerItem("Asr", _todayLog!.asr),
              _buildPrayerItem("Maghrib", _todayLog!.maghrib),
              _buildPrayerItem("Isha", _todayLog!.isha),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerItem(String name, bool isCompleted) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => _togglePrayer(name),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: isCompleted
                  ? colorScheme.primary
                  : colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
              boxShadow: isCompleted
                  ? [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : [],
            ),
            child: isCompleted
                ? Icon(Icons.check_rounded,
                    color: colorScheme.onPrimary, size: 28)
                : Icon(Icons.circle_outlined,
                    color: colorScheme.outline, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: isCompleted ? FontWeight.w600 : FontWeight.w400,
              color: isCompleted
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
