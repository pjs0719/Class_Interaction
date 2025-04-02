import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:spaghetti/Dialog/Dialogs.dart';
import 'package:spaghetti/classroom/instructor/EvaluationResultPage.dart';
import 'package:spaghetti/Websocket/MessageDTO.dart';
import 'package:spaghetti/Websocket/UserCount.dart';
import 'package:spaghetti/classroom/classDetailPage.dart';
import 'package:spaghetti/classroom/student/classEnterPage.dart';
import 'package:spaghetti/member/User.dart';
import 'package:spaghetti/opinion/Opinion.dart';
import 'package:spaghetti/opinion/OpinionService.dart';
import 'package:spaghetti/opinion/OpinionVote.dart';
import 'package:spaghetti/quiz/Quiz.dart';
import 'package:spaghetti/quiz/QuizService.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:spaghetti/ApiUrl.dart';
import 'dart:convert';

class Websocket {
  late String classId;
  final storage = FlutterSecureStorage();
  String? jwt;
  StompClient? stompClient;
  late User? user;
  dynamic unsubscribe;
  late BuildContext context;

  // late BuildContext context;
  Websocket(this.classId, this.user, this.jwt, this.context) {
    stompClient = stomClient(jwt, context);
    stompClient?.activate();
  }

  StompClient stomClient(String? jwt, context) {
    return StompClient(
      config: StompConfig.sockJS(
        url: '${Apiurl().url}/classroomEnter',
        onConnect: (StompFrame frame) => onConnect(frame, context),
        beforeConnect: () async {
          await Future.delayed(const Duration(milliseconds: 2000));
        },
        onWebSocketError: (dynamic error) => print(error.toString()),
        onDisconnect: (frame) {},
        reconnectDelay: const Duration(milliseconds: 0),
        stompConnectHeaders: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': jwt ?? "",
        },
        webSocketConnectHeaders: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': jwt,
        },
      ),
    );
  }

  Future<void> onConnect(StompFrame frame, context) async {
    unsubscribe = stompClient!.subscribe(
      destination: '/sub/classroom/$classId',
      callback: (frame) async {
        Map<String, dynamic> json = jsonDecode(frame.body ?? "");

        MessageDTO message = MessageDTO.fromJson(json);
        switch (message.status) {
          case Status.OPINION:
            // 의견 제출 처리
            if (user?.role == "instructor") {
              if (message.opinion?.opinionId != null) {
                //  message.opinion?.opinionId;
                Provider.of<OpinionService>(context, listen: false)
                    .voteAdd(message.opinion);
                List<OpinionVote> list =
                    Provider.of<OpinionService>(context, listen: false)
                        .countList;
                int total = list.length;
                for (int i = 0; i < list.length; i++) {
                  if ((total / 3) <= list[i].count) {
                    await Dialogs.showErrorDialog(context,
                        "${Provider.of<OpinionService>(context, listen: false).opinionList[i].opinion}");
                  }
                }
              }
            }
            break;
          case Status.OPINIONUPDATE:
            // 교수 의견 업데이트 처리
            if (user?.role == "student") {
              Provider.of<OpinionService>(context, listen: false)
                  .setOpinionList(message.opList);
              Provider.of<OpinionService>(context, listen: false)
                  .setOpinionList(message.opList);
              Provider.of<OpinionService>(context, listen: false)
                  .setOpinionSend(true);
            }

            break;
          case Status.OPINIONINITIALIZE:

            //의견초기화
            if (user?.role == "student") {
              Provider.of<OpinionService>(context, listen: false)
                  .setOpinionSend(true);
            }
            break;
          case Status.QUIZ:
            // 퀴즈 처리
            if (user?.role == "instructor") {
              Provider.of<QuizService>(context, listen: false)
                  .voteAdd(message.quiz);
            }
            break;
          case Status.QUIZUPDATE:
            // 교수 퀴즈 업데이트 처리
            if (user?.role == "student") {
              Provider.of<QuizService>(context, listen: false)
                  .setQuizList(message.quizList);
              await addDialog(context, this);
            }
            break;
          case Status.EVALUATION:
            // 수업 평가 처리
            if (user?.role == "instructor") {
              Provider.of<UserCount>(context, listen: false)
                  .evaluationListAdd(message.evaluation);
            }
            break;
          case Status.PEOPLESTATUS:
            // 사용자인원 처리

            Provider.of<UserCount>(context, listen: false).updateUserCount(
                message.classId ?? "", message.userEmails.length);
            break;
          case Status.CLOSE:
            // 사용자에게 수업끝났다고 알림
            if (user?.role == "student") {
              await Dialogs.showErrorDialog(context, "교수님께서 수업을 종료하셨습니다 ");
              Navigator.pop(context);
            }
            break;
          default:
            break;
        }
      },
    );
  }

  //의견 보내기
  Future<void> opinionSend(Opinion opinion) async {
    stompClient?.send(
      destination: '/pub/classroom/$classId/message',
      body: json.encode({
        'status': Status.OPINION.toString().split('.').last,
        'classId': classId,
        'opinion': opinion,
      }),
    );
  }

  //의견 초기화
  Future<void> opinionInit() async {
    stompClient?.send(
      destination: '/pub/classroom/$classId/message',
      body: json.encode({
        'status': Status.OPINIONINITIALIZE.toString().split('.').last,
        'classId': classId,
      }),
    );
  }

  //의견 수정 정보 알리기
  Future<void> sendOpinionUpdate(List<Opinion> opinion) async {
    stompClient?.send(
      destination: '/pub/classroom/$classId/message',
      body: json.encode({
        'status': Status.OPINIONUPDATE.toString().split('.').last,
        'classId': classId,
        'opinionList': opinion,
      }),
    );
  }

  //퀴즈 제출
  Future<void> sendQuiz(Quiz quiz) async {
    print("퀴즈아이디 : $quiz.quizId");
    stompClient?.send(
      destination: '/pub/classroom/$classId/message',
      body: json.encode({
        'status': Status.QUIZ.toString().split('.').last,
        'classId': classId,
        'quiz': quiz,
      }),
    );
  }

  //학생들에게 퀴즈 풀기 알리기
  Future<void> sendQuizUpdate(List<Quiz> quizs) async {
    stompClient?.send(
      destination: '/pub/classroom/$classId/message',
      body: json.encode({
        'status': Status.QUIZUPDATE.toString().split('.').last,
        'classId': classId,
        'quizList': quizs.map((quiz) => quiz.toJson()).toList(),
      }),
    );
  }

  //학생 -> 교육자 평가
  Future<void> studentEvaluation(int evaluation) async {
    stompClient?.send(
      destination: '/pub/classroom/$classId/message',
      body: json.encode({
        'status': Status.EVALUATION.toString().split('.').last,
        'classId': classId,
        'evaluation': evaluation,
      }),
    );
  }

  void listen(Null Function(dynamic message) param0) {}
}
//   //연결끊기
//   void disconnect() {
//     try {
//       unsubscribe(); // 구독 취소
//       stompClient?.deactivate();
//       print('연결 끊기 완료');
//     } catch (e) {
//       print('연결 끊기 실패: $e');
//     }
//   }
// }

// unsubscribeFn(unsubscribeHeaders: {});
// client.deactivate();
