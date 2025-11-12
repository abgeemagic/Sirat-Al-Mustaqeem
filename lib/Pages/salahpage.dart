import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:molvi/Pages/settings.dart';

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
    {'name': 'Fajr', 'arabicName': 'فجر', 'icon': Icons.wb_twilight},
    {'name': 'Sunrise', 'arabicName': 'شروق', 'icon': Icons.wb_sunny_outlined},
    {'name': 'Dhuhr', 'arabicName': 'ظهر', 'icon': Icons.wb_sunny},
    {'name': 'Asr', 'arabicName': 'عصر', 'icon': Icons.wb_sunny_outlined},
    {'name': 'Maghrib', 'arabicName': 'مغرب', 'icon': Icons.wb_twilight},
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
      if (mounted) {
        setState(() {
          isLoading = true;
          error = null;
        });
      }
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            error =
                'Location services are disabled. Please enable location services in device settings.';
            isLoading = false;
          });
        }
        return;
      }
      PermissionStatus permission = await Permission.location.request();
      if (permission.isDenied) {
        if (mounted) {
          setState(() {
            error =
                'Location permission denied. Please grant location permission to get prayer times.';
            isLoading = false;
          });
        }
        return;
      }
      if (permission.isPermanentlyDenied) {
        if (mounted) {
          setState(() {
            error =
                'Location permissions are permanently denied. Please enable in app settings.';
            isLoading = false;
          });
          _showPermissionDialog();
        }
        return;
      }
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );
      if (mounted) {
        setState(() {
          currentPosition = position;
        });
      }
      await _calculatePrayerTimes();
    } catch (e) {
      if (mounted) {
        setState(() {
          error = 'Error getting location: ${e.toString()}';
          isLoading = false;
        });
      }
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Location Permission Required'),
          content: Text(
            'This app needs location permission to calculate accurate prayer times for your area. Please enable location permission in app settings.',
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Open Settings'),
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
      final coordinates = Coordinates(
        currentPosition!.latitude,
        currentPosition!.longitude,
      );
      final params = CalculationMethod.muslim_world_league.getParameters();
      params.madhab = Madhab.hanafi;
      final prayers = PrayerTimes.today(coordinates, params);
      if (mounted) {
        setState(() {
          prayerTimes = prayers;
          isLoading = false;
        });
      }
      _calculateNextPrayer();
    } catch (e) {
      if (mounted) {
        setState(() {
          error = 'Error calculating prayer times: $e';
          isLoading = false;
        });
      }
    }
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
    for (int i = 0; i < prayers.length; i++) {
      final prayerTime = prayers[i]['time'] as DateTime;
      if (prayerTime.isAfter(now)) {
        nextPrayer = prayers[i]['name'] as String;
        timeToNextPrayer = prayerTime.difference(now);
        return;
      }
    }
    final tomorrowCoordinates = Coordinates(
      currentPosition!.latitude,
      currentPosition!.longitude,
    );
    final tomorrowParams =
        CalculationMethod.muslim_world_league.getParameters();
    tomorrowParams.madhab = Madhab.hanafi;
    final tomorrowPrayers =
        PrayerTimes.today(tomorrowCoordinates, tomorrowParams);
    nextPrayer = 'Fajr';
    timeToNextPrayer = tomorrowPrayers.fajr.difference(now);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'أوقات الصلاة',
          style: GoogleFonts.amiriQuran(
            fontSize: FontSettings.arabicFontSize * 1.3,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text(error!, textAlign: TextAlign.center),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _getCurrentLocation,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : prayerTimes == null
                  ? Center(child: Text('No prayer times available'))
                  : ListView(
                      padding: EdgeInsets.all(16),
                      children: [
                        Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Text('Next Prayer: $nextPrayer'),
                                Text(
                                  'Time remaining: ${timeToNextPrayer.inHours + 24}h ${timeToNextPrayer.inMinutes % 60}m',
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
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
                          return Card(
                            child: ListTile(
                              leading: Icon(prayer['icon']),
                              title: Text(prayer['name']),
                              subtitle: Text(prayer['arabicName']),
                              trailing: Text(DateFormat.jm().format(time!)),
                            ),
                          );
                        }),
                      ],
                    ),
    );
  }
}
