import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lastdance_f/model/student_model.dart';
import 'package:permission_handler/permission_handler.dart';

class MyPageUpdate extends StatefulWidget {
  final Map<String, dynamic> studentData;

  const MyPageUpdate({super.key, required this.studentData});

  @override
  State<MyPageUpdate> createState() => _MyPageUpdateState();
}

class _MyPageUpdateState extends State<MyPageUpdate> {
  final StudentModel _studentModel = StudentModel();

  late TextEditingController _nameController;
  late TextEditingController _birthController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _studentEtcController;
  late TextEditingController _parentsNameController;
  late TextEditingController _parentsPhoneController;
  late TextEditingController _studentGenderController;

  File? _selectedImage;
  String? beforeImg;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.studentData['studentName'] ?? '');
    _birthController = TextEditingController(text: widget.studentData['studentBirth'] ?? '');
    _phoneController = TextEditingController(text: widget.studentData['studentPhone'] ?? '');
    _addressController = TextEditingController(text: widget.studentData['studentAddress'] ?? '');
    _studentEtcController = TextEditingController(text: widget.studentData['studentEtc'] ?? '');
    _parentsNameController = TextEditingController(text: widget.studentData['parentsName'] ?? '');
    _parentsPhoneController = TextEditingController(text: widget.studentData['parentsPhone'] ?? '');
    _studentGenderController = TextEditingController(text: widget.studentData['studentGender'] ?? '');

    if (widget.studentData['studentImg'] != null) {

      beforeImg = widget.studentData['studentImg'];

    }
  }

  Future<void> _pickImage() async {
    await _checkPermission(Permission.photos);

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && pickedFile.path.isNotEmpty) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("이미지를 선택할 수 없습니다.")),
      );
    }
  }

  Future<void> _checkPermission(Permission permission) async {
    PermissionStatus permissionStatus = await permission.status;
    if (!permissionStatus.isGranted) {
      permissionStatus = await permission.request();
      if (!permissionStatus.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("갤러리 접근 권한이 필요합니다.")),
        );
        openAppSettings();
      }
    }
  }



  Future<void> _saveChanges() async  {
    String studentImgPath = _selectedImage != null ? _selectedImage!.path : '';
    Map<String, dynamic> updatedData = {
      'studentName': _nameController.text,
      'studentBirth': _birthController.text,
      'studentPhone': _phoneController.text,
      'studentAddress': _addressController.text,
      'studentEtc': _studentEtcController.text,
      'parentsName': _parentsNameController.text,
      'parentsPhone': _parentsPhoneController.text,
      'studentGender': _studentGenderController.text,
      'studentImg': studentImgPath,
      'studentId': widget.studentData['studentId']
    };

    try {
      final dio = Dio();
      FormData formData = FormData.fromMap({
        'studentName': updatedData['studentName'],
        'studentBirth': updatedData['studentBirth'],
        'studentPhone': updatedData['studentPhone'],
        'studentAddress': updatedData['studentAddress'],
        'studentEtc': updatedData['studentEtc'],
        'parentsName': updatedData['parentsName'],
        'parentsPhone': updatedData['parentsPhone'],
        'studentGender': updatedData['studentGender'],
        'studentId': updatedData['studentId'],
        if (_selectedImage != null)
          'studentImg': await MultipartFile.fromFile(_selectedImage!.path),
      });

      Response response = await dio.post(
        'http://112.221.66.174:6892/api/students/register/${updatedData['studentId']}',
        data: formData,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("메모 업데이트 성공")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("업데이트 실패")),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("업데이트 중 오류가 발생했습니다.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("학생 정보 수정"),
        backgroundColor: const Color(0xffF4F4F4),
      ),
      backgroundColor: const Color(0xffF4F4F4),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Column(
              children: [
                if (_selectedImage != null)
                  Image.file(
                    _selectedImage!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  )
                else if (beforeImg != null)
                  Image.network(
                    "http://112.221.66.174:6892$beforeImg",
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  )
                else
                  Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[300],
                    child: Icon(Icons.image, color: Colors.grey[700]),
                  ),
                ElevatedButton(
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff515151),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text("프로필 변경"),
                ),
              ],
            ),
            _buildTextField("이 름", _nameController, isEnabled: false),
            _buildTextField("성별", _studentGenderController),
            _buildTextField("생년월일", _birthController),
            _buildTextField("핸드폰", _phoneController),
            _buildTextField("주소", _addressController),
            _buildTextField("보호자", _parentsNameController),
            _buildTextField("보호자 번호", _parentsPhoneController),
            _buildTextField("특이사항", _studentEtcController),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff515151),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text("저장"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isEnabled = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextField(
        controller: controller,
        enabled: isEnabled,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }
}