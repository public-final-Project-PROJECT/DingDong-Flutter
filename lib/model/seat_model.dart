import 'package:dio/dio.dart';

class seatModel {

  // 좌석 테이블에서 저장된 좌석 조회 api
  Future<List<dynamic>> selectSeatTable(int classId) async {
    final dio = Dio();

    print("좌석 테이블에서 저장된 좌석 조회 api");
    try {
      final response = await dio.post(
          "http://112.221.66.174:3013/api/seat/findAllSeat",
          data: {'classId': 2});
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      }
      // else {
      //   if(response.data == null){
      //     selectStudentsTable(2);
      //   }
      //   throw Exception("로드 실패");
      // }
      throw Exception("로드 실패 !");
    } catch (e) {
      print(e);
      throw Exception("Error 좌석 조회 중 : $e");
    }
  }

  // // 좌석저장이 없을 시 학생테이블 조회 api
  // Future<List<dynamic>> selectStudentsTable(int classId) async {
  //   final dio = Dio();
  //
  //   print("좌석저장이 없을 시 학생테이블 조회 api");
  //   try {
  //     final response = await dio.post(
  //         "http://112.221.66.174:3013/api/seat/findName",
  //         data: {'classId': 2});
  //     if (response.statusCode == 200) {
  //       print("학생테이블 조회임 : " + response.data);
  //       return response.data as List<dynamic>;
  //     } else {
  //       throw Exception("로드 실패");
  //     }
  //   } catch (e) {
  //     print(e);
  //     throw Exception("Error : $e");
  //   }
  // }




  // 이름 조회 api
  Future<List<dynamic>?> studentNameAPI()async{
    final dio = Dio();
    print("학생 이름 조회 api");

    try{
      final response = await dio.post(
        "http://112.221.66.174:3013/api/seat/findName",
        data: {'classId': 2},
      );
      if (response.statusCode == 200) {
        print("이름 조회임  :: " + response.data.toString());
        return response.data as List<dynamic>;
      }
    }catch(e) {
      print(e);
      throw Exception("Error : $e");
    }
  }
}