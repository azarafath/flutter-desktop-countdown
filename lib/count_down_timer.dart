import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

class CountDownTimer extends StatefulWidget {
  const CountDownTimer({Key? key}) : super(key: key);
  @override
  _CountDownTimerState createState() => _CountDownTimerState();
}

class _CountDownTimerState extends State<CountDownTimer>
    with TickerProviderStateMixin {
  late AnimationController controller;
  bool isStart = true;

  String get timerString {
    Duration duration = controller.duration! * controller.value;
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  late Timer _timer;
  int _start = 3;

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 180),
    );
  }

  void onStart() {
    startTimer();
    if (isStart) {
      Future.delayed(const Duration(seconds: 3), () {
        controller.reverse(
            from: controller.value == 0.0 ? 1.0 : controller.value);
        setState(() {
          isStart = false;
        });
      });
    } else {
      controller.reverse(
          from: controller.value == 0.0 ? 1.0 : controller.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white10,
      body: AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            return Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height:
                        controller.value * MediaQuery.of(context).size.height,
                    child: WaveWidget(
                      config: CustomConfig(
                        gradients: [
                          [Colors.blue, Color.fromARGB(237, 120, 54, 244)],
                          [Color.fromARGB(237, 120, 54, 244), Colors.blue],
                          [Colors.blue, Color.fromARGB(237, 120, 54, 244)],
                          [
                            Color.fromARGB(236, 54, 136, 244),
                            Color.fromARGB(255, 65, 33, 243)
                          ],
                        ],
                        durations: [35000, 19440, 10800, 6000],
                        heightPercentages: [0.001, 0.002, 0.003, 0.004],
                        blur: MaskFilter.blur(BlurStyle.solid, 5),
                        gradientBegin: Alignment.bottomLeft,
                        gradientEnd: Alignment.topRight,
                      ),
                      waveAmplitude: 0,
                      size: Size(
                        double.infinity,
                        double.infinity,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(60),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Align(
                            alignment: FractionalOffset.center,
                            child: AspectRatio(
                              aspectRatio: 1.0,
                              child: Stack(
                                children: <Widget>[
                                  Positioned.fill(
                                    child: CustomPaint(
                                        painter: CustomTimerPainter(
                                      animation: controller,
                                      backgroundColor: Colors.red,
                                      color: Colors.white,
                                    )),
                                  ),
                                  isStart
                                      ? Align(
                                          alignment: FractionalOffset.center,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                _start.toString(),
                                                style: const TextStyle(
                                                    fontSize: 112.0,
                                                    color: Colors.white),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Align(
                                          alignment: FractionalOffset.center,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              const Text(
                                                "Hitungan Mundur",
                                                style: TextStyle(
                                                    fontSize: 20.0,
                                                    color: Colors.white),
                                              ),
                                              Text(
                                                timerString,
                                                style: const TextStyle(
                                                    fontSize: 112.0,
                                                    color: Colors.white),
                                              ),
                                            ],
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 100),
                              child: AnimatedBuilder(
                                animation: controller,
                                builder: (context, child) {
                                  return FloatingActionButton.extended(
                                    onPressed: () {
                                      if (controller.isAnimating) {
                                        controller.stop();
                                        setState(() {});
                                      } else {
                                        onStart();
                                      }
                                    },
                                    icon: Icon(controller.isAnimating
                                        ? Icons.pause
                                        : Icons.play_arrow),
                                    label: Text(controller.isAnimating
                                        ? "Pause"
                                        : "Play"),
                                    backgroundColor: controller.isAnimating
                                        ? Colors.amber
                                        : Colors.green,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(
                              width: 30,
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 100),
                              child: AnimatedBuilder(
                                animation: controller,
                                builder: (context, child) {
                                  return FloatingActionButton.extended(
                                      onPressed: () {
                                        setState(() {
                                          isStart = true;
                                          _start = 3;
                                          controller.reset();
                                        });
                                      },
                                      icon: const Icon(Icons.restart_alt),
                                      label: const Text("Reset"));
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
    );
  }
}

class CustomTimerPainter extends CustomPainter {
  CustomTimerPainter({
    required this.animation,
    required this.backgroundColor,
    required this.color,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color backgroundColor, color;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(size.center(Offset.zero), size.width / 2.0, paint);
    paint.color = color;
    double progress = (1.0 - animation.value) * 2 * math.pi;
    canvas.drawArc(Offset.zero & size, math.pi * 1.5, -progress, false, paint);
  }

  @override
  bool shouldRepaint(CustomTimerPainter old) {
    return animation.value != old.animation.value ||
        color != old.color ||
        backgroundColor != old.backgroundColor;
  }
}
