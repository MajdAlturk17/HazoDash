import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';

class CustomSplash extends StatefulWidget {
  const CustomSplash({super.key});

  @override
  State<CustomSplash> createState() => _CustomSplashState();
}

class _CustomSplashState extends State<CustomSplash> {
  List<Uint8List> _images = [];
  Set<int> _selectedIndexes = {};

  Future<void> _pickImages() async {
    List<Uint8List>? bytesFromPicker = await ImagePickerWeb.getMultiImagesAsBytes();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text("CustomSplash - Multi Images"),
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
              onPressed: _pickImages,
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
              onPressed: (){},
              icon: const Icon(Icons.photo_library_outlined, color: Colors.white),
              label: const Text("Upload Select Photo", style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}
