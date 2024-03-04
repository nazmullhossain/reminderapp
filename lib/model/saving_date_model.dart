import 'dart:convert';

List<SavingDateModel> savingDateModelFromJson(String str) =>
    List<SavingDateModel>.from(
        json.decode(str).map((x) => SavingDateModel.fromJson(x)));

String savingDateModelToJson(List<SavingDateModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SavingDateModel {
  final int? id;
  final String? savingDateTime;

  SavingDateModel({
    this.id,
    this.savingDateTime,
  });

  factory SavingDateModel.fromJson(Map<String, dynamic> json) =>
      SavingDateModel(
        id: json["id"],
        savingDateTime: json["savingDateTime"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "savingDateTime": savingDateTime,
      };
}
