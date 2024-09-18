import 'package:wheres_that_movie/api/models/show_model.dart';

class ShowCastCredit {
  final Show show;
  final String character;
  final int? order;

  const ShowCastCredit({
    required this.show,
    required this.character,
    required this.order,
  });
  factory ShowCastCredit.fromJson(Map<String, dynamic> json) {
    return ShowCastCredit(
      show: Show.fromJson(json),
      character: json['character'],
      order: json['order'],
    );
  }
}

class ShowCrewCredit {
  final Show show;
  final String department;
  final String job;

  const ShowCrewCredit({
    required this.show,
    required this.department,
    required this.job,
  });
  factory ShowCrewCredit.fromJson(Map<String, dynamic> json) {
    return ShowCrewCredit(
      show: Show.fromJson(json),
      department: json['department'],
      job: json['job'],
    );
  }
}
