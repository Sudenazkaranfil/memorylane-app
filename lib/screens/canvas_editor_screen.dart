import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import '../theme/app_theme.dart';
import '../models/entry.dart';
import '../services/entry_service.dart';
import '../services/photo_service.dart';
import 'package:image_cropper/image_cropper.dart';

class CanvasEditorScreen extends StatefulWidget {
  final int journalId;
  final Entry? entry;

  const CanvasEditorScreen({super.key, required this.journalId, this.entry});

  @override
  State<CanvasEditorScreen> createState() => _CanvasEditorScreenState();
}

class _CanvasEditorScreenState extends State<CanvasEditorScreen> {
  final List<CanvasElement> _elements = [];
  bool _isDrawingMode = false;
  Color _drawingColor = AppTheme.textPrimary;
  double _drawingSize = 3.0;
  List<DrawingPath> _drawingPaths = [];
  DrawingPath? _currentPath;
  double _lastRotation = 0;

  @override
  void initState() {
    super.initState();
    if (widget.entry?.canvasData != null) {
      _loadCanvasData(widget.entry!.canvasData!);
    }
  }

  void _loadCanvasData(String canvasData) {
    try {
      final Map<String, dynamic> data = jsonDecode(canvasData);
      final elements = (data['elements'] as List?) ?? [];
      final paths = (data['paths'] as List?) ?? [];
      setState(() {
        _elements.addAll(elements.map((e) => CanvasElement.fromJson(e)).toList());
        _drawingPaths = paths.map((p) => DrawingPath.fromJson(p)).toList();
      });
    } catch (e) {
      try {
        final List<dynamic> elements = jsonDecode(canvasData);
        setState(() {
          _elements.addAll(elements.map((e) => CanvasElement.fromJson(e)).toList());
        });
      } catch (_) {}
    }
  }

  Future<void> _onBackPressed() async {
    if (_elements.isEmpty && _drawingPaths.isEmpty) {
      Navigator.pop(context);
      return;
    }
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Değişiklikler kaydedilmedi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
        content: Text('Çıkarsanız yaptığınız değişiklikler kaybolacak.', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Devam et', style: TextStyle(color: AppTheme.terracotta))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade400, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Çık'),
          ),
        ],
      ),
    );
    if (shouldLeave == true && mounted) Navigator.pop(context);
  }

  Future<void> _saveCanvas() async {
    if (_elements.isEmpty && _drawingPaths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Canvas boş, bir şeyler ekle!')));
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: AppTheme.terracotta)),
    );

    try {
      final locationElement = _elements.where((e) => e.type == ElementType.location).firstOrNull;
      final textElement = _elements.where((e) => e.type == ElementType.text).firstOrNull;

      final entryData = {
        'textContent': textElement?.content,
        'locationName': locationElement?.content,
        'lat': locationElement?.lat,
        'lng': locationElement?.lng,
        'date': DateTime.now().toIso8601String().split('T')[0],
      };

      // Önce entry oluştur
      Entry entry;
      if (widget.entry != null) {
        entry = await EntryService.updateEntry(widget.journalId, widget.entry!.id, entryData);
      } else {
        entry = await EntryService.createEntry(widget.journalId, entryData);
      }

      // Fotoğrafları Cloudinary'e yükle
      for (var element in _elements) {
        if (element.type == ElementType.photo &&
            element.content != null &&
            !element.content!.startsWith('http')) {
          try {
            final url = await PhotoService.uploadPhoto(element.content!, entry.id);
            element.content = url;
          } catch (e) {
            if (mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fotoğraf yüklenemedi, tekrar dene!')),
              );
            }
            return;
          }
        }
      }

      // Canvas verisini kaydet
      final canvasData = jsonEncode({
        'elements': _elements.map((e) => e.toJson()).toList(),
        'paths': _drawingPaths.map((p) => p.toJson()).toList(),
      });

      await EntryService.updateEntry(widget.journalId, entry.id, {
        ...entryData,
        'canvasData': canvasData,
      });

      if (mounted) {
        Navigator.pop(context);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sayfa kaydedildi!')));
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kaydedilemedi, tekrar dene!')));
      }
    }
  }

  Future<void> _addPhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: image.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9,
      ],
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Fotoğrafı Kırp',
          toolbarColor: AppTheme.terracotta,
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: AppTheme.terracotta,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
      ],
    );

    if (croppedFile != null) {
      setState(() {
        _elements.add(CanvasElement(
          type: ElementType.photo,
          content: croppedFile.path,
          x: 50,
          y: 100,
        ));
      });
    }
  }

  void _addText() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Yazı Ekle'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Bir şeyler yaz...',
            hintStyle: TextStyle(color: AppTheme.textSecondary),
            filled: true,
            fillColor: AppTheme.terracottaLight,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('İptal', style: TextStyle(color: AppTheme.textSecondary))),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _elements.add(CanvasElement(type: ElementType.text, content: controller.text.trim(), x: 50, y: 100));
                });
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.terracotta, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  void _addEmoji() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Align(alignment: Alignment.centerLeft, child: Text('Emoji Seç', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.textPrimary))),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: {
                  '✈️ Seyahat': ['✈️', '🚂', '⛵', '🚗', '🏕️', '🗺️', '🧳', '🎒', '🚀', '🛸', '🚁', '⛴️', '🚢', '🛳️', '🚤'],
                  '🌍 Yerler': ['🏔️', '🌊', '🏖️', '🌅', '🗼', '🏰', '🌃', '🌉', '🌴', '🏝️', '🗽', '🏯', '⛩️', '🕌', '🏛️'],
                  '❤️ Duygular': ['❤️', '⭐', '🌟', '💫', '🎉', '🥰', '😊', '🤩', '💕', '🙌', '🥳', '😍', '🤗', '💖', '✨'],
                  '📸 Anlar': ['📸', '🎭', '🎪', '🎨', '🎵', '🍜', '🥂', '🌺', '🎊', '🎁', '🎬', '🎤', '🎸', '🍷', '🥗'],
                  '🌙 Hava': ['☀️', '🌙', '⭐', '🌈', '🌸', '🍂', '❄️', '🌊', '⚡', '🌤️', '🌧️', '🌨️', '🌪️', '🌫️', '🌬️'],
                  '🐾 Hayvanlar': ['🦋', '🐬', '🦅', '🐘', '🦁', '🐆', '🦒', '🐧', '🦜', '🐠', '🦈', '🐢', '🦩', '🦚', '🦀'],
                  '🍕 Yiyecek': ['🍜', '🍣', '🥐', '🍕', '🌮', '🥘', '🍛', '🥗', '🍰', '☕', '🧃', '🍹', '🥤', '🍦', '🧁'],
                }.entries.map((category) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(category.key, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: category.value.map((emoji) => GestureDetector(
                        onTap: () {
                          setState(() {
                            _elements.add(CanvasElement(type: ElementType.sticker, content: emoji, x: 100, y: 150));
                          });
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(color: AppTheme.terracottaLight, borderRadius: BorderRadius.circular(12)),
                          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
                        ),
                      )).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addLocation() {
    final controller = TextEditingController();
    List<Map<String, dynamic>> suggestions = [];
    bool isSearching = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Konum Ekle', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  onChanged: (value) async {
                    if (value.length < 2) {
                      setSheetState(() => suggestions = []);
                      return;
                    }
                    setSheetState(() => isSearching = true);
                    try {
                      final response = await http.get(
                        Uri.parse('https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(value)}&format=json&limit=5&accept-language=tr'),
                        headers: {'User-Agent': 'MemoryLane/1.0'},
                      );
                      if (response.statusCode == 200) {
                        final List<dynamic> data = jsonDecode(response.body);
                        setSheetState(() {
                          suggestions = data.map((e) => {
                            'name': e['display_name'],
                            'lat': double.parse(e['lat']),
                            'lng': double.parse(e['lon']),
                          }).toList();
                          isSearching = false;
                        });
                      }
                    } catch (e) {
                      setSheetState(() => isSearching = false);
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'Paris, Tokyo, İstanbul...',
                    hintStyle: TextStyle(color: AppTheme.textSecondary),
                    filled: true,
                    fillColor: AppTheme.terracottaLight,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary, size: 20),
                    suffixIcon: isSearching
                        ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.terracotta)))
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (suggestions.isNotEmpty)
                Container(
                  constraints: const BoxConstraints(maxHeight: 250),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: suggestions.length,
                    itemBuilder: (context, index) {
                      final suggestion = suggestions[index];
                      final parts = suggestion['name'].toString().split(',');
                      final mainName = parts[0].trim();
                      final subName = parts.length > 1 ? parts.sublist(1).join(',').trim() : '';

                      return ListTile(
                        leading: const Icon(Icons.location_on_outlined, color: AppTheme.terracotta, size: 20),
                        title: Text(mainName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
                        subtitle: subName.isNotEmpty
                            ? Text(subName, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis)
                            : null,
                        onTap: () {
                          setState(() {
                            _elements.add(CanvasElement(
                              type: ElementType.location,
                              content: mainName,
                              x: 80,
                              y: 200,
                              lat: suggestion['lat'],
                              lng: suggestion['lng'],
                            ));
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _geocodeAndAddLocation(String locationName) async {
    try {
      final response = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(locationName)}&format=json&limit=1'),
        headers: {'User-Agent': 'MemoryLane/1.0'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lng = double.parse(data[0]['lon']);
          final displayName = data[0]['display_name'].toString().split(',')[0];

          setState(() {
            _elements.add(CanvasElement(
              type: ElementType.location,
              content: displayName,
              x: 80,
              y: 200,
              lat: lat,
              lng: lng,
            ));
          });
          return;
        }
      }
    } catch (e) {}

    setState(() {
      _elements.add(CanvasElement(
        type: ElementType.location,
        content: locationName,
        x: 80,
        y: 200,
      ));
    });
  }

  void _showDrawingOptions() {
    if (_isDrawingMode) {
      _showDrawingSettings();
    } else {
      setState(() => _isDrawingMode = true);
    }
  }

  void _showDrawingSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Çizim Ayarları', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
                  TextButton(
                    onPressed: () {
                      setState(() => _isDrawingMode = false);
                      Navigator.pop(context);
                    },
                    child: Text('Bitti', style: TextStyle(color: AppTheme.terracotta, fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Renk', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                children: [
                  AppTheme.textPrimary,
                  AppTheme.terracotta,
                  Colors.blue.shade400,
                  Colors.green.shade400,
                  Colors.purple.shade400,
                  Colors.red.shade400,
                  Colors.orange.shade400,
                  Colors.white,
                ].map((color) => GestureDetector(
                  onTap: () {
                    setModalState(() => _drawingColor = color);
                    setState(() => _drawingColor = color);
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _drawingColor == color ? AppTheme.terracotta : AppTheme.border, width: _drawingColor == color ? 2 : 1),
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 16),
              const Text('Boyut', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
              Slider(
                value: _drawingSize,
                min: 1,
                max: 20,
                activeColor: AppTheme.terracotta,
                onChanged: (value) {
                  setModalState(() => _drawingSize = value);
                  setState(() => _drawingSize = value);
                },
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() => _drawingPaths.clear());
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.clear, size: 16, color: Colors.red),
                label: const Text('Çizimleri Temizle', style: TextStyle(color: Colors.red, fontSize: 13)),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary, size: 20),
          onPressed: _onBackPressed,
        ),
        title: const Text('Sayfa Düzenle', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
        actions: [
          if (_isDrawingMode)
            TextButton(
              onPressed: () => setState(() => _isDrawingMode = false),
              child: Text('Taşı', style: TextStyle(color: AppTheme.terracotta, fontWeight: FontWeight.w500)),
            ),
          TextButton(
            onPressed: _saveCanvas,
            child: Text('Kaydet', style: TextStyle(color: AppTheme.terracotta, fontWeight: FontWeight.w500)),
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppTheme.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF7F2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: GestureDetector(
                  onPanStart: _isDrawingMode ? (details) {
                    setState(() {
                      _currentPath = DrawingPath(points: [details.localPosition], color: _drawingColor, strokeWidth: _drawingSize);
                      _drawingPaths.add(_currentPath!);
                    });
                  } : null,
                  onPanUpdate: _isDrawingMode ? (details) {
                    setState(() => _currentPath?.points.add(details.localPosition));
                  } : null,
                  onPanEnd: _isDrawingMode ? (details) {
                    setState(() => _currentPath = null);
                  } : null,
                  child: Stack(
                    children: [
                      CustomPaint(painter: DottedBackgroundPainter(), size: Size.infinite),
                      CustomPaint(painter: DrawingPainter(_drawingPaths), size: Size.infinite),
                      ..._elements.map((element) => _buildElement(element)),
                      if (_elements.isEmpty && _drawingPaths.isEmpty)
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.touch_app_outlined, size: 48, color: AppTheme.textSecondary.withOpacity(0.4)),
                              const SizedBox(height: 12),
                              Text('Aşağıdan eleman ekle', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary.withOpacity(0.5))),
                            ],
                          ),
                        ),
                      if (_isDrawingMode)
                        Positioned(
                          top: 12, left: 0, right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: AppTheme.terracotta.withOpacity(0.9), borderRadius: BorderRadius.circular(20)),
                              child: const Text('Çizim modu aktif', style: TextStyle(color: Colors.white, fontSize: 12)),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _buildToolbar(),
        ],
      ),
    );
  }

  Widget _buildElement(CanvasElement element) {
    return Positioned(
      left: element.x,
      top: element.y,
      child: GestureDetector(
        onPanUpdate: _isDrawingMode ? null : (details) {
          setState(() {
            element.x += details.delta.dx;
            element.y += details.delta.dy;
          });
        },
        onScaleUpdate: _isDrawingMode ? null : (details) {
          setState(() {
            if (details.scale != 1.0) {
              element.scale = (element.scale * details.scale).clamp(0.3, 5.0);
            }
            if (details.pointerCount > 1) {
              element.rotation += details.rotation - _lastRotation;
              _lastRotation = details.rotation;
            }
            element.x += details.focalPointDelta.dx;
            element.y += details.focalPointDelta.dy;
          });
        },
        onScaleStart: _isDrawingMode ? null : (details) {
          _lastRotation = 0;
        },
        onScaleEnd: _isDrawingMode ? null : (details) {
          _lastRotation = 0;
        },
        child: Transform.rotate(
          angle: element.rotation,
          child: Transform.scale(
            scale: element.scale,
            child: _buildElementContent(element),
          ),
        ),
      ),
    );
  }

  Widget _buildElementContent(CanvasElement element) {
    switch (element.type) {
      case ElementType.text:
        return Container(
          padding: const EdgeInsets.all(12),
          constraints: const BoxConstraints(maxWidth: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Text(element.content ?? '', style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary, height: 1.5)),
        );
      case ElementType.photo:
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(2, 2))],
          ),
          padding: const EdgeInsets.all(8),
          child: element.content!.startsWith('http')
              ? Image.network(element.content!, width: 160, height: 160, fit: BoxFit.cover)
              : Image.file(File(element.content!), width: 160, height: 160, fit: BoxFit.cover),
        );
      case ElementType.sticker:
        return Text(element.content ?? '⭐', style: const TextStyle(fontSize: 40));
      case ElementType.location:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: AppTheme.terracotta, borderRadius: BorderRadius.circular(20)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_on, color: Colors.white, size: 14),
              const SizedBox(width: 4),
              Text(element.content ?? 'Konum', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: AppTheme.border))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildToolbarItem(Icons.image_outlined, 'Fotoğraf', _addPhoto, !_isDrawingMode),
          _buildToolbarItem(Icons.text_fields, 'Yazı', _addText, !_isDrawingMode),
          _buildToolbarItem(Icons.emoji_emotions_outlined, 'Emoji', _addEmoji, !_isDrawingMode),
          _buildToolbarItem(Icons.draw_outlined, 'Çiz', _showDrawingOptions, true, isActive: _isDrawingMode),
          _buildToolbarItem(Icons.location_on_outlined, 'Konum', _addLocation, !_isDrawingMode),
        ],
      ),
    );
  }

  Widget _buildToolbarItem(IconData icon, String label, VoidCallback onTap, bool enabled, {bool isActive = false}) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isActive ? AppTheme.terracotta : (enabled ? AppTheme.terracottaLight : AppTheme.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: isActive ? Colors.white : (enabled ? AppTheme.terracotta : AppTheme.textSecondary), size: 22),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: enabled ? AppTheme.textSecondary : AppTheme.border)),
        ],
      ),
    );
  }
}

enum ElementType { text, photo, sticker, location }

class CanvasElement {
  final ElementType type;
  String? content;
  double x;
  double y;
  double rotation;
  double scale;
  double? lat;
  double? lng;

  CanvasElement({
    required this.type,
    this.content,
    this.x = 0,
    this.y = 0,
    this.rotation = 0,
    this.scale = 1,
    this.lat,
    this.lng,
  });

  factory CanvasElement.fromJson(Map<String, dynamic> json) {
    return CanvasElement(
      type: ElementType.values.firstWhere((e) => e.name == json['type'], orElse: () => ElementType.text),
      content: json['content'],
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      rotation: (json['rotation'] as num).toDouble(),
      scale: (json['scale'] as num).toDouble(),
      lat: json['lat']?.toDouble(),
      lng: json['lng']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'content': content,
    'x': x,
    'y': y,
    'rotation': rotation,
    'scale': scale,
    'lat': lat,
    'lng': lng,
  };
}

class DrawingPath {
  List<Offset> points;
  Color color;
  double strokeWidth;

  DrawingPath({required this.points, required this.color, required this.strokeWidth});

  factory DrawingPath.fromJson(Map<String, dynamic> json) {
    return DrawingPath(
      points: (json['points'] as List).map((p) => Offset((p['x'] as num).toDouble(), (p['y'] as num).toDouble())).toList(),
      color: Color(json['color'] as int),
      strokeWidth: (json['strokeWidth'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'points': points.map((p) => {'x': p.dx, 'y': p.dy}).toList(),
    'color': color.value,
    'strokeWidth': strokeWidth,
  };
}

class DrawingPainter extends CustomPainter {
  final List<DrawingPath> paths;
  DrawingPainter(this.paths);

  @override
  void paint(Canvas canvas, Size size) {
    for (final path in paths) {
      if (path.points.isEmpty) continue;
      final paint = Paint()
        ..color = path.color
        ..strokeWidth = path.strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final drawPath = Path();
      drawPath.moveTo(path.points.first.dx, path.points.first.dy);
      for (int i = 1; i < path.points.length; i++) {
        drawPath.lineTo(path.points[i].dx, path.points[i].dy);
      }
      canvas.drawPath(drawPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) => true;
}

class DottedBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4C5B0).withOpacity(0.4)
      ..style = PaintingStyle.fill;

    const spacing = 20.0;
    const dotRadius = 1.0;

    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}