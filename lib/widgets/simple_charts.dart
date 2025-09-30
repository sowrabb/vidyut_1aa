import 'package:flutter/material.dart';

class LineSeriesPoint {
  final DateTime x;
  final double y;
  LineSeriesPoint(this.x, this.y);
}

class LineChart extends StatelessWidget {
  final List<LineSeriesPoint> points;
  final Color color;
  final double strokeWidth;
  final EdgeInsets padding;
  const LineChart(
      {super.key,
      required this.points,
      this.color = Colors.blue,
      this.strokeWidth = 2,
      this.padding = const EdgeInsets.all(12)});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 180),
      painter: _LineChartPainter(
          points: points,
          color: color,
          strokeWidth: strokeWidth,
          padding: padding),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<LineSeriesPoint> points;
  final Color color;
  final double strokeWidth;
  final EdgeInsets padding;
  _LineChartPainter(
      {required this.points,
      required this.color,
      required this.strokeWidth,
      required this.padding});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final chartRect = Rect.fromLTWH(
        rect.left + padding.left,
        rect.top + padding.top,
        rect.width - padding.horizontal,
        rect.height - padding.vertical);
    if (points.isEmpty || chartRect.width <= 0 || chartRect.height <= 0) return;

    // Axes
    final axisPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 1;
    canvas.drawLine(chartRect.bottomLeft, chartRect.bottomRight, axisPaint);
    canvas.drawLine(chartRect.bottomLeft, chartRect.topLeft, axisPaint);

    // Compute scales
    final xs =
        points.map((p) => p.x.millisecondsSinceEpoch.toDouble()).toList();
    final ys = points.map((p) => p.y).toList();
    final minX = xs.reduce((a, b) => a < b ? a : b);
    final maxX = xs.reduce((a, b) => a > b ? a : b);
    final minY = ys.reduce((a, b) => a < b ? a : b);
    final maxY = ys.reduce((a, b) => a > b ? a : b);
    final spanX = (maxX - minX) == 0 ? 1 : (maxX - minX);
    final spanY = (maxY - minY) == 0 ? 1 : (maxY - minY);

    double mapX(double v) =>
        chartRect.left + (v - minX) / spanX * chartRect.width;
    double mapY(double v) =>
        chartRect.bottom - (v - minY) / spanY * chartRect.height;

    // Path
    final path = Path();
    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final dx = mapX(p.x.millisecondsSinceEpoch.toDouble());
      final dy = mapY(p.y);
      if (i == 0) {
        path.moveTo(dx, dy);
      } else {
        path.lineTo(dx, dy);
      }
    }
    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;
    canvas.drawPath(path, linePaint);

    // Points
    final pointPaint = Paint()..color = color.withOpacity(0.8);
    for (final p in points) {
      final dx = mapX(p.x.millisecondsSinceEpoch.toDouble());
      final dy = mapY(p.y);
      canvas.drawCircle(Offset(dx, dy), 2.5, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.padding != padding;
  }
}
