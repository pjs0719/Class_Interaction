import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spaghetti/Dialog/CicularProgress.dart';
import 'package:spaghetti/classroom/classroom.dart';
import 'package:spaghetti/classroom/instructor/classroomService.dart';
import 'package:spaghetti/classroom/student/Enrollment.dart';
import 'package:spaghetti/classroom/student/EnrollmentService.dart';
import 'package:spaghetti/classroom/student/classEnterPage.dart';
import 'package:spaghetti/classroom/instructor/classCreatePage.dart';
import 'package:spaghetti/login/AuthService.dart';
import 'package:spaghetti/member/User.dart';
import 'package:spaghetti/member/UserProvider.dart';
import '../main/startPage.dart';
import '../login/joinMember.dart';

class LoginPage extends StatefulWidget {
  final String role;

  const LoginPage({super.key, required this.role});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isObscure = true;
  String errorMessage = "";
  bool isLoading = false;
  bool _showPasswordField = false;

  @override
  Widget build(BuildContext context) {
    String name;

    if (widget.role == "student") {
      name = "학생님";
    } else {
      name = "교수님";
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.0), // 앱바 높이 줄이기
        child: AppBar(
          backgroundColor: Colors.white, // 앱바 색상 흰색으로 설정
          elevation: 0, // 그림자 제거
          leading: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StartPage(),
                ),
              );
            },
            icon: Icon(Icons.arrow_back_rounded, color: Colors.black),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bottomInset = MediaQuery.of(context).viewInsets.bottom;
          final isKeyboardVisible = bottomInset > 0;

          return Stack(
            children: [
              if (isLoading) CircularProgress.build(),
              AnimatedPositioned(
                duration: Duration(milliseconds: 300),
                top: isKeyboardVisible ? 10 : 50,
                left: 30,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('수업은 언제나',
                        style:
                            TextStyle(fontSize: 20, color: Color(0xff696868))),
                    Text('Edu Connect', style: TextStyle(fontSize: 25)),
                    Text('$name, 반가워요!',
                        style:
                            TextStyle(fontSize: 17, color: Color(0xff696868))),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 210.0), // 이 값을 조정하여 높이를 내릴 수 있습니다.
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!_showPasswordField)
                          TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              labelText: '아이디',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            style: TextStyle(
                              fontFamily: 'NanumB',
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                        if (_showPasswordField)
                          AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            child: TextField(
                              controller: passwordController,
                              obscureText: _isObscure,
                              decoration: InputDecoration(
                                labelText: '비밀번호',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isObscure
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isObscure = !_isObscure;
                                    });
                                  },
                                ),
                              ),
                              style: TextStyle(
                                fontFamily: 'NanumB',
                              ),
                            ),
                          ),
                        if (errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              errorMessage,
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple[400],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed:
                                _showPasswordField ? _handleLogin : _checkEmail,
                            child: Text(
                              _showPasswordField ? '로그인' : '다음',
                              style: TextStyle(
                                fontFamily: 'NanumB',
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Joinmember(),
                              ),
                            );
                          },
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: RichText(
                              text: TextSpan(
                                text: "계정이 없으신가요? ",
                                style: TextStyle(
                                    fontSize: 13, color: Colors.black),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: "가입하기",
                                    style: TextStyle(
                                        fontSize: 13, color: Colors.blue),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  bool _validateEmail(String email) {
    // 이메일 형식 체크
    final emailRegex = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    return emailRegex.hasMatch(email);
  }

  void _checkEmail() async {
    setState(() {
      errorMessage = "";
    });

    var email = emailController.text;

    if (!_validateEmail(email)) {
      setState(() {
        errorMessage = "유효한 이메일 주소를 입력하세요";
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    // 이메일 체크 요청
    var response = await AuthService(context).checkEmail(email);
    setState(() {
      isLoading = false; // 로딩 종료
    });

    if (response.statusCode == 200) {
      // 성공하면 비밀번호 필드를 보여주기
      setState(() {
        _showPasswordField = true;
        errorMessage = ""; // 에러 메시지 초기화
      });
    } else {
      setState(() {
        errorMessage = "이메일을 확인하세요";
      });
    }
  }

  void _handleLogin() async {
    setState(() {
      isLoading = true;
    });
    var email = emailController.text;
    var password = passwordController.text;

    // 로그인 요청
    var response =
        await AuthService(context).login(email, password, widget.role);
    setState(() {
      isLoading = false; // 로딩 종료
    });
    if (response.statusCode == 200) {
      User user = AuthService(context).parseUser(json.decode(response.body));
      Provider.of<UserProvider>(context, listen: false).setUser(user);
      if (user.role != widget.role) {
        setState(() {
          errorMessage = user.role == "instructor"
              ? "교수 계정 입니다 교수페이지에서 로그인 하세요"
              : "학생 계정 입니다 학생페이지에서 로그인 하세요";
        });
      } else {
        if (widget.role == "student") {
          List<Enrollment> enrollments = AuthService(context)
                  .parseEnrollments(json.decode(response.body)) ??
              [];
          Provider.of<EnrollmentService>(context, listen: false)
              .setEnrollList(enrollments);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ClassEnterPage()),
          );
        } else {
          List<Classroom> classrooms = AuthService(context)
                  .parseClassrooms(json.decode(response.body)) ??
              [];
          Provider.of<ClassroomService>(context, listen: false)
              .setClassrooms(classrooms);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ClassCreatePage()),
          );
        }
      }
    } else {
      setState(() {
        errorMessage = "이메일 또는 비밀번호를 확인하세요";
      });
    }
  }
}
