import 'package:flutter/material.dart';
import 'package:hazodashborad/Core/res/Service/AuthService.dart';
import 'package:hazodashborad/Core/res/Service/PhotoService.dart'; // عدّل المسار حسب مشروعك
import 'package:hazodashborad/Core/res/Model/AdminPhoto.dart'; // عدّل المسار حسب مشروعك

class PhotosGalleryPage extends StatefulWidget {
  const PhotosGalleryPage({super.key});

  @override
  State<PhotosGalleryPage> createState() => _PhotosGalleryPageState();
}

class _PhotosGalleryPageState extends State<PhotosGalleryPage> {
  final _photoService = PhotoService();
  final _auth = AuthService();

  String? _token;
  List<AdminPhoto> _photos = [];
  bool _loading = true;
  bool _refreshing = false;
  bool _patching = false; // مؤشر صغير عند التعديل

  // -------- Helpers: تنظيف روابط الصور --------
  String sanitizeUrl(String url) {
    var u = url.trim();
    if (u.isEmpty) return u;
    // شيل اقتباس بداية/نهاية لو راجع بهيئة x"
    if (u.startsWith('"') && u.endsWith('"') && u.length > 1) {
      u = u.substring(1, u.length - 1).trim();
    } else {
      if (u.startsWith('"')) u = u.substring(1).trim();
      if (u.endsWith('"')) u = u.substring(0, u.length - 1).trim();
    }
    // ترميز أي مسافات/أحرف خاصة
    return Uri.encodeFull(u);
  }

  String resolveUrl(String url) {
    final clean = sanitizeUrl(url);
    // إذا الرابط كامل، استخدمه كما هو
    if (clean.startsWith('http://') || clean.startsWith('https://'))
      return clean;
    // لو رجع نسبي (نادرًا)، كمّله ببيئة API لو بدك. حالياً نرجعه كما هو.
    return clean;
  }
  // ---------------------------------------------

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    try {
      setState(() => _loading = true);
      final token = await _auth.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('No token');
      }
      final data = await _photoService.getAllAdminPhotos(token);
      setState(() {
        _token = token;
        _photos = data;
      });

      // Debug بسيط لأول رابط
      if (_photos.isNotEmpty) {
        // ignore: avoid_print
        print('raw url: ${_photos.first.url}');
        // ignore: avoid_print
        print('resolved url: ${resolveUrl(_photos.first.url)}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load photos: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _refresh() async {
    setState(() => _refreshing = true);
    await _loadPhotos();
    if (mounted) setState(() => _refreshing = false);
  }

  Future<void> _toggleSelectWithPatch(int index) async {
    final item = _photos[index];
    final newSelected = !item.isSelected;

    // optimistic update
    setState(() {
      _patching = true;
      _photos[index] = AdminPhoto(
        id: item.id,
        title: item.title,
        url: item.url,
        isSelected: newSelected,
      );
    });

    try {
      await _photoService.patchPhotoSelection(
        token: _token ?? '',
        id: item.id,
        selected: newSelected,
      );
      // success: لا شيء
    } catch (e) {
      // rollback
      if (!mounted) return;
      setState(() => _photos[index] = item);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Update failed: $e')));
    } finally {
      if (mounted) setState(() => _patching = false);
    }
  }

  Future<void> _selectAllOrClearWithPatch() async {
    // لو في واحد غير محدد => حدد الكل. غير ذلك الغِ التحديد.
    final shouldSelectAll = _photos.any((p) => !p.isSelected);
    final indicesToChange = <int>[];
    for (int i = 0; i < _photos.length; i++) {
      if (_photos[i].isSelected != shouldSelectAll) indicesToChange.add(i);
    }
    if (indicesToChange.isEmpty) return;

    final old = List<AdminPhoto>.from(_photos);
    setState(() {
      _patching = true;
      for (final i in indicesToChange) {
        final it = _photos[i];
        _photos[i] = AdminPhoto(
          id: it.id,
          title: it.title,
          url: it.url,
          isSelected: shouldSelectAll,
        );
      }
    });

    try {
      for (final i in indicesToChange) {
        final it = _photos[i];
        await _photoService.patchPhotoSelection(
          token: _token ?? '',
          id: it.id,
          selected: it.isSelected,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _photos = old);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Bulk update failed: $e')));
    } finally {
      if (mounted) setState(() => _patching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text("Admin Photos"),
        backgroundColor: const Color(0xFF5B8DEF),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_loading || _refreshing || _patching)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                child: SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          IconButton(
            tooltip: 'Reload',
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _loadPhotos,
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF5B8DEF)),
            )
          : _photos.isEmpty
          ? const Center(
              child: Text(
                "No photos found.",
                style: TextStyle(color: Color(0xFF5B8DEF), fontSize: 18),
              ),
            )
          : Column(
              children: [
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${_photos.where((p) => p.isSelected).length} selected',
                          style: const TextStyle(
                            color: Color(0xFF192132),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: _patching
                            ? null
                            : _selectAllOrClearWithPatch,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF5B8DEF)),
                          foregroundColor: const Color(0xFF5B8DEF),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: Icon(
                          _photos.every((p) => p.isSelected)
                              ? Icons.select_all
                              : Icons.done_all_outlined,
                          size: 18,
                        ),
                        label: Text(
                          _photos.every((p) => p.isSelected)
                              ? 'Clear'
                              : 'Select all',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: RefreshIndicator(
                    color: const Color(0xFF5B8DEF),
                    onRefresh: _refresh,
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      itemCount: _photos.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: 1,
                          ),
                      itemBuilder: (context, i) {
                        final item = _photos[i];
                        final isSelected = item.isSelected;
                        final resolvedUrl = resolveUrl(item.url);

                        return GestureDetector(
                          onTap: _patching
                              ? null
                              : () => _toggleSelectWithPatch(i),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                  ),
                                  child: Image.network(
                                    resolvedUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: Colors.grey[300],
                                      alignment: Alignment.center,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.broken_image_outlined,
                                            size: 36,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(height: 6),
                                          // مفيد للتشخيص: عرض الرابط المصحّح
                                          Text(
                                            resolvedUrl,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // عنوان الصورة
                              Positioned(
                                left: 8,
                                right: 8,
                                bottom: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.35),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    item.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
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
                                        child: Icon(
                                          Icons.check,
                                          size: 36,
                                          color: Color(0xFF5B8DEF),
                                        ),
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
                ),
                const SizedBox(height: 6),
              ],
            ),
    );
  }
}
