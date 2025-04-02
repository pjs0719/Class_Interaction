import 'package:class_interaction_wear_os/classroom.dart';

class Opinion {
  String opinionId;
  String opinion;
  Classroom? classroom;

  Opinion({
    this.opinionId = "",
    required this.opinion,
    this.classroom,
  });

  Map<String, dynamic> toJson() => {
        'opinionId': opinionId,
        'opinion': opinion,
        'classroom': classroom?.toJson(),
      };

  factory Opinion.fromJson(Map<String, dynamic> json) {
    return Opinion(
      opinionId: json['opinionId'] ?? "",
      opinion: json['opinion'] ?? "",
      classroom: Classroom.fromJson_notArray(json['classroom']),
    );
  }
}
