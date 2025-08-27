import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hazodashborad/Core/res/Service/AuthService.dart';
import 'package:hazodashborad/Core/res/Service/UserService.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UploadSplash extends StatefulWidget {
  const UploadSplash({super.key});

  @override
  State<UploadSplash> createState() => _UploadSplashState();
}

class _UploadSplashState extends State<UploadSplash> {

  static const String _fieldName = 'files';

  List<Uint8List> _images = [];
  Set<int> _selectedIndexes = {};
  bool _isUploading = false;

  Future<void> _pickImages() async {
    final bytesFromPicker = await ImagePickerWeb.getMultiImagesAsBytes();
    if (bytesFromPicker != null) {
      setState(() {
        _images = bytesFromPicker;
        _selectedIndexes.clear();
      });
    }
  }

  void _toggleSelect(int index) {
    setState(() {
      if (_selectedIndexes.contains(index)) {
        _selectedIndexes.remove(index);
      } else {
        _selectedIndexes.add(index);
      }
    });
  }


  Future<void> _uploadSelectedPhotos() async {
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No images to upload')),
      );
      return;
    }

    // إذا ما حددت صور، يرفع الكل
    final indices = _selectedIndexes.isEmpty
        ? List<int>.generate(_images.length, (i) => i)
        : _selectedIndexes.toList()..sort();

    final selectedBytes = [for (final i in indices) _images[i]];

    setState(() => _isUploading = true);

    try {
      final token = await AuthService().getToken();
      final res = await UserService().uploadPhotosBytes(
        token: token!,
        bytesList: selectedBytes,
        fieldName: _fieldName, // غيّر لـ 'photos' إذا لزم
      );

      // نجاح
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Uploaded ${selectedBytes.length} image(s) successfully')),
      );

      // خيار: تفريغ التحديد بعد الرفع
      setState(() => _selectedIndexes.clear());
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = _selectedIndexes.length;
    final canUpload = _images.isNotEmpty && !_isUploading;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text("Upload Splash - Multi Images"),
        backgroundColor: const Color(0xFF5B8DEF),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B8DEF),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isUploading ? null : _pickImages,
              icon: const Icon(Icons.photo_library_outlined, color: Colors.white),
              label: const Text("Pick images from gallery", style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: _images.isEmpty
                ? const Center(
                    child: Text(
                      "No images selected.",
                      style: TextStyle(color: Color(0xFF5B8DEF), fontSize: 18),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: _images.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, i) {
                      final isSelected = _selectedIndexes.contains(i);
                      return GestureDetector(
                        onTap: () => _toggleSelect(i),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.memory(
                                _images[i],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                            if (isSelected)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.35),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: const Center(
                                    child: CircleAvatar(
                                      radius: 26,
                                      backgroundColor: Colors.white,
                                      child: Icon(Icons.check, size: 36, color: Color(0xFF5B8DEF)),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Center(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B8DEF),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: canUpload ? _uploadSelectedPhotos : null,
              icon: _isUploading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.cloud_upload_outlined, color: Colors.white),
              label: Text(
                _isUploading
                    ? 'Uploading...'
                    : (selectedCount > 0 ? 'Upload ($selectedCount selected)' : 'Upload All'),
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
          const SizedBox(height: 22),
        ],
      ),
    );
  }
}
