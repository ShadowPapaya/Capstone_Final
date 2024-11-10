import 'dart:async';
import 'package:capstone_1/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:google_sign_in/google_sign_in.dart';
import 'sensor-meter.dart';

class WelcomePage1 extends StatefulWidget {
  final String email;
  WelcomePage1({Key? key, required this.email}) : super(key: key);

  @override
  State<WelcomePage1> createState() => _WelcomePage1State();
}

class _WelcomePage1State extends State<WelcomePage1> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: <String>[sheets.SheetsApi.spreadsheetsReadonlyScope]);
  String _sensorData = 'Loading sensor data...';
  final String _spreadsheetId = '1ARmiXfzcgx2pMnB15LyGQGSeiY1Itz7uB4feiuOXvoo'; // Your actual Google Sheets ID

  double temperature = 0.0;
  double humidity = 0.0;
  double sensorValue1 = 0.0;
  double sensorValue2 = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) {
        setState(() {
          _sensorData = 'Sign-in failed.';
        });
        return;
      }

      final authClient = await _googleSignIn.authenticatedClient();
      if (authClient == null) {
        setState(() {
          _sensorData = 'Failed to authenticate.';
        });
        return;
      }

      final sheetsApi = sheets.SheetsApi(authClient);
      final range = 'Sheet1!A:G';  // Adjust the range based on your sheet structure
      final response = await sheetsApi.spreadsheets.values.get(_spreadsheetId, range);

      if (response.values != null && response.values!.isNotEmpty) {
        final latestRow = response.values!.last;

        if (latestRow.length >= 7) {
          setState(() {
            temperature = double.tryParse(latestRow[3].toString()) ?? 0.0;
            humidity = double.tryParse(latestRow[4].toString()) ?? 0.0;
            sensorValue1 = double.tryParse(latestRow[5].toString()) ?? 0.0;
            sensorValue2 = double.tryParse(latestRow[6].toString()) ?? 0.0;
          });
        } else {
          setState(() {
            _sensorData = 'Incomplete data in the latest row.';
          });
        }
      } else {
        setState(() {
          _sensorData = 'No data found.';
        });
      }
    } catch (e) {
      setState(() {
        _sensorData = 'Error loading data: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            width: w,
            height: h * 0.30,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("img/signup.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              children: [
                SizedBox(height: h * 0.15),
                CircleAvatar(
                  backgroundColor: Colors.white70,
                  radius: 60,
                  backgroundImage: AssetImage("img/profile.png"),
                ),
              ],
            ),
          ),
          SizedBox(height: 1),
          Container(
            width: w,
            margin: const EdgeInsets.only(left: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome!!",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  widget.email,
                  style: TextStyle(fontSize: 18, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          SizedBox(height: 5),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 1.1,
              padding: EdgeInsets.all(0),
              mainAxisSpacing: 0,
              crossAxisSpacing: 0,
              children: [
                SensorMeter(sensorName: "Temperature", sensorValue: temperature, maxValue: 100.0),
                SensorMeter(sensorName: "Humidity", sensorValue: humidity, maxValue: 100.0),
                SensorMeter(sensorName: "LDR", sensorValue: sensorValue1, maxValue: 5000.0),
                SensorMeter(sensorName: "MQ3", sensorValue: sensorValue2, maxValue: 600.0),
              ],
            ),
          ),
          SizedBox(height: 1),
          GestureDetector(
            onTap: _fetchData,
            child: Container(
              width: w * 0.3,
              height: h * 0.05,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                image: DecorationImage(
                  image: AssetImage("img/loginbtn.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: Text(
                  "Refresh Data",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              // Log out logic
              AuthController.instance.logOut(); // This will log out the user via your existing AuthController
            },
            child: Container(
              width: w * 0.3,
              height: h * 0.06,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                image: DecorationImage(
                  image: AssetImage("img/loginbtn.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: Text(
                  "Sign out",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
