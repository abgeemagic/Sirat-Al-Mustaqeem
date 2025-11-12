import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class Ayah {
  final int number;
  final String text;
  final String? translation;
  final int surahNumber;
  final String surahName;
  final int ayahNumber;
  Ayah({
    required this.number,
    required this.text,
    this.translation,
    required this.surahNumber,
    required this.surahName,
    required this.ayahNumber,
  });
}

Future<Ayah?> getRandomVerse() async {
  final random = Random();
  final randomAyahNumber = random.nextInt(6236) + 1; // Total ayahs in Quran

  final arabicUrl =
      Uri.parse("http://api.alquran.cloud/v1/ayah/$randomAyahNumber");
  final translationUrl =
      Uri.parse("http://api.alquran.cloud/v1/ayah/$randomAyahNumber/en.asad");

  try {
    var arabicRes = await http.get(arabicUrl);
    var translationRes = await http.get(translationUrl);

    if (arabicRes.statusCode != 200) {
      print('Failed to load Arabic Quran: ${arabicRes.statusCode}');
      return null;
    }
    if (translationRes.statusCode != 200) {
      print('Failed to load English translation: ${translationRes.statusCode}');
      return null;
    }

    final arabicBody = utf8.decode(arabicRes.bodyBytes);
    final translationBody = utf8.decode(translationRes.bodyBytes);

    final arabicJson = jsonDecode(arabicBody);
    final translationJson = jsonDecode(translationBody);

    // Access the ayah data directly from the API response
    final arabicAyah = arabicJson['data'];
    final translationAyah = translationJson['data'];

    return Ayah(
      number: arabicAyah['number'],
      text: arabicAyah['text'],
      translation: translationAyah['text'],
      surahNumber: arabicAyah['surah']['number'],
      surahName: arabicAyah['surah']['englishName'],
      ayahNumber: arabicAyah['numberInSurah'],
    );
  } catch (e) {
    print('Error fetching random verse: $e');
    return null;
  }
}

Future<void> getQuran(Function(List<String>) updatequran) async {
  final url = Uri.parse("http://api.alquran.cloud/v1/quran/ar.alafasy");
  try {
    var res = await http.get(url);
    if (res.statusCode == 200) {
      final body = utf8.decode(res.bodyBytes);
      final json = jsonDecode(body);
      List<String> quranText = [];
      for (var surah in json['data']['surahs']) {
        for (var ayah in surah['ayahs']) {
          quranText.add(ayah['text']);
        }
      }
      updatequran(quranText);
    } else {
      print('Failed to load Quran: ${res.statusCode}');
    }
  } catch (e) {
    print('Error occurred: $e');
  }
}
