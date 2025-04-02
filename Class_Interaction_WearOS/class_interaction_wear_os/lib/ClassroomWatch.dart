import 'dart:io';

import 'package:class_interaction_wear_os/Opinion/Opinion.dart';
import 'package:class_interaction_wear_os/Opinion/OpinionService.dart';
import 'package:class_interaction_wear_os/Opinion/OpinionVote.dart';
import 'package:class_interaction_wear_os/Websocket/Websocket.dart';
import 'package:class_interaction_wear_os/classroom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

class Classroomwatch extends StatefulWidget {
  String classId;
  Classroomwatch(this.classId, {super.key});

  @override
  State<Classroomwatch> createState() => _Classroomwatch();
}

class _Classroomwatch extends State<Classroomwatch> {
  Websocket? websocket;
  String? jwt;
  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _initializeWebsocket();
  }

  Future<void> _initializeWebsocket() async {
    String classId = widget.classId;
    jwt = await storage.read(key: "Authorization") ?? "";
    websocket = await Websocket(classId, jwt, context);
  }

  @override
  void dispose() async {
    await websocket?.unsubscribe();
    websocket?.stomClient(jwt, context).deactivate(); // websocket 연결 해제
    Provider.of<OpinionService>(context, listen: false).deleteAll();
    super.dispose();
  }

  final List<Color> _colors = [
    Color(0xff7b9bcf),
    Color(0xfff5c369),
    Color(0xffa4d3fb),
    Color(0xfff7a3b5),
    Color(0xfffcb29c),
    Color(0xffcab3e7),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        visualDensity: VisualDensity.compact,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20.0), // 가로 여백 설정
          child: Consumer<OpinionService>(
              builder: (context, opinionService, child) {
            List<Opinion> opinionList = opinionService.opinionList; // 옵션 배열
            List<OpinionVote> opinionCount = opinionService.countList;

            if (opinionList.isNotEmpty) {
              // Combine the opinions and their counts into a single list
              List<Map<String, dynamic>> combinedList = List.generate(
                opinionList.length,
                (index) => {
                  'opinion': opinionList[index],
                  'count': opinionCount[index]
                },
              );

              // Sort the combined list based on counts in descending order
              combinedList
                  .sort((a, b) => b['count'].count.compareTo(a['count'].count));

              return ListView.builder(
                itemCount: combinedList.length,
                itemBuilder: (context, index) {
                  Opinion opinion = combinedList[index]['opinion'];
                  OpinionVote count = combinedList[index]['count'];
                  return Card(
                    color: _colors[index % _colors.length],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    elevation: 5,
                    child: ListTile(
                      title: Center(
                        child: Text(
                          "${opinion.opinion} : ${count.count}",
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ),
                  );
                },
              );
            } else {
              return Center(
                child: Text(
                  "의견이없습니다",
                  style: TextStyle(color: Colors.white),
                ),
              );
            }
          }),
        ),
      ),
    );
  }
}
