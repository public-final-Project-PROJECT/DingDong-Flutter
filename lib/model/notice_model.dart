import 'package:dio/dio.dart';

class NoticeModel {

  Future<List<dynamic>> searchNotice({String? category}) async {
    final dio = Dio();
    try {
      final response = await dio.get(
        "http://112.221.66.174:3013/api/notice/view",
        queryParameters: {
          'classId': 1,
          if (category != null) 'noticeCategory': category,
        },
      );
      return response.data as List<dynamic>;
    } catch (e) {
      print(e);
      throw Exception("Error: $e");
    }
  }
}