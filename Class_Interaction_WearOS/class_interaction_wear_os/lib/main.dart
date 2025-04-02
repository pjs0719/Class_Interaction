import 'package:class_interaction_wear_os/Enter.dart';
import 'package:class_interaction_wear_os/Opinion/OpinionService.dart';
import 'package:class_interaction_wear_os/classroomService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Opinion/OpinionService.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => OpinionService()),
      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Enter(),
          theme: ThemeData(
            scaffoldBackgroundColor: Colors.black,
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.black, // AppBar 배경색을 흰색으로 설정
            ),
          )),
    );
  }
}
