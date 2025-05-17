import 'package:permission_handler/permission_handler.dart';

Future<bool> requestHealthPermissions() async {
  final status1 = await Permission.activityRecognition.request();
  final status2 = await Permission.sensors.request();

  return status1.isGranted && status2.isGranted;
}
