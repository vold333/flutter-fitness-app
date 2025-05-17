import 'package:fitness/screens/health_data_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/google_fit_service.dart';

class QuestionnaireScreen extends StatefulWidget {
  @override
  _QuestionnaireScreenState createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _data = {};
  bool _loading = false;

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _smokingStatus = ['Non-smoker', 'Occasional', 'Regular'];

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _loading = true);

    // Save questionnaire data
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'questionnaire': _data,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Fetch and save Google Fit data
    final googleFitData = await GoogleFitService.fetchGoogleFitData();
    if (googleFitData != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'googleFit': googleFitData,
        'googleFitTimestamp': FieldValue.serverTimestamp(),
      });
    }

    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ Data and health data saved successfully!')),
    );

    Navigator.push(context, MaterialPageRoute(builder: (context) => HealthDataScreen()));
  }

  InputDecoration _inputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.blue),
      borderRadius: BorderRadius.circular(10),
    ),
  );
}

Widget _buildTextField(String label, String key,
    {TextInputType type = TextInputType.text,
    String? Function(String?)? validator}) {
  return TextFormField(
    decoration: _inputDecoration(label),
    keyboardType: type,
    validator: validator ?? (val) => val == null || val.isEmpty ? 'Required' : null,
    onSaved: (val) => _data[key] = val,
  );
}

Widget _buildDropdown(String label, String key, List<String> options) {
  return DropdownButtonFormField<String>(
    decoration: _inputDecoration(label),
    items: options.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
    validator: (val) => val == null || val.isEmpty ? 'Required' : null,
    onChanged: (val) => _data[key] = val,
    onSaved: (val) => _data[key] = val,
  );
}


  String? _validateNumberInRange(String? val, int min, int max) {
    if (val == null || val.isEmpty) return 'Required';
    final n = int.tryParse(val);
    if (n == null) return 'Must be a number';
    if (n < min || n > max) return 'Must be between $min and $max';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width > 600 ? 500.0 : double.infinity;

    return Scaffold(
      appBar: AppBar(
        title: Text('Health Questionnaire', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[700], // Dark blue app bar
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField('Full Name', 'fullName'),
                    SizedBox(height: 12),
                    _buildTextField('Age', 'age',
                        type: TextInputType.number,
                        validator: (v) => _validateNumberInRange(v, 1, 120)),
                    SizedBox(height: 12),
                    _buildDropdown('Gender', 'gender', _genders),
                    SizedBox(height: 12),
                    _buildTextField('Height (cm)', 'height',
                        type: TextInputType.number,
                        validator: (v) => _validateNumberInRange(v, 30, 300)),
                    SizedBox(height: 12),
                    _buildTextField('Weight (kg)', 'weight',
                        type: TextInputType.number,
                        validator: (v) => _validateNumberInRange(v, 1, 500)),
                    SizedBox(height: 12),
                    _buildTextField('Physical Activity Level', 'activity'),
                    SizedBox(height: 12),
                    _buildTextField('Medical History', 'history'),
                    SizedBox(height: 12),
                    _buildTextField('Dietary Preferences', 'diet'),
                    SizedBox(height: 12),
                    _buildDropdown('Smoking Status', 'smoking', _smokingStatus),
                    SizedBox(height: 12),
                    _buildTextField('Chronic Conditions', 'conditions'),
                    SizedBox(height: 20),
                    _loading
                        ? CircularProgressIndicator()
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _submit,
                              child: Text('Submit', style: TextStyle(color: Colors.blue)),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

