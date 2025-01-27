import 'package:flutter/material.dart';
import '../model/seat_model.dart';

class Seat extends StatefulWidget {
  final int classId;
  const Seat({super.key, required this.classId});

  @override
  State<Seat> createState() => _SeatState();
}

class _SeatState extends State<Seat> {
  final SeatModel _seatModel = SeatModel();
  List<dynamic> loadedSeats = [];
  List<dynamic> nameList = [];
  bool isEditing = false;
  Map<String, dynamic>? firstSelectedSeat;
  List<dynamic> originalSeats = [];

  @override
  void initState() {
    super.initState();
    loadSeatTable(widget.classId);
    loadStudentNames();
  }

  Future<void> loadSeatTable(int classId) async {
    List<dynamic> result = await _seatModel.selectSeatTable(widget.classId);
    setState(() {
      loadedSeats = result.map((seat) => Map<String, dynamic>.from(seat)).toList();
      originalSeats = List.from(loadedSeats);
    });
    if(result.isEmpty){
      loadSeatTable(widget.classId);
    }
  }


  Future<void> loadStudentNames() async {
    List<dynamic> result = await _seatModel.studentNameAPI(widget.classId) as List;
    setState(() {
      nameList = List.from(result);
      nameList.sort((a, b) => a['studentId'].compareTo(b['studentId']));
    });
  }

  String getStudentNameByStudentId(int studentId) {
    var student = nameList.firstWhere(
          (student) => student['studentId'] == studentId,
      orElse: () => {'studentName': ''},
    );
    return student['studentName'];
  }

  @override
  Widget build(BuildContext context) {
    int maxColumn = loadedSeats.isNotEmpty
        ? loadedSeats.fold<int>(
        0, (max, seat) => seat['columnId'] > max ? seat['columnId'] : max)
        : 5;
    int maxRow = loadedSeats.isNotEmpty
        ? loadedSeats.fold<int>(
        0, (max, seat) => seat['rowId'] > max ? seat['rowId'] : max)
        : (nameList.length / maxColumn).ceil();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.table_restaurant_outlined, color: Colors.deepOrange, size: 30,),
            SizedBox(width: 10),
            Text("우리반 좌석 보기", style: TextStyle(fontFamily: "NamuL"),),
          ],
        ),
        backgroundColor: Color(0xFFFFEFB0),
        shape: Border(
          bottom: BorderSide(
            color: Colors.grey,
          ),
        ),
      ),
      backgroundColor: Color(0xFFFFEFB0),
      body: Column(
        children: [
          SizedBox(height: 90,),
          Center(
            child:  Center(
              child: Container(
                height: 40,
                width: 170,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Color(0xff205736),
                  borderRadius: BorderRadius.circular(0),
                  border: Border(
                      bottom: BorderSide(color: Colors.brown, width: 5)
                  ),
                ),
                child: Text(
                  "칠판",
                  style: TextStyle(fontSize: 16, color: Colors.white,fontFamily: "NamuL",),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
                padding: EdgeInsets.fromLTRB(30, 30, 30, 30),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: maxColumn,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                ),
                itemCount: maxColumn * maxRow,
                itemBuilder: (context, index) {
                  if (loadedSeats.isNotEmpty) {
                    int rowId = (index / maxColumn).floor() + 1;
                    int columnId = index % maxColumn + 1;
                    var seat = loadedSeats.firstWhere(
                          (seat) => seat['rowId'] == rowId && seat['columnId'] == columnId,
                      orElse: () => {
                        'rowId': -1,
                        'columnId': -1,
                        'studentId': -1,
                        'studentName': 'Unknown',
                      },
                    );
                    return buildSeatWidget(seat, isEditing);
                  } else {
                    if (index >= nameList.length) return SizedBox();
                    var student = nameList[index];
                    return Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: Color(0xfff1c555),
                      ),
                      child: Text(
                        student['studentName'],
                        style: TextStyle(fontWeight: FontWeight.bold,fontFamily: "NamuL",),
                      ),
                    );
                  }
                }
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSeatWidget(Map<String, dynamic>? seat, bool isEditing) {
    if (seat == null) {
      return Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white70,
          borderRadius: BorderRadius.circular(50),
        ),
        child: SizedBox(height: 30, width: 30),
      );
    }
    return GestureDetector(
      child: Container(
        height: 10,
        width: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: Color(0xfff1c555),
          border: Border.all(
            color: (firstSelectedSeat == seat) ? Colors.red : Colors.white70,
          ),
        ),
        child: Text(
          getStudentNameByStudentId(seat['studentId']),
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold,fontFamily: "NamuL",),
        ),
      ),
    );
  }
}
