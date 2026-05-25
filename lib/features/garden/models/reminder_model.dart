class ReminderModel {
  final int id;
  final String type;
  final String triggerTime;
  final String repeatDays;
  final bool isActive;
  final int plantId;
  final String? lastPerformed;
  final String? nextExecution;

  ReminderModel({
    required this.id,
    required this.type,
    required this.triggerTime,
    required this.repeatDays,
    required this.isActive,
    required this.plantId,
    this.lastPerformed,
    this.nextExecution,
  });

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      type: json['type'] ?? '',
      triggerTime: json['triggerTime'] ?? '',
      repeatDays: json['repeatDays'] ?? '',
      isActive: json['isActive'] ?? json['active'] ?? true,
      plantId: json['plantId'] is int ? json['plantId'] : int.tryParse(json['plantId'].toString()) ?? 0,
      lastPerformed: json['lastPerformed'],
      nextExecution: json['nextExecution'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'triggerTime': triggerTime,
      'repeatDays': repeatDays,
      'isActive': isActive,
      'plantId': plantId,
      'lastPerformed': lastPerformed,
      'nextExecution': nextExecution,
    };
  }
}
