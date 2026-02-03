import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

class StrokeSplashScreen extends StatefulWidget {
  const StrokeSplashScreen({Key? key}) : super(key: key);

  @override
  State<StrokeSplashScreen> createState() => _StrokeSplashScreenState();
}

class _StrokeSplashScreenState extends State<StrokeSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final String _svgPathData = '''
      M52.2 117.1 
c-7 -1.8 -10.2 -7.5 -10.2 -18.3 
0 -9.8 -1 -10.8 -11.1 -10.8 
-8.3 0 -12.9 -1.8 -16.4 -6.4 
-1.8 -2.5 -2 -4.2 -2 -17.1 
0 -12.9 0.2 -14.6 2 -17.1 
3 -3.9 8.2 -6.4 13.7 -6.4 
l4.8 0 0 3.5 
c0 3.5 -0.1 3.5 -4.3 3.5 
-2.3 0 -5.3 0.7 -6.5 1.6 
-2.1 1.4 -2.2 2.2 -2.2 14.9 
0 16.3 0.1 16.5 12.3 16.5 
13.1 0 16.7 3.6 16.7 16.7 
0 12.2 0.2 12.3 16.5 12.3 
17.4 0 16.5 1.2 16.5 -21 
0 -21.7 0.6 -21 -17.4 -21 
-20.9 0 -22 -1.3 -22.4 -27.5 
-0.3 -16.2 -0.1 -18.4 1.6 -21.5 
3.8 -6.9 5.6 -7.5 21.7 -7.5 
12.9 0 14.6 0.2 17.2 2.1 
4.5 3.3 6.3 7.9 6.3 16.5 
0 10 1 10.9 11.1 10.9 
8.3 0 12.9 1.8 16.4 6.4 
1.8 2.5 2 4.2 2 17.1 
0 12.9 -0.2 14.6 -2.1 17.2 
-2.8 3.9 -8 6.3 -13.6 6.3 
l-4.8 0 0 -3.5 
c0 -3.5 0.1 -3.5 4.3 -3.5 
2.3 0 5.3 -0.7 6.5 -1.6 
2.1 -1.4 2.2 -2.2 2.2 -14.9 
0 -16.3 -0.1 -16.5 -12.3 -16.5 
-13 0 -16.7 -3.8 -16.7 -17.2 
0 -11.6 -0.3 -11.8 -16.5 -11.8 
-17.7 0 -16.9 -1.1 -16.3 22.1 
0.3 15.4 0.5 17.2 2.3 18.5 
1.4 1 5.2 1.4 14.2 1.4 
21.5 0 23.3 2.2 23.3 28.6 
0 18.6 -0.8 21.8 -6.3 25.8 
-2.3 1.7 -4.5 2 -15 2.3 
-6.7 0.1 -13.7 -0.2 -15.5 -0.6
''';

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2700),
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomPaint(
              size: const Size(300, 300),
              painter: LogoPainter(
                animation: _animation,
                pathData: _svgPathData,
              ),
            ),
            const SizedBox(height: 15),
            FadeTransition(
              opacity: CurvedAnimation(
                parent: _animation,
                curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
              ),
              child: const Text(
                'Welcome to Vytal',
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  color: Colors.tealAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LogoPainter extends CustomPainter {
  final Animation<double> animation;
  final String pathData;

  LogoPainter({required this.animation, required this.pathData})
    : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final originalPath = parseSvgPathData(pathData);
    final paintStroke = Paint()
      ..color = Colors.white
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintFill = Paint()
      ..color = Colors.white.withOpacity(animation.value.clamp(0.0, 1.0))
      ..style = PaintingStyle.fill;

    final metrics = originalPath.computeMetrics().toList();
    final animatedPath = Path();

    for (final metric in metrics) {
      final extractLength = metric.length * animation.value;
      animatedPath.addPath(metric.extractPath(0, extractLength), Offset.zero);
    }

    canvas.translate(85, 0); // Position adjustment

    canvas.drawPath(animatedPath, paintStroke);

    if (animation.value > 0.98) {
      canvas.drawPath(originalPath, paintFill);
    }
  }

  @override
  bool shouldRepaint(covariant LogoPainter oldDelegate) => true;
}
