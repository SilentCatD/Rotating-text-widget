import 'package:flutter/material.dart';

enum RotatingType {
  next,
  prev,
}

class RotatingTextController extends ChangeNotifier {
  late RotatingType _rotatingType;

  RotatingType get rotatingType => _rotatingType;

  RotatingTextController([RotatingType rotatingType = RotatingType.next]) {
    _rotatingType = rotatingType;
  }

  void next() {
    _rotatingType = RotatingType.next;
    notifyListeners();
  }

  void prev() {
    _rotatingType = RotatingType.prev;
    notifyListeners();
  }
}

class RotatingText extends StatefulWidget {
  RotatingText(
      {Key? key,
        this.controller,
        required this.texts,
        this.textStyle,
        this.animationDuration = const Duration(milliseconds: 300)})
      : super(key: key) {
    assert(texts.isNotEmpty);
  }

  final RotatingTextController? controller;
  final List<String> texts;
  final TextStyle? textStyle;
  final Duration animationDuration;

  @override
  State<RotatingText> createState() => _RotatingTextState();
}

class _RotatingTextState extends State<RotatingText>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _rollPrevAnimation;
  late Animation<Offset> _rollNextAnimation;
  late Animation<Offset> _bounceBackAnimation;
  late Animation<double> _fadePrevAnimation;
  late Animation<double> _fadeNextAnimation;

  int _currentIndex = 0;
  int _nextIndex = 0;

  @override
  void initState() {
    super.initState();
    final initialRotateType =
        widget.controller?.rotatingType ?? RotatingType.next;
    _initAnimation(initialRotateType);
    widget.controller?.addListener(_playAnimation);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_playAnimation);
    super.dispose();
  }

  void _playAnimation() async {
    _animationController.dispose();
    if (widget.controller!.rotatingType == RotatingType.next) {
      _nextIndex = _currentIndex + 1;
      if (_nextIndex > widget.texts.length - 1) {
        _nextIndex = 0;
      }
    } else {
      _nextIndex = _currentIndex - 1;
      if (_nextIndex < 0) {
        _nextIndex = widget.texts.length - 1;
      }
    }
    setState(() {});
    _initAnimation(widget.controller!.rotatingType);
    _animationController.forward();
    _currentIndex = _nextIndex;
  }

  void _initAnimation(RotatingType rotatingType) {
    _animationController =
        AnimationController(vsync: this, duration: widget.animationDuration);
    if (rotatingType == RotatingType.next) {
      _rollPrevAnimation =
          Tween<Offset>(begin: Offset.zero, end: const Offset(0, -1)).animate(
              CurvedAnimation(
                  parent: _animationController, curve: const Interval(0, 0.8)));
      _rollNextAnimation =
          Tween<Offset>(begin: const Offset(0, 1), end: const Offset(0, -0.5))
              .animate(CurvedAnimation(
              parent: _animationController,
              curve: const Interval(0.0, 0.8)));
      _bounceBackAnimation =
          Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero).animate(
              CurvedAnimation(
                  parent: _animationController, curve: const Interval(0.8, 1)));

      _fadePrevAnimation = Tween<double>(begin: 1, end: 0).animate(
          CurvedAnimation(
              parent: _animationController, curve: const Interval(0, 0.3)));

      _fadeNextAnimation = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
              parent: _animationController, curve: const Interval(0, 0.3)));
    } else {
      _rollPrevAnimation =
          Tween<Offset>(begin: Offset.zero, end: const Offset(0, 1)).animate(
              CurvedAnimation(
                  parent: _animationController, curve: const Interval(0, 0.8)));
      _rollNextAnimation =
          Tween<Offset>(begin: const Offset(0, -1), end: const Offset(0, 0.5))
              .animate(CurvedAnimation(
              parent: _animationController,
              curve: const Interval(0.0, 0.8)));
      _bounceBackAnimation =
          Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
              CurvedAnimation(
                  parent: _animationController, curve: const Interval(0.8, 1)));

      _fadePrevAnimation = Tween<double>(begin: 1, end: 0).animate(
          CurvedAnimation(
              parent: _animationController, curve: const Interval(0, 0.3)));

      _fadeNextAnimation = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
              parent: _animationController, curve: const Interval(0, 0.3)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        FadeTransition(
          opacity: _fadePrevAnimation,
          child: SlideTransition(
            position: _rollPrevAnimation,
            child: Text(
              widget.texts[_currentIndex],
              style: widget.textStyle,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return SlideTransition(
              position: _rollNextAnimation.value.dy == -0.5 ||
                  _rollNextAnimation.value.dy == 0.5
                  ? _bounceBackAnimation
                  : _rollNextAnimation,
              child: FadeTransition(
                opacity: _fadeNextAnimation,
                child: Text(
                  widget.texts[_nextIndex],
                  style: widget.textStyle,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
