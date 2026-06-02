import 'package:flutter/material.dart';

class AnimatedCounter extends StatefulWidget {
  final double value;
  final String suffix;
  final String prefix;
  final TextStyle? style;
  final Duration duration;
  final int decimalPlaces;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.suffix = '',
    this.prefix = '',
    this.style,
    this.duration = const Duration(milliseconds: 800),
    this.decimalPlaces = 0,
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _begin = 0;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween<double>(begin: 0, end: widget.value)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCounter old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _begin = old.value;
      _animation = Tween<double>(begin: _begin, end: widget.value)
          .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final val = _animation.value;
        final text = widget.decimalPlaces > 0
            ? val.toStringAsFixed(widget.decimalPlaces)
            : val.toStringAsFixed(0);
        return Text(
          '${widget.prefix}$text${widget.suffix}',
          style: widget.style,
        );
      },
    );
  }
}
