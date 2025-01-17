import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:intl/intl.dart';
import 'package:lastdance_f/model/notice_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class NoticeDetailpage extends StatefulWidget {
  final dynamic noticeId;

  const NoticeDetailpage({super.key, required this.noticeId});

  @override
  State<NoticeDetailpage> createState() => _NoticeDetailpageState();
}

class _NoticeDetailpageState extends State<NoticeDetailpage> {
  static bool isInitialized = false;
  NoticeModel _noticeModel = NoticeModel();
  List<dynamic> noticeList = [];

  @override
  void initState() {
    super.initState();
    _loadNoticeDetail();
    if (!isInitialized) {
      FlutterDownloader.initialize(debug: true);
      isInitialized = true;
    }
  }

  void _loadNoticeDetail() async {
    print(widget.noticeId);
    List<dynamic> noticeData = await _noticeModel.searchNoticeDetail(widget.noticeId);
    setState(() {
      noticeList = noticeData;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (noticeList.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text("공지사항"),
          backgroundColor: Color(0xffF4F4F4),
          shape: const Border(
              bottom: BorderSide(
                color: Colors.grey,
                width: 1,
              )),
        ),
        backgroundColor: Color(0xffF4F4F4),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final notice = noticeList[0];
    String formattedCreateAt = _formatDate(notice['createdAt']);
    String formattedUpdatedAt = _formatDate(notice['updatedAt']);

    String displayDate = "";
    if (notice['updatedAt'] != null &&
        notice['updatedAt'].isNotEmpty &&
        notice['createdAt'] != notice['updatedAt']) {
      formattedUpdatedAt = _formatDate(notice['updatedAt']);
      displayDate = "수정일: $formattedUpdatedAt";
    } else {
      formattedCreateAt = _formatDate(notice['createdAt']);
      displayDate = "작성일: $formattedCreateAt";
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("공지사항"),
        backgroundColor: Color(0xffF4F4F4),
        shape: const Border(
            bottom: BorderSide(
              color: Colors.grey,
              width: 1,
            )),
      ),
      backgroundColor: Color(0xffF4F4F4),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${notice['noticeTitle']}",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                if (notice['noticeFile'] != null)
                  ElevatedButton.icon(
                    onPressed: () async {
                      String fileUrl =
                          "http://112.221.66.174:3013/download${notice['noticeFile']}";
                      await _downloadFile(fileUrl, context);
                    },
                    icon: Icon(Icons.file_download),
                    label: Text("첨부 파일"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff515151),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        )),
                  ),
              ],
            ),
            Text(displayDate),
            Text("${notice['noticeCategory']}"),
            SizedBox(height: 8),
            Container(
              width: 393,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1,
                    strokeAlign: BorderSide.strokeAlignCenter,
                    color: Color(0xFFB8B8B8),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8),

            // 이미지 섬네일 표시
            if (notice['noticeImg'] != null && notice['noticeImg'].isNotEmpty)
              Image.network(
                "http://112.221.66.174:3013${notice['noticeImg']}",
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
              ),
            SizedBox(height: 8),

            Text("${notice['noticeContent']}"),
            SizedBox(height: 8),

            if (notice['noticeFile'] != null && notice['noticeFile'].isNotEmpty)
              Container(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.all(8.0),
                child: Text(
                  getFileName("${getFileName(notice['noticeFile'])}"),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadFile(String fileUrl, BuildContext context) async {
    try {
      if (await Permission.storage.request().isGranted) {
        final externalDirs = await getExternalStorageDirectories();
        if (externalDirs == null || externalDirs.isEmpty) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('외부 저장소를 찾을 수 없습니다.')));
          return;
        }

        final downloadsDirectory = Directory('/storage/emulated/0/Download');
        print("다운로드 위치: ${downloadsDirectory.path}");
        if (!downloadsDirectory.existsSync()) {
          downloadsDirectory.createSync(recursive: true);
        }

        final taskId = await FlutterDownloader.enqueue(
          url: fileUrl,
          savedDir: downloadsDirectory.path,
          showNotification: true,
          openFileFromNotification: true,
          saveInPublicStorage: true,
        );

        print("다운로드 완료: $taskId");
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('다운로드가 완료되었습니다.')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('저장소 권한을 허용해주세요.')));
      }
    } catch (e) {
      print("파일 다운로드 중 오류 발생: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('파일 다운로드 중 오류가 발생했습니다: $e')));
    }
  }

  String _formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    String formattedDate = DateFormat('yyyy.MM.dd').format(dateTime);
    return formattedDate;
  }

  String getFileName(String filePath) {
    String fileName = filePath.split('/').last;

    String processedFileName;
    if (fileName.contains('%')) {
      processedFileName = Uri.encodeFull(fileName);
    } else {
      processedFileName = fileName;
    }

    int underscoreIndex = processedFileName.indexOf('_');
    if (underscoreIndex != -1) {
      return processedFileName.substring(underscoreIndex + 1);
    } else {
      return processedFileName;
    }
  }
}
