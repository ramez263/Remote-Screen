import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/vpn_models.dart';

class TrafficHeroBanner extends StatelessWidget {
  final bool isConnected;
  final bool isConnecting;
  final List<TrafficSample> samples;

  const TrafficHeroBanner({
    super.key,
    required this.isConnected,
    required this.isConnecting,
    required this.samples,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 158,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/tunnel_hero_wings.jpg',
              fit: BoxFit.contain,
            ),
          ),
          Container(
            width: 108,
            height: 108,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE6B800), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.14),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/tunnel_emblem_badge.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          if (isConnected && samples.length > 1)
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 24, 12, 6),
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineTouchData: const LineTouchData(enabled: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          for (int i = 0; i < samples.length; i++)
                            FlSpot(i.toDouble(), samples[i].downloadKbps),
                        ],
                        isCurved: true,
                        color: const Color(0xFFCA8A04),
                        barWidth: 2.2,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: const Color(0xFFEAB308).withValues(alpha: 0.25),
                        ),
                      ),
                      LineChartBarData(
                        spots: [
                          for (int i = 0; i < samples.length; i++)
                            FlSpot(i.toDouble(), samples[i].uploadKbps),
                        ],
                        isCurved: true,
                        color: const Color(0xFF120E3A),
                        barWidth: 1.8,
                        dashArray: [4, 3],
                        dotData: const FlDotData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isConnecting ? 'Handshaking VPS...' : 'No Graph Data',
                style: const TextStyle(
                  color: Color(0xFFFACC15),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
