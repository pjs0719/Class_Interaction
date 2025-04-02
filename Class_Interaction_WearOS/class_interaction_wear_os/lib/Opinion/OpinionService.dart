import 'package:class_interaction_wear_os/Opinion/Opinion.dart';
import 'package:class_interaction_wear_os/Opinion/OpinionVote.dart';
import 'package:flutter/material.dart';

class OpinionService extends ChangeNotifier {
  List<Opinion> opinionList = [];
  List<OpinionVote> countList = []; //투표 인원 수
  bool opinionSend = true; // 투표 1회만

  void setOpinionList(List<Opinion>? opList) {
    if (opList != null) {
      opinionList = opList;
    }
    notifyListeners();
  }

  //의견제출버튼 true or false 동작
  void setOpinionSend(bool value) {
    opinionSend = value;
    notifyListeners();
  }

  OpinionService() {
    updateCountList();
  }

  // 투표 수량 초기화
  void updateCountList() {
    countList = opinionList
        .map((opinion) => OpinionVote(opinionId: opinion.opinionId, count: 0))
        .toList();
    notifyListeners();
  }

  void addOpinion({required Opinion opinion}) {
    opinionList.add(opinion);
    countList.add(
        OpinionVote(opinionId: opinion.opinionId, count: 0)); // 기본 투표 수를 0으로 설정
    notifyListeners();
  }

  void updateOpinion(int index, Opinion op) {
    opinionList[index] = op;
    countList[index] = OpinionVote(opinionId: op.opinionId, count: 0);
    notifyListeners();
  }

  void voteAdd(Opinion? opinion) {
    for (int i = 0; i < countList.length; i++) {
      if (countList[i].opinionId == opinion?.opinionId) {
        countList[i].count += 1;
        break;
      }
    }
    notifyListeners();
  }

  void deleteOpinion(int index) {
    opinionList.removeAt(index);
    countList.removeAt(index); // countList에서도 해당 항목을 제거
    notifyListeners();
  }

  void deleteAll() {
    opinionList.clear();
    countList.clear();
    notifyListeners();
  }

  //의견,투표 배열 전체 삭제
  void initializeOpinionList() {
    opinionList.clear();
    countList.clear();
    notifyListeners();
  }

  int maxCount(List<OpinionVote> opinion) {
    int maxIndex = 0;
    for (int i = 1; i < opinion.length; i++) {
      if (opinion[i].count > opinion[maxIndex].count) {
        maxIndex = i;
      }
    }
    return maxIndex;
  }
}
