import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/reminder_model.dart';

class ReminderRepository {
  final Dio _dio = ApiClient.instance;

  Future<List<ReminderModel>> getRemindersByGarden(int gardenId) async {
    final response = await _dio.get('${ApiConstants.gardens}/$gardenId/reminders');
    return (response.data as List)
        .map((json) => ReminderModel.fromJson(json))
        .toList();
  }

  Future<List<ReminderModel>> getRemindersByPlant(int plantId) async {
    final response = await _dio.get('${ApiConstants.plants}/$plantId/reminders');
    return (response.data as List)
        .map((json) => ReminderModel.fromJson(json))
        .toList();
  }

  Future<ReminderModel> createReminder(int plantId, Map<String, dynamic> data) async {
    final response = await _dio.post('${ApiConstants.plants}/$plantId/reminders', data: data);
    return ReminderModel.fromJson(response.data);
  }

  Future<ReminderModel> updateReminder(int reminderId, Map<String, dynamic> data) async {
    final response = await _dio.put('${ApiConstants.reminders}/$reminderId', data: data);
    return ReminderModel.fromJson(response.data);
  }

  Future<void> deleteReminder(int reminderId) async {
    await _dio.delete(
      '${ApiConstants.reminders}/$reminderId',
      options: Options(responseType: ResponseType.plain),
    );
  }
}
