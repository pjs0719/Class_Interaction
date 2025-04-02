import 'dart:async';
import 'package:class_interaction_wear_os/Apiurl.dart';
import 'package:class_interaction_wear_os/Enter.dart';
import 'package:class_interaction_wear_os/Opinion/Opinion.dart';
import 'package:class_interaction_wear_os/Opinion/OpinionService.dart';
import 'package:class_interaction_wear_os/Websocket/Dialogs.dart';
import 'package:class_interaction_wear_os/Websocket/MessageDTO.dart';
import 'package:class_interaction_wear_os/member/User.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'dart:convert';

class Websocket {
  late String classId;
  String? jwt;
  StompClient? stompClient;
  late User? user;
  dynamic unsubscribe;
  late BuildContext context;

  // late BuildContext context;
  Websocket(this.classId, this.jwt, this.context) {
    stompClient = stomClient(jwt, context);
    stompClient?.activate();
  }

  StompClient stomClient(String? jwt, context) {
    return StompClient(
      config: StompConfig.sockJS(
        url: '${Apiurl().url}/classroomEnter',
        onConnect: (StompFrame frame) => onConnect(frame, context),
        beforeConnect: () async {
          print('waiting to connect...');
          await Future.delayed(const Duration(milliseconds: 2000));
          print('connecting...');
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
          'Authorization': jwt ?? "",
        },
      ),
    );
  }

  Future<void> onConnect(StompFrame frame, context) async {
    unsubscribe = stompClient!.subscribe(
      destination: '/sub/classroom/$classId',
      callback: (frame) async {
        Map<String, dynamic> json = jsonDecode(frame.body ?? "");
        print("수신 json:");
        print(json);
        MessageDTO message = MessageDTO.fromJson(json);
        switch (message.status) {
          case Status.OPINION:
            if (message.opinion?.opinionId != null) {
              Provider.of<OpinionService>(context, listen: false)
                  .voteAdd(message.opinion);
            }
            break;
          case Status.OPINIONUPDATE:
            Provider.of<OpinionService>(context, listen: false).deleteAll();
            if (message.opList!.isNotEmpty) {
              for (int i = 0; i < message.opList!.length; i++) {
                Provider.of<OpinionService>(context, listen: false)
                    .addOpinion(opinion: message.opList![i]);
              }
            }
            break;
          case Status.OPINIONINITIALIZE:
            Provider.of<OpinionService>(context, listen: false)
                .updateCountList();
            break;
          case Status.CLOSE:
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => Enter()),
              (Route<dynamic> route) => false,
            );
            break;
          default:
            print("예외문제 확인용(default switch문) ${message.status}");
            break;
        }
      },
    );
  }
}
