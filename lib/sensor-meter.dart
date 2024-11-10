import 'package:flutter/material.dart';

class SensorMeter extends StatelessWidget {
  final String sensorName;
  final double sensorValue;
  final double maxValue;

  SensorMeter({
    required this.sensorName,
    required this.sensorValue,
    required this.maxValue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 120.0, // Increase width of the circle
          height: 120.0, // Increase height of the circle
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: 3, // Scale the progress circle to the desired size
                child: CircularProgressIndicator(
                  value: 1.0,
                  color: Colors.green[100],
                  strokeWidth: 5, // Adjust stroke width for visibility
                ),
              ),
              Transform.scale(
                scale: 3, // Scale the progress circle to the desired size
                child: CircularProgressIndicator(
                  value: sensorValue / maxValue,
                  color: Colors.green[800],
                  strokeWidth: 5, // Adjust stroke width for visibility
                ),
              ),
              Text(
                '${sensorValue.toStringAsFixed(1)}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        SizedBox(height: 11),
        Text(sensorName, style: TextStyle(fontSize: 16)),
      ],
    );
  }
}
