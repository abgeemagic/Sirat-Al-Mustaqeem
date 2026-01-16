import 'dart:async';
import 'dart:ui'; // REQUIRED for FontFeature
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:molvi/Features/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SalahPage extends StatefulWidget {
  const SalahPage({super.key});

  @override
  State<SalahPage> createState() => _SalahPageState();
}

class _SalahPageState extends State<SalahPage> {
  Position? currentPosition;
  PrayerTimes? prayerTimes;
  bool isLoading = true;
  String? error;
  Timer? _timer;
  DateTime currentTime = DateTime.now();
  String nextPrayer = '';
  Duration timeToNextPrayer = Duration.zero;

  final List<Map<String, dynamic>> prayerData = [
    {'name': 'Fajr', 'arabicName': 'فجر', 'icon': Icons.wb_twilight_rounded},
    {'name': 'Sunrise', 'arabicName': 'شروق', 'icon': Icons.wb_sunny_outlined},
    {'name': 'Dhuhr', 'arabicName': 'ظهر', 'icon': Icons.wb_sunny_rounded},
    {'name': 'Asr', 'arabicName': 'عصر', 'icon': Icons.wb_cloudy_rounded},
    {
      'name': 'Maghrib',
      'arabicName': 'مغرب',
      'icon': Icons.wb_twilight_rounded
    },
    {'name': 'Isha', 'arabicName': 'عشاء', 'icon': Icons.nightlight_round},
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          currentTime = DateTime.now();
          _calculateNextPrayer();
        });
      }
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      if (mounted)
        setState(() {
          isLoading = true;
          error = null;
        });

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted)
          setState(() {
            error = 'Location services are disabled.';
            isLoading = false;
          });
        return;
      }

      PermissionStatus permission = await Permission.location.request();
      if (permission.isDenied) {
        if (mounted)
          setState(() {
            error = 'Location permission denied.';
            isLoading = false;
          });
        return;
      }
      if (permission.isPermanentlyDenied) {
        if (mounted) {
          setState(() {
            error = 'Location permissions permanently denied.';
            isLoading = false;
          });
          _showPermissionDialog();
        }
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );

      if (mounted) setState(() => currentPosition = position);
      await _calculatePrayerTimes();
    } catch (e) {
      if (mounted)
        setState(() {
          error = 'Error getting location: $e';
          isLoading = false;
        });
    }
  }

  Future<void> _testNotification() async {
    // Check permission
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    // Schedule for 10 seconds later
    final now = DateTime.now();
    final testTime = now.add(const Duration(seconds: 10));

    await NotificationService.schedulePrayer(
      999, // Unique ID for testing
      'Test Prayer',
      testTime,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Test notification scheduled in 10 seconds! Minimize the app.')),
      );
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permission Required'),
          content: const Text(
              'Please enable location permission in app settings to calculate prayer times.'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Open Settings'),
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _calculatePrayerTimes() async {
    if (currentPosition == null) return;
    try {
      final coordinates =
          Coordinates(currentPosition!.latitude, currentPosition!.longitude);
      final params = CalculationMethod.muslim_world_league.getParameters();
      params.madhab = Madhab.hanafi;

      final prayers = PrayerTimes.today(coordinates, params);

      if (mounted) {
        setState(() {
          prayerTimes = prayers;
          isLoading = false;
        });
        _calculateNextPrayer();
        _schedulePrayerNotifications(prayers);
      }
    } catch (e) {
      if (mounted)
        setState(() {
          error = 'Error: $e';
          isLoading = false;
        });
    }
  }

  Future<void> _schedulePrayerNotifications(PrayerTimes times) async {
    final prefs = await SharedPreferences.getInstance();
    final bool enabled = prefs.getBool('notifications_enabled') ?? false;

    if (!enabled) return;

    await NotificationService.cancelAllNotifications();

    await NotificationService.schedulePrayer(1, 'Fajr', times.fajr);
    await NotificationService.schedulePrayer(2, 'Dhuhr', times.dhuhr);
    await NotificationService.schedulePrayer(3, 'Asr', times.asr);
    await NotificationService.schedulePrayer(4, 'Maghrib', times.maghrib);
    await NotificationService.schedulePrayer(5, 'Isha', times.isha);
  }

  void _calculateNextPrayer() {
    if (prayerTimes == null) return;
    final now = DateTime.now();
    final prayers = [
      {'name': 'Fajr', 'time': prayerTimes!.fajr},
      {'name': 'Sunrise', 'time': prayerTimes!.sunrise},
      {'name': 'Dhuhr', 'time': prayerTimes!.dhuhr},
      {'name': 'Asr', 'time': prayerTimes!.asr},
      {'name': 'Maghrib', 'time': prayerTimes!.maghrib},
      {'name': 'Isha', 'time': prayerTimes!.isha},
    ];

    bool foundNext = false;
    for (int i = 0; i < prayers.length; i++) {
      final prayerTime = prayers[i]['time'] as DateTime;
      if (prayerTime.isAfter(now)) {
        nextPrayer = prayers[i]['name'] as String;
        timeToNextPrayer = prayerTime.difference(now);
        foundNext = true;
        break;
      }
    }

    if (!foundNext && currentPosition != null) {
      final tomorrowCoordinates =
          Coordinates(currentPosition!.latitude, currentPosition!.longitude);
      final params = CalculationMethod.muslim_world_league.getParameters();
      params.madhab = Madhab.hanafi;

      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final dateComponents =
          DateComponents(tomorrow.year, tomorrow.month, tomorrow.day);

      final tomorrowPrayers =
          PrayerTimes(tomorrowCoordinates, dateComponents, params);

      nextPrayer = 'Fajr';
      timeToNextPrayer = tomorrowPrayers.fajr.difference(now);
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    if (duration.isNegative) duration = Duration.zero;

    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Prayer Timings',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active, color: Colors.orange),
            onPressed: _testNotification,
          ),
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: colorScheme.primary),
            onPressed: _getCurrentLocation,
          )
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_off_rounded,
                            size: 64, color: colorScheme.error),
                        const SizedBox(height: 16),
                        Text(
                          error!,
                          textAlign: TextAlign.center,
                          style:
                              GoogleFonts.inter(color: colorScheme.onSurface),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _getCurrentLocation,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primaryContainer,
                            foregroundColor: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : prayerTimes == null
                  ? const Center(child: Text('Calculating...'))
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // --- NEXT PRAYER CARD ---
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  colorScheme.primary,
                                  colorScheme.primary.withOpacity(0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary.withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Next Prayer',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color:
                                        colorScheme.onPrimary.withOpacity(0.9),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  nextPrayer,
                                  style: GoogleFonts.inter(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.timer_outlined,
                                          color: colorScheme.onPrimary,
                                          size: 18),
                                      const SizedBox(width: 8),
                                      Text(
                                        '- ${_formatDuration(timeToNextPrayer)}',
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: colorScheme.onPrimary,
                                          fontFeatures: [
                                            const FontFeature.tabularFigures()
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // --- PRAYER LIST ---
                          Text(
                            "Today's Schedule",
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 16),

                          ...prayerData.map((prayer) {
                            DateTime? time;
                            switch (prayer['name']) {
                              case 'Fajr':
                                time = prayerTimes!.fajr;
                                break;
                              case 'Sunrise':
                                time = prayerTimes!.sunrise;
                                break;
                              case 'Dhuhr':
                                time = prayerTimes!.dhuhr;
                                break;
                              case 'Asr':
                                time = prayerTimes!.asr;
                                break;
                              case 'Maghrib':
                                time = prayerTimes!.maghrib;
                                break;
                              case 'Isha':
                                time = prayerTimes!.isha;
                                break;
                            }

                            final isNext = prayer['name'] == nextPrayer;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: isNext
                                    ? colorScheme.primaryContainer
                                    : colorScheme.surfaceContainer,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isNext
                                      ? colorScheme.primary
                                      : (isDark
                                          ? Colors.white10
                                          : Colors.black.withOpacity(0.05)),
                                  width: isNext ? 1.5 : 1,
                                ),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 4),
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isNext
                                        ? colorScheme.primary
                                        : colorScheme.surface,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    prayer['icon'],
                                    color: isNext
                                        ? colorScheme.onPrimary
                                        : colorScheme.primary,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  prayer['name'],
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                subtitle: Text(
                                  prayer['arabicName'],
                                  style: GoogleFonts.amiri(
                                    fontSize: 14,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                trailing: Text(
                                  DateFormat.jm().format(time!),
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: isNext
                                        ? colorScheme.primary
                                        : colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
    );
  }
}
