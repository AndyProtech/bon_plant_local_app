// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/nsg_controls.dart';

import '../model/data_controller.dart';

// const List<String> _images = <String>[
//   'lib/assets/images/sv1.svg',
//   'lib/assets/images/sv2.svg',
//   'lib/assets/images/sv3.svg',
//   'lib/assets/images/sv4.svg',
//   'lib/assets/images/logo.svg'
// ];

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double>

      ///
      _fadein,
      _translate,
      _opacity,
      _scale,
      _scale2,
      _scale3,
      _scale4,
      _scale5,
      _translate3,
      _opacity5,
      _fadein1,
      _fadein2,
      _fadein3,
      _fadein4;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _fadein = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.2, curve: Curves.easeOut),
      ),
    );

    _translate = Tween(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.5, curve: Curves.easeInOut),
      ),
    );

    _opacity = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0).chain(CurveTween(curve: Curves.easeOut)), weight: 95),
      TweenSequenceItem(
          //  tween: Tween(begin: 1.0, end: 0.0)
          tween: Tween(begin: 1.0, end: 1.0).chain(CurveTween(curve: Curves.easeOut)),
          weight: 5)
    ]).animate((CurvedAnimation(parent: _controller, curve: const Interval(0.0, 1.0))));

    _scale = Tween(begin: 0.0, end: 1.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeInOut),
      ),
    );

    _scale2 = Tween(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    _scale3 = TweenSequence([
      TweenSequenceItem(
          //  tween: Tween(begin: 1.0, end: 0.0)
          tween: Tween(begin: 500.0, end: 400.0).chain(CurveTween(curve: Curves.linear)),
          weight: 20),
      TweenSequenceItem(
          //  tween: Tween(begin: 1.0, end: 0.0)
          tween: Tween(begin: 400.0, end: 250.0).chain(CurveTween(curve: Curves.linear)),
          weight: 20),
    ]).animate((CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.5))));

    _translate3 = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.linear)), weight: 10),
      TweenSequenceItem(
          //  tween: Tween(begin: 1.0, end: 0.0)
          tween: Tween(begin: 1.0, end: -1.0).chain(CurveTween(curve: Curves.linear)),
          weight: 10),
      TweenSequenceItem(
          //  tween: Tween(begin: 1.0, end: 0.0)
          tween: Tween(begin: -1.0, end: 0.0).chain(CurveTween(curve: Curves.bounceInOut)),
          weight: 10)
    ]).animate((CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5))));

    _scale4 = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0).chain(CurveTween(curve: Curves.linear)), weight: 80),
      TweenSequenceItem(
          //  tween: Tween(begin: 1.0, end: 0.0)
          tween: Tween(begin: -10.0, end: 10.0).chain(CurveTween(curve: Curves.linear)),
          weight: 20)
    ]).animate((CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5))));

    _scale5 = Tween(begin: 0.0, end: -100.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.8, curve: Curves.easeInOut),
      ),
    );

    _opacity5 = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeInOut),
      ),
    );

    _fadein1 = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.35, curve: Curves.easeInOut),
      ),
    );

    _fadein2 = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.4, curve: Curves.easeInOut),
      ),
    );

    _fadein3 = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.45, curve: Curves.easeInOut),
      ),
    );

    _fadein4 = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.3, curve: Curves.easeInOut),
      ),
    );

    _controller.addListener(() {
      if (_controller.status == AnimationStatus.completed) {
        var controller = Get.find<DataController>();
        controller.splashAnimationFinished();
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<DataController>();
    double size;
    double getHeight = Get.height;
    double getWidth = Get.width;
    if (getWidth < getHeight) {
      size = getWidth - 60;
    } else {
      size = getHeight - 60;
    }
    if (size > 500) {
      size = 500;
    }

    //TextStyle textstyle = const TextStyle(fontSize: 12, fontWeight: FontWeight.bold);
    return Scaffold(
      body: AnimatedBuilder(
        animation: _fadein,
        builder: (ctx, ch) => Container(
          decoration: const BoxDecoration(color: Color.fromARGB(255, 255, 255, 255)),
          padding: const EdgeInsets.all(0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: FadeTransition(
                    opacity: _opacity,
                    child: Transform.scale(
                      scale: _scale.value,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Transform.scale(
                            scale: _opacity5.value,
                            child: Opacity(
                              opacity: _opacity5.value,
                              child: SvgPicture.asset(
                                'lib/assets/images/logo_lab.svg',
                                width: 300,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              controller.obx(
                (state) => const SizedBox(),
                onLoading: FadeIn(
                  duration: Duration(milliseconds: ControlOptions.instance.fadeSpeed),
                  curve: Curves.easeIn,
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 15),
                    child: Text(
                      'Подключение к серверу...',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                onError: (s) => FadeIn(
                  duration: Duration(milliseconds: ControlOptions.instance.fadeSpeed),
                  curve: Curves.easeIn,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: ControlOptions.instance.colorError),
                        const Padding(
                          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                          child: Text(
                            'Проверьте интернет соединение',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
