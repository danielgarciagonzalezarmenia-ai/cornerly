import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AnalysisOverlayScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const AnalysisOverlayScreen({super.key, required this.onComplete});

  @override
  State<AnalysisOverlayScreen> createState() => _AnalysisOverlayScreenState();
}

class _AnalysisOverlayScreenState extends State<AnalysisOverlayScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scan;
  int _stepIndex = 0;
  Timer? _timer;
  int _progress = 0;

  final List<String> _steps = [
    'Obteniendo partidos de hoy...',
    'Revisando cuotas 12/48...',
    'Buscando mercado de corners...',
    'Filtrando resultados...',
    'Finalizando análisis...',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _scan = Tween<double>(begin: -100, end: 110).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
    _controller.repeat();

    _timer = Timer.periodic(const Duration(milliseconds: 400), (_) {
      if (_progress < 100) {
        setState(() {
          _progress += 17;
          if (_stepIndex < _steps.length - 1 && _progress >= 20 * (_stepIndex + 1)) {
            _stepIndex++;
          }
        });
      } else {
        _timer?.cancel();
        Future.delayed(const Duration(milliseconds: 500), widget.onComplete);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _scan,
                      builder: (context, child) {
                        return ClipRect(
                          child: Align(
                            alignment: Alignment(0, _scan.value),
                            child: Container(
                              height: 4,
                              color: const Color(0xFF7ACB1F),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(CupertinoIcons.viewfinder, size: 80, color: Color(0xFF7ACB1F)),
                      const SizedBox(height: 24),
                      Text(
                        _steps[_stepIndex],
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF111111)),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 260,
                        height: 6,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: _progress / 100,
                            backgroundColor: const Color(0xFFE6E6E6),
                            valueColor: const AlwaysStoppedAnimation(Color(0xFF7ACB1F)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('$_progress%', style: const TextStyle(fontSize: 12, color: Color(0xFF8A8A8A))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
