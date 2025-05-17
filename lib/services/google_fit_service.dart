import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

class GoogleFitService {
  static Future<bool> requestHealthPermissions() async {
    final status1 = await Permission.activityRecognition.request();
    final status2 = await Permission.sensors.request();
    return status1.isGranted && status2.isGranted;
  }

  static Future<Map<String, dynamic>?> fetchGoogleFitData() async {
    print('Requesting health permissions...');

    final hasPermission = await requestHealthPermissions();
    if (!hasPermission) {
      print('Permission denied');
      return null;
    }

    final health = HealthFactory();

    final types = [
      HealthDataType.STEPS,
      HealthDataType.HEART_RATE,
      HealthDataType.ACTIVE_ENERGY_BURNED,
      HealthDataType.SLEEP_ASLEEP,
    ];

    final now = DateTime.now();
    final yesterday = now.subtract(Duration(days: 1));

    bool requested = await health.requestAuthorization(types);
    print('Permission granted: $requested');
    if (!requested) return null;

    try {
      Map<String, dynamic> data = {};

      for (var type in types) {
        print('Fetching data for $type...');
        List<HealthDataPoint> points =
            await health.getHealthDataFromTypes(yesterday, now, [type]);
        print('Fetched ${points.length} points for $type');

        if (points.isNotEmpty) {
          if (type == HealthDataType.STEPS) {
            int totalSteps = points.fold(0, (sum, p) {
              if (p.value is int) return sum + (p.value as int);
              if (p.value is double) return sum + (p.value as double).toInt();
              return sum;
            });
            data['steps'] = totalSteps;
          } else if (type == HealthDataType.HEART_RATE) {
            List<double> values = points
                .where((p) => p.value is num)
                .map((p) => (p.value as num).toDouble())
                .toList();
            if (values.isNotEmpty) {
              double avgHR = values.reduce((a, b) => a + b) / values.length;
              data['heartRate'] = avgHR;
            }
          } else if (type == HealthDataType.ACTIVE_ENERGY_BURNED) {
            double totalEnergy = points.fold(0.0, (sum, p) {
              if (p.value is num) return sum + (p.value as num).toDouble();
              return sum;
            });
            data['activeEnergyBurned'] = totalEnergy;
          } else if (type == HealthDataType.SLEEP_ASLEEP) {
            int totalSleepMinutes = points.fold(0, (sum, p) {
              final duration = p.dateTo.difference(p.dateFrom);
              return sum + duration.inMinutes;
            });
            data['sleepMinutes'] = totalSleepMinutes;
          }
        }
      }

      print('Final collected data: $data');
      return data;
    } catch (e) {
      print('Error fetching health data: $e');
      return null;
    }
  }
}
