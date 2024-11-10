import 'dart:async';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[sheets.SheetsApi.spreadsheetsReadonlyScope],
);


class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => WelcomePageState();
}

class WelcomePageState extends State<WelcomePage> {
  GoogleSignInAccount? _currentUser;
  String _contactText = '';
  final String _spreadsheetId = '1ARmiXfzcgx2pMnB15LyGQGSeiY1Itz7uB4feiuOXvoo'; // Replace with your spreadsheet ID

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
      if (_currentUser != null) {
        _handleGetLatestSensorData();
      }
    });
    _googleSignIn.signInSilently();
  }

  Future<void> _handleGetLatestSensorData() async {
    setState(() {
      _contactText = 'Loading sensor data...';
    });

    // Retrieve an AuthClient from the current GoogleSignIn instance
    final auth.AuthClient? client = await _googleSignIn.authenticatedClient();

    assert(client != null, 'Authenticated client missing!');

    // Initialize Sheets API with the authenticated client
    final sheetsApi = sheets.SheetsApi(client!);

    // Define the range to fetch data from
    final range = 'Sheet1!A:G';  // Modify based on your sheet
    final response = await sheetsApi.spreadsheets.values.get(_spreadsheetId, range);

    final rows = response.values;
    if (rows == null || rows.isEmpty) {
      setState(() {
        _contactText = 'No data found.';
      });
      return;
    }

    // Assuming rows contain the latest sensor data, here we display it
    final latestData = rows.last;  // You can modify how to display it based on your data
    setState(() {
      _contactText = 'Latest Data: ${latestData.join(", ")}';
    });
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error); // ignore: avoid_print
    }
  }

  Future<void> _handleSignOut() async {
    await _googleSignIn.disconnect();
    setState(() {
      _contactText = 'You are signed out';
    });
  }

  Widget _buildBody() {
    final GoogleSignInAccount? user = _currentUser;
    if (user != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          ListTile(
            leading: GoogleUserCircleAvatar(
              identity: user,
            ),
            title: Text(user.displayName ?? ''),
            subtitle: Text(user.email),
          ),
          const Text('Signed in successfully.'),
          Text(_contactText),
          ElevatedButton(
            onPressed: _handleSignOut,
            child: const Text('SIGN OUT'),
          ),
          ElevatedButton(
            onPressed: _handleGetLatestSensorData,
            child: const Text('REFRESH'),
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          const Text('You are not currently signed in.'),
          ElevatedButton(
            onPressed: _handleSignIn,
            child: const Text('SIGN IN'),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Google Sign In + Google Sheets'),
        ),
        body: ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: _buildBody(),
        ));
  }
}
