import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:class_interaction_wear_os/Apiurl.dart';
import 'package:class_interaction_wear_os/Enter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Service {
  final String apiUrl = Apiurl().url;
  BuildContext context;
  final storage = FlutterSecureStorage();

  Service(this.context);

  Future<http.Response?> getInfo(String pin) async {
    try {
      var response = await http.get(
        Uri.parse('$apiUrl/watch/${pin}'),
      );
      if (response.statusCode == 200) {
        var token = response.headers['authorization'];

        startTokenDeletionTimer(context);
        await storage.write(key: 'Authorization', value: token);
      }
      return response;
    } catch (e) {
      print("예외처리");
    }
    return null;
  }

  void startTokenDeletionTimer(BuildContext context) {
    // 2시간 후 토큰 삭제 타이머
    Timer(Duration(hours: 2), () async {
      await logout();
      showLogoutDialog(context);
    });
  }

  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('알림'),
          content: Text('로그인 시간이 만료되었습니다.'),
          actions: <Widget>[
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => Enter()),
                    (route) => false);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> logout() async {
    // FlutterSecureStorage에서 토큰 삭제
    await storage.delete(key: 'Authorization');
  }

}
