import 'dart:convert';
import 'package:class_interaction_wear_os/Apiurl.dart';
import 'package:class_interaction_wear_os/Opinion/Opinion.dart';
import 'package:class_interaction_wear_os/Opinion/OpinionService.dart';
import 'package:class_interaction_wear_os/Opinion/OpinionVote.dart';
import 'package:class_interaction_wear_os/Websocket/Dialogs.dart';
import 'package:class_interaction_wear_os/classroom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';


class ClassroomService{
  final String apiUrl = Apiurl().url;
  final storage = FlutterSecureStorage();


  int maxCount(List<OpinionVote> opinion) {
    int maxIndex = 0;
    for (int i = 1; i < opinion.length; i++) {
      if (opinion[i].count > opinion[maxIndex].count) {
        maxIndex = i;
      }
    }
    return maxIndex;
  }

  //학생 특정수업입장(pin번호 입력으로)
  Future<Classroom?> studentEnterClassPin(
    BuildContext context,
    String classNumber,
  ) async {
    // JWT 토큰을 저장소에서 읽어오기
    String? jwt = await storage.read(key: 'Authorization');

    if (jwt == null) {
      //토큰이 존재하지 않을 때 첫페이지로 이동
      await Dialogs.showErrorDialog(context, '로그인시간이 만료되었습니다.');
      Navigator.of(context).pushReplacementNamed('/Loginpage');
      return null;
    }

    // 헤더에 JWT 토큰 추가
    var headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': jwt,
    };

    try {
      var response = await http.get(
        Uri.parse('$apiUrl/classrooms/classroomEnter/pin/$classNumber'),
        headers: headers,
      );
      print(classNumber);
      print(response.statusCode);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody =
            jsonDecode(utf8.decode(response.bodyBytes));
        print("응답성공 ");
        Classroom classroom =
            Classroom.fromJson_notArray(responseBody['classroom']);

        List<Opinion> opinions = (responseBody['opinions'] as List)
            .map((opinionJson) => Opinion.fromJson(opinionJson))
            .toList();

        var opinionService =
            Provider.of<OpinionService>(context, listen: false);

        if (opinions.isNotEmpty) {
          opinionService.initializeOpinionList();
        }
        for (int i = 0; i < opinions.length; i++) {
          opinionService.addOpinion(opinion: opinions[i]);
          print(opinions[i].opinion);
        }
        return classroom;
      } else {
        await Dialogs.showErrorDialog(context, '오류발생');
      }
    } catch (exception) {
      print(exception);
      await Dialogs.showErrorDialog(context, "서버와의 통신 중 오류가 발생했습니다.");
    }
    return null;
  }
}
