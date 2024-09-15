import 'dart:convert';

List<SavingDateModel> savingDateModelFromJson(String str) =>
    List<SavingDateModel>.from(
        jsonDecode(str).map((x) => SavingDateModel.fromJson(x)));

String savingDateModelToJson(List<SavingDateModel> data) =>
    jsonEncode(List<dynamic>.from(data.map((x) => x.toJson())));

class SavingDateModel {
  final int? id;
  final String? savingDateTime;
  final bool? isAlarm;

  SavingDateModel({
    this.id,
    this.savingDateTime,
    this.isAlarm,
  });

  factory SavingDateModel.fromJson(Map<String, dynamic> json) =>
      SavingDateModel(
        id: json["id"],
        savingDateTime: json["savingDateTime"],
        isAlarm: json["isAlarm"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "savingDateTime": savingDateTime,
        'isAlarm': isAlarm,
      };



     // Map<String, dynamic> toJson() => {
     //    "id": id,
     //    "savingDateTime": savingDateTime,
     //    'isAlarm': isAlarm,
     //  };
}
