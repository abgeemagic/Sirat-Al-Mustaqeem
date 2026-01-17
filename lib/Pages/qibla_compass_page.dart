import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For HapticFeedback
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:google_fonts/google_fonts.dart';

class QiblaCompassPage extends StatefulWidget {
  const QiblaCompassPage({super.key});

  @override
  State<QiblaCompassPage> createState() => _QiblaCompassPageState();
}

class _QiblaCompassPageState extends State<QiblaCompassPage>
    with SingleTickerProviderStateMixin {
  final _deviceSupport = FlutterQiblah.androidDeviceSensorSupport();
  bool _hasVibrated = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('Qibla Compass',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: _deviceSupport,
        builder: (_, AsyncSnapshot<bool?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error.toString()}"));
          }
          if (snapshot.data!) {
            return _buildCompassView(colorScheme);
          } else {
            return const Center(
                child: Text("Your device doesn't support Qibla sensors"));
          }
        },
      ),
    );
  }

  Widget _buildCompassView(ColorScheme colorScheme) {
    return StreamBuilder(
      // FIXED: Added 'h' to qiblahStream
      stream: FlutterQiblah.qiblahStream,
      builder: (_, AsyncSnapshot<QiblahDirection> snapshot) {
        // FIXED: Added 'h' to QiblahDirection
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final qiblahDirection = snapshot.data!;

        // Calculate difference for Haptics
        // qiblahDirection.direction is the heading (0-360)
        // qiblahDirection.offset is the Qibla angle relative to North

        // Use 'direction' (heading) and 'offset' (Qibla bearing)
        // Note: The package returns 'direction' (0 is North) and 'offset' (angle to Qibla from North)
        double diff =
            (qiblahDirection.direction - qiblahDirection.offset).abs();
        bool isAligned = diff < 2 || diff > 358;

        if (isAligned && !_hasVibrated) {
          HapticFeedback.mediumImpact();
          _hasVibrated = true;
        } else if (!isAligned) {
          _hasVibrated = false;
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Status Text
            Text(
              isAligned ? "You are facing the Qibla!" : "Rotate your phone",
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isAligned ? Colors.green : colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "${qiblahDirection.direction.toStringAsFixed(0)}°",
              style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.w300,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 50),

            // COMPASS STACK
            SizedBox(
              height: 300,
              width: 300,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 1. The Rotating Dial (Points North)
                  // Rotate negative direction to keep 'N' pointing North
                  Transform.rotate(
                    angle: (qiblahDirection.direction * (pi / 180) * -1),
                    child: _buildCompassDial(colorScheme, isAligned),
                  ),

                  // 2. The Qibla Needle
                  // Rotate relative to the dial to point to the Qibla offset
                  Transform.rotate(
                    angle: (qiblahDirection.direction * (pi / 180) * -1) +
                        (qiblahDirection.offset * (pi / 180)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_on,
                            size: 50,
                            color:
                                isAligned ? Colors.green : colorScheme.primary),
                        Container(
                          height: 100,
                          width: 4,
                          decoration: BoxDecoration(
                            color:
                                isAligned ? Colors.green : colorScheme.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 100), // Push needle up
                      ],
                    ),
                  ),

                  // 3. Center Pin
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                        color: colorScheme.onSurface,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10)
                        ]),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 50),

            // Footer Info
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mosque, size: 20, color: colorScheme.primary),
                  const SizedBox(width: 10),
                  Text(
                    "Qibla is at ${qiblahDirection.offset.toStringAsFixed(0)}°",
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            )
          ],
        );
      },
    );
  }

  Widget _buildCompassDial(ColorScheme colorScheme, bool isAligned) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: isAligned
                ? Colors.green.withOpacity(0.4)
                : Colors.black.withOpacity(0.1),
            blurRadius: 30,
            spreadRadius: 5,
          )
        ],
        border: Border.all(
          color:
              isAligned ? Colors.green : colorScheme.outline.withOpacity(0.2),
          width: 4,
        ),
      ),
      child: Stack(
        children: [
          // Cardinal Directions
          Align(
              alignment: Alignment.topCenter,
              child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text('N',
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 24)))),
          Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text('S',
                      style: TextStyle(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 24)))),
          Align(
              alignment: Alignment.centerRight,
              child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text('E',
                      style: TextStyle(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 24)))),
          Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text('W',
                      style: TextStyle(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 24)))),

          // Decorative Ring
          Center(
            child: SizedBox(
              width: 260,
              height: 260,
              child: CircularProgressIndicator(
                value: 1,
                strokeWidth: 2,
                color: colorScheme.outline.withOpacity(0.1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
