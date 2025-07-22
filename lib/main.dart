import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:async';
import 'dart:math';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  // Configure window to be frameless and transparent
  await windowManager.ensureInitialized();
  await windowManager.setAsFrameless();
  await windowManager.setResizable(true);
  
  WindowOptions windowOptions = WindowOptions(
    size: Size(310, 310),
    center: false,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
    windowButtonVisibility: false,
    alwaysOnTop: true,
    maximumSize: Size(310, 310),
    minimumSize: Size(271, 271),
  );
  
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    await windowManager.setBackgroundColor(Colors.transparent);
  });
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Analog Digital Clock',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.transparent,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.transparent,
      ),
      themeMode: ThemeMode.system,
      home: ClockApp(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ClockApp extends StatefulWidget {
  @override
  _ClockAppState createState() => _ClockAppState();
}

class _ClockAppState extends State<ClockApp> {
  late Timer _timer;
  DateTime _currentTime = DateTime.now();
  bool _isDarkMode = true; // Default to dark mode

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: GestureDetector(
          onPanStart: (details) {
            windowManager.startDragging();
          },
          child: Center(
            child: Container(
              width: 256,
              height: 256,
              child: Stack(
                children: [
                  // Main clock widget
                  Center(child: AnalogDigitalClock(currentTime: _currentTime)),
                  // Theme toggle button
                  Positioned(
                    top: 10,
                    right: 10,
                    child: IconButton(
                      onPressed: _toggleTheme,
                      icon: Icon(
                        _isDarkMode ? Icons.light_mode : Icons.dark_mode,
                        color: _isDarkMode ? Colors.white : Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AnalogDigitalClock extends StatelessWidget {
  final DateTime currentTime;

  const AnalogDigitalClock({Key? key, required this.currentTime}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.grey[900]!.withOpacity(0.2) : Colors.grey[100]!.withOpacity(0.2);
    final borderColor = isDarkMode ? Colors.white : Colors.black;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final accentColor = isDarkMode ? Colors.blue[300] : Colors.blue[700];

    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
        border: Border.all(color: borderColor!, width: 3),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black54 : Colors.grey.withOpacity(0.3),
            spreadRadius: 5,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: CustomPaint(
        painter: TimeRangePainter(),
        child: Stack(
          children: [
            // Hour markers (12, 3, 6, 9) - positioned manually to respect gravity
            // 12 at top
            Positioned(
              top: 10,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  '12',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ),
            // 3 at right
            Positioned(
              top: 0,
              bottom: 0,
              right: 10,
              child: Center(
                child: Text(
                  '3',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ),
            // 6 at bottom (respecting gravity!)
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  '6',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ),
            // 9 at left (also respecting gravity!)
            Positioned(
              top: 0,
              bottom: 0,
              left: 10,
              child: Center(
                child: Text(
                  '9',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ),
            
            // Clock hands
            // Hour hand
            Center(
              child: Transform.rotate(
                angle: (currentTime.hour % 12 + currentTime.minute / 60) * 30 * pi / 180,
                child: Container(
                  width: 3,
                  height: 50,
                  decoration: BoxDecoration(
                    color: textColor,
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                  margin: EdgeInsets.only(bottom: 50),
                ),
              ),
            ),
            
            // Minute hand
            Center(
              child: Transform.rotate(
                angle: (currentTime.minute + currentTime.second / 60) * 6 * pi / 180,
                child: Container(
                  width: 2,
                  height: 70,
                  decoration: BoxDecoration(
                    color: textColor,
                    borderRadius: BorderRadius.circular(1),
                  ),
                  margin: EdgeInsets.only(bottom: 70),
                ),
              ),
            ),
            
            // Second hand
            Center(
              child: Transform.rotate(
                angle: currentTime.second * 6 * pi / 180,
                child: Container(
                  width: 1,
                  height: 80,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(0.5),
                  ),
                  margin: EdgeInsets.only(bottom: 80),
                ),
              ),
            ),

            // Center dot
            Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: borderColor,
                  border: Border.all(color: backgroundColor, width: 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TimeRangePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4; // Slightly inside the border for smaller clock
    
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    // Helper function to convert hour to angle (in radians)
    double hourToAngle(double hour) {
      // 12 o'clock is at -π/2, each hour is π/6 radians
      return -pi/2 + (hour * pi / 6);
    }

    // Dark green arc: 08:00 to 11:30
    paint.color = Colors.green[800]!;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      hourToAngle(8.0),
      hourToAngle(11.5) - hourToAngle(8.0),
      false,
      paint,
    );

    // Yellow arc: 11:30 to 13:00
    paint.color = Colors.yellow[600]!;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      hourToAngle(11.5),
      hourToAngle(13.0) - hourToAngle(11.5),
      false,
      paint,
    );

    // Green arc: 13:00 to 18:00
    paint.color = Colors.green[600]!;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      hourToAngle(13.0),
      hourToAngle(18.0) - hourToAngle(13.0),
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}