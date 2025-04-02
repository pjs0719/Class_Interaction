import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spaghetti/Dialog/CicularProgress.dart';
import 'package:spaghetti/classroom/instructor/classroomService.dart';
import 'package:spaghetti/opinion/Opinion.dart';
import 'package:spaghetti/opinion/OpinionService.dart';

class AddClassDialog extends StatefulWidget {
  const AddClassDialog({super.key});

  @override
  _AddClassDialogState createState() => _AddClassDialogState();
}

class _AddClassDialogState extends State<AddClassDialog> {
  ScrollController? _scrollController;
  var className = "";
  List<String>? ops;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final opinionService =
          Provider.of<OpinionService>(context, listen: false);
      List<Opinion> opinionList = opinionService.opinionList;

      if (opinionList.isEmpty) {
        opinionService.addOpinion(opinion: Opinion(opinion: "수업속도가 빨라요"));
        opinionService.addOpinion(opinion: Opinion(opinion: "수업속도가 느려요"));
        opinionService.addOpinion(opinion: Opinion(opinion: "이해하지 못했어요"));
      }
    });
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ClassroomService, OpinionService>(
        builder: (context, classService, opinionService, child) {
      List<Opinion> opinionList = opinionService.opinionList;

      final mediaQuery = MediaQuery.of(context);
      final screenHeight = mediaQuery.size.height;
      final screenWidth = mediaQuery.size.width;

      // ClassroomService classroomService = new ClassroomService();
      return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        controller: _scrollController, // ScrollController 추가
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SizedBox(
            height: screenHeight * 0.7,
            width: double.infinity,
            child: PageView(
              children: [
                Container(
                  child: Stack(
                    children: [
                      if (isLoading) CircularProgress.build(),
                      Positioned(
                        left: screenWidth * 0.12,
                        top: screenHeight * 0.05,
                        child: Text('수업을 생성해주세요.',
                            style: TextStyle(fontSize: screenWidth * 0.05)),
                      ),
                      Positioned(
                        right: screenWidth * 0.1,
                        top: screenHeight * 0.1,
                        child: IconButton(
                          icon: Image.asset(
                            'assets/images/logout.png', // 이미지 경로
                            width: screenWidth * 0.08,
                            height: screenWidth * 0.08,
                          ),
                          iconSize: screenWidth * 0.08,
                          onPressed: () {},
                        ),
                      ),
                      Positioned(
                        left: screenWidth * 0.12,
                        top: screenHeight * 0.225,
                        child: Text('수업 의견을 생성해주세요.',
                            style: TextStyle(fontSize: screenWidth * 0.04)),
                      ),
                      Positioned(
                        left: screenWidth * 0.1,
                        top: screenHeight * 0.2,
                        child: Container(
                          height: 3,
                          width: screenWidth * 0.8,
                          color: Colors.black,
                        ),
                      ),
                      Positioned(
                        left: screenWidth * 0.1,
                        top: screenHeight * 0.11,
                        child: SizedBox(
                          width: screenWidth * 0.8,
                          height: screenHeight * 0.07,
                          child: TextField(
                            decoration: InputDecoration(
                              fillColor: Color(0xfff7f8fc),
                              filled: true,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              hintText: '수업명을 입력해주세요',
                            ),
                            onChanged: (value) {
                              className = value;
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        left: screenWidth * 0.675,
                        top: screenHeight * 0.21,
                        child: IconButton(
                          icon: Icon(Icons.add_circle_outline),
                          onPressed: () {
                            opinionService.addOpinion(
                                opinion: Opinion(opinion: ""));
                          },
                          iconSize: 35,
                          color: Color(0xff71cdcb),
                        ),
                      ),
                      Positioned(
                        left: screenWidth * 0.8,
                        top: screenHeight * 0.21,
                        child: IconButton(
                          icon: Icon(Icons.remove_circle_outline),
                          onPressed: () {
                            if (opinionList.isNotEmpty) {
                              opinionService
                                  .deleteOpinion(opinionList.length - 1);
                            }
                          },
                          iconSize: 35,
                          color: Color(0xfff9a3b6),
                        ),
                      ),
                      Positioned(
                        top: screenHeight * 0.225 + 40,
                        left: screenWidth * 0.1,
                        child: SizedBox(
                          width: screenWidth * 0.8,
                          height: screenHeight * 0.32,
                          child: Scrollbar(
                            thumbVisibility: false,
                            controller:
                                _scrollController, // ScrollController 추가
                            child: ListView.builder(
                              scrollDirection: Axis.vertical,
                              padding: EdgeInsets.zero, // ListView의 패딩을 없앰
                              itemCount: opinionList.length,
                              itemBuilder: (context, index) {
                                TextEditingController _controller =
                                    TextEditingController(
                                  text: opinionList[index]
                                      .opinion, // opinionList에서 값이 있으면 초기화
                                );

                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Container(
                                    alignment: Alignment.centerLeft,
                                    width: screenWidth * 0.8,
                                    height: screenHeight * 0.07,
                                    child: TextField(
                                      controller: _controller,
                                      onChanged: (value) {
                                        opinionService.updateOpinion(
                                            index, Opinion(opinion: value));
                                      },
                                      decoration: InputDecoration(
                                        fillColor: Color(0xfff7f8fc),
                                        filled: true,
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: BorderSide.none,
                                        ),
                                        hintText: '의견을 적어주세요',
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: screenWidth * 0.1,
                        top: screenHeight * 0.57 + 30,
                        child: SizedBox(
                          width: screenWidth * 0.8,
                          height: screenHeight * 0.06, // 화면 너비의 80%
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xff789ad0),
                              surfaceTintColor: Color(0xff789ad0),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              setState(() {
                                isLoading = true;
                              });
                              await classService.classroomCreate(
                                  context,
                                  className,
                                  opinionList,
                                  opinionService); //??:의견 추가안했을 때는 빈 배열
                              setState(() {
                                isLoading = false;
                              });
                              Navigator.pop(context);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "수업 생성하기",
                                  style: TextStyle(color: Colors.white),
                                ),
                                Text(
                                  "+",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
