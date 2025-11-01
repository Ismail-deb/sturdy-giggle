import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;

class SensorCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String unit;
  final String status;
  final Color statusColor;
  final double progress; // Value from 0.0 to 1.0
  final Color progressColor;
  final VoidCallback onTap;

  const SensorCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.unit,
    required this.status,
    required this.statusColor,
    required this.progress,
    required this.progressColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isCritical = status.toLowerCase() == 'critical' || 
                       status.toLowerCase() == 'high' || 
                       status.toLowerCase() == 'detected';

    return Card(
      color: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(16), // Match theme's border radius
            onTap: onTap,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final shortest = math.min(constraints.maxWidth, constraints.maxHeight);
                // Scale relative to a comfortable baseline (180)
                final scale = (shortest / 180.0).clamp(0.9, 1.6);
                final gaugeSize = shortest * 0.62; // occupy ~62% of shorter side
                final stroke = 8.0 * scale;
                final pad = (14.0 * scale).clamp(12.0, 20.0);

                return Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withAlpha(((isDark ? 0.22 : 0.70) * 255).round()),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).dividerColor.withAlpha(((isDark ? 0.30 : 0.25) * 255).round()),
                      width: 1,
                    ),
                  ),
                  padding: EdgeInsets.all(pad),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      // 1. Icon and Title
                      Row(
                        children: [
                          Icon(icon, color: iconColor, size: 20 * scale),
                          SizedBox(width: 6 * scale),
                          Expanded(
                            child: Text(
                              title,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: theme.textTheme.bodyMedium?.color,
                                fontSize: 14 * scale,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 8 * scale),

                      // 2. Circular Gauge and Value
                      Expanded(
                        child: Center(
                          child: SizedBox(
                            height: gaugeSize,
                            width: gaugeSize,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Background arc
                                CustomPaint(
                                  size: Size(gaugeSize, gaugeSize),
                                  painter: _GaugePainter(
                                    progress: 1.0,
                  color: isDark
                    ? theme.scaffoldBackgroundColor.withAlpha((0.3 * 255).round())
                    : Colors.grey.shade300,
                                    strokeWidth: stroke,
                                  ),
                                ),
                                // Progress arc
                                CustomPaint(
                                  size: Size(gaugeSize, gaugeSize),
                                  painter: _GaugePainter(
                                    progress: progress,
                                    color: progressColor,
                                    strokeWidth: stroke,
                                  ),
                                ),
                                // Value Text
                                Padding(
                                  padding: EdgeInsets.only(top: 10 * scale),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        value,
                                        style: theme.textTheme.titleLarge?.copyWith(
                                          color: isCritical
                                              ? statusColor
                                              : theme.textTheme.bodyLarge?.color,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 26 * scale,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (unit.isNotEmpty)
                                        Text(
                                          unit,
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: isCritical
                                                ? statusColor
                                                : theme.textTheme.bodyMedium?.color,
                                            fontSize: 12 * scale,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 8 * scale),

                      // 3. Status
                      Center(
                        child: Text(
                          status,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13 * scale,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// Custom painter for the gauge arc
class _GaugePainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _GaugePainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw arc from -140 degrees to +140 degrees (280 degrees total)
    // Starting angle: -140 degrees from top (converted to radians)
    const startAngle = -140 * math.pi / 180;
    // Sweep angle based on progress (280 degrees max)
    final sweepAngle = 280 * math.pi / 180 * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}