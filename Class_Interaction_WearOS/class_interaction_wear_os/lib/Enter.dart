import 'package:class_interaction_wear_os/Websocket/Dialogs.dart';
import 'package:class_interaction_wear_os/classroom.dart';
import 'package:class_interaction_wear_os/classroomService.dart';
import 'package:class_interaction_wear_os/classroomWatch.dart';
import 'package:class_interaction_wear_os/service.dart';
import 'package:flutter/material.dart';

class Enter extends StatefulWidget {
  @override
  _EnterState createState() => _EnterState();
}

class _EnterState extends State<Enter> {
  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    String value = "";
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        visualDensity: VisualDensity.compact,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Center(
              child: Text('수업 입장', style: TextStyle(color: Colors.white))),
          backgroundColor: Colors.black,
        ),
        backgroundColor: Colors.black, // 배경색을 검정으로 설정
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontSize: 10, color: Colors.white), // 텍스트 색상 변경
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0), // 라운드 처리
                  ),
                  hintText: '수업 코드 입력',
                  hintStyle: TextStyle(color: Colors.white),
                  labelStyle: TextStyle(color: Colors.white), // 라벨 색상 변경
                  filled: true,
                  fillColor: Colors.grey[800], // 텍스트 박스 배경색 설정
                ),
                onChanged: (text) {
                  value = text;
                },
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  if (value == "") {
                    Dialogs.showErrorDialog(context, "수업 입력");
                  }
                  var response = await Service(context).getInfo(value);
                  // var response = "abs";
                  if (response?.statusCode == 200) {
                    var classroomService = ClassroomService();
                    Classroom? classroom = await classroomService
                        .studentEnterClassPin(context, value);
                    setState(() {
                      value = "";
                    });
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                Classroomwatch(classroom!.classId)));
                  } else {
                    print("핀번호 틀렸습니다 에러처리 ");
                  }
                },
                child: Text(
                  '수업입장',
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0), // 버튼 라운드 처리
                  ),
                  backgroundColor: Color(0xfffbaf01), // 버튼 배경색
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
