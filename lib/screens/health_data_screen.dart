import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HealthDataScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return Scaffold(body: Center(child: Text('Not logged in')));

    return Scaffold(
      appBar: AppBar(title: Text('Your Health Data')),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
          final health = data['googleFit'] ?? {};

          return Padding(
            padding: EdgeInsets.all(16),
            child: ListView(
              children: [
                _tile('Steps (last 24h)', health['steps']?.toString()),
                _tile('Heart Rate (avg)', health['heartRate']?.toStringAsFixed(1)),
                _tile('Active Energy Burned (kcal)', health['activeEnergyBurned']?.toStringAsFixed(1)),
                _tile('Sleep Duration (minutes)', health['sleepMinutes']?.toString()),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _tile(String label, String? value) {
    return Card(
      child: ListTile(
        title: Text(label),
        trailing: Text(value ?? 'No data'),
      ),
    );
  }
}
