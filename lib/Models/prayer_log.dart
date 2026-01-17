import 'dart:convert';

class PrayerLog {
  String date;
  bool fajr;
  bool dhuhr;
  bool asr;
  bool maghrib;
  bool isha;

  PrayerLog({
    required this.date,
    this.fajr = false,
    this.dhuhr = false,
    this.asr = false,
    this.maghrib = false,
    this.isha = false,
  });

  // Convert to JSON (Text) to save
  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'fajr': fajr,
      'dhuhr': dhuhr,
      'asr': asr,
      'maghrib': maghrib,
      'isha': isha,
    };
  }

  // Create from JSON (Text) when loading
  factory PrayerLog.fromMap(Map<String, dynamic> map) {
    return PrayerLog(
      date: map['date'],
      fajr: map['fajr'] ?? false,
      dhuhr: map['dhuhr'] ?? false,
      asr: map['asr'] ?? false,
      maghrib: map['maghrib'] ?? false,
      isha: map['isha'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory PrayerLog.fromJson(String source) =>
      PrayerLog.fromMap(json.decode(source));
}
