import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import '../theme/app_theme.dart';
import '../models/journal.dart';
import '../models/entry.dart';
import '../services/entry_service.dart';
import 'canvas_editor_screen.dart';
import '../services/journal_service.dart';

class JournalDetailScreen extends StatefulWidget {
  final Journal journal;

  const JournalDetailScreen({super.key, required this.journal});

  @override
  State<JournalDetailScreen> createState() => _JournalDetailScreenState();
}

class _JournalDetailScreenState extends State<JournalDetailScreen> {
  List<Entry> _entries = [];
  bool _isLoading = true;
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadEntries();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadEntries() async {
    try {
      final entries = await EntryService.getEntries(widget.journal.id);
      setState(() {
        _entries = entries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _showDeleteDialog(int index) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sayfayı sil', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
        content: Text('Bu sayfa kalıcı olarak silinecek.', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('İptal', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      final entry = _entries[index];
      setState(() {
        _entries.removeAt(index);
        if (_currentPage >= _entries.length && _currentPage > 0) {
          _currentPage = _entries.length - 1;
        }
      });
      try {
        await EntryService.deleteEntry(widget.journal.id, entry.id);
      } catch (e) {
        setState(() => _entries.insert(index, entry));
      }
    }
  }

  void _showVisibilityDialog() async {
    final newVisibility = widget.journal.visibility == 'PUBLIC' ? 'PRIVATE' : 'PUBLIC';
    try {
      await JournalService.updateJournal(widget.journal.id, widget.journal.title, newVisibility);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(newVisibility == 'PUBLIC' ? 'Ajanda herkese açık yapıldı' : 'Ajanda özel yapıldı')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Güncellenemedi, tekrar dene!')),
        );
      }
    }
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.journal.title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppTheme.textPrimary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (value) async {
              if (value == 'delete' && _entries.isNotEmpty) {
                _showDeleteDialog(_currentPage);
              } else if (value == 'visibility') {
                _showVisibilityDialog();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'visibility',
                child: Row(
                  children: [
                    Icon(
                      widget.journal.visibility == 'PUBLIC' ? Icons.lock_outline : Icons.public,
                      color: AppTheme.textPrimary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(widget.journal.visibility == 'PUBLIC' ? 'Özel yap' : 'Herkese aç'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Sayfayı sil', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.terracotta))
          : _entries.isEmpty
          ? _buildEmptyState()
          : Column(
        children: [
          Expanded(child: _buildPageView()),
          _buildThumbnailList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CanvasEditorScreen(journalId: widget.journal.id),
            ),
          );
          _loadEntries();
        },
        backgroundColor: AppTheme.terracotta,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(color: AppTheme.terracottaLight, borderRadius: BorderRadius.circular(40)),
            child: const Icon(Icons.edit_outlined, color: AppTheme.terracotta, size: 40),
          ),
          const SizedBox(height: 20),
          const Text('İlk sayfanı ekle', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          Text('Sağ alttaki + butonuna bas', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildPageView() {
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          onPageChanged: (index) => setState(() => _currentPage = index),
          itemCount: _entries.length,
          itemBuilder: (context, index) => _buildPage(_entries[index], index),
        ),
        if (_currentPage > 0)
          Positioned(
            left: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
                  ),
                  child: const Icon(Icons.chevron_left, color: AppTheme.textPrimary),
                ),
              ),
            ),
          ),
        if (_currentPage < _entries.length - 1)
          Positioned(
            right: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
                  ),
                  child: const Icon(Icons.chevron_right, color: AppTheme.textPrimary),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPage(Entry entry, int index) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CanvasEditorScreen(
              journalId: widget.journal.id,
              entry: entry,
            ),
          ),
        );
        _loadEntries();
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(40, 16, 40, 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF7F2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(4, 0)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              CustomPaint(painter: DottedBackgroundPainter(), size: Size.infinite),
              if (entry.canvasData != null)
                ..._buildCanvasPreview(entry.canvasData!)
              else
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (entry.locationName != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(color: AppTheme.terracotta, borderRadius: BorderRadius.circular(20)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.location_on, color: Colors.white, size: 14),
                                const SizedBox(width: 4),
                                Text(entry.locationName!, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                        if (entry.textContent != null) ...[
                          const SizedBox(height: 16),
                          Text(entry.textContent!, style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary, height: 1.6), textAlign: TextAlign.center),
                        ],
                      ],
                    ),
                  ),
                ),
              Positioned(
                bottom: 12,
                right: 12,
                child: Text(
                  entry.date != null ? '${entry.date!.day} ${_getMonth(entry.date!.month)}' : '',
                  style: TextStyle(fontSize: 11, color: AppTheme.textSecondary.withOpacity(0.6)),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Text(
                  '${index + 1}/${_entries.length}',
                  style: TextStyle(fontSize: 11, color: AppTheme.textSecondary.withOpacity(0.6)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCanvasPreview(String canvasData) {
    try {
      final Map<String, dynamic> data = jsonDecode(canvasData);
      final elements = (data['elements'] as List?) ?? [];
      final paths = (data['paths'] as List?) ?? [];

      List<Widget> widgets = [];

      if (paths.isNotEmpty) {
        final drawingPaths = paths.map((p) => DrawingPath.fromJson(p)).toList();
        widgets.add(
          Positioned.fill(
            child: CustomPaint(painter: DrawingPainter(drawingPaths)),
          ),
        );
      }

      for (final e in elements) {
        final type = e['type'];
        final content = e['content'];
        final x = (e['x'] as num).toDouble() * 0.6;
        final y = (e['y'] as num).toDouble() * 0.6;

        Widget child;
        if (type == 'text') {
          child = Container(
            padding: const EdgeInsets.all(6),
            constraints: const BoxConstraints(maxWidth: 120),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
            child: Text(content ?? '', style: const TextStyle(fontSize: 9, color: AppTheme.textPrimary)),
          );
        } else if (type == 'photo') {
          child = Container(
            padding: const EdgeInsets.all(4),
            color: Colors.white,
            child: content.startsWith('http')
                ? Image.network(content, width: 80, height: 80, fit: BoxFit.cover)
                : Image.file(File(content), width: 80, height: 80, fit: BoxFit.cover),
          );
        } else if (type == 'sticker') {
          child = Text(content ?? '⭐', style: const TextStyle(fontSize: 20));
        } else if (type == 'location') {
          child = Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(color: AppTheme.terracotta, borderRadius: BorderRadius.circular(20)),
            child: Text(content ?? '', style: const TextStyle(color: Colors.white, fontSize: 8)),
          );
        } else {
          child = const SizedBox();
        }

        widgets.add(Positioned(left: x, top: y, child: child));
      }

      return widgets;
    } catch (e) {
      return [];
    }
  }

  Widget _buildThumbnailList() {
    return Container(
      height: 80,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _entries.length,
        itemBuilder: (context, index) {
          final isSelected = index == _currentPage;
          return GestureDetector(
            onTap: () => _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
            onLongPress: () => _showDeleteDialog(index),
            child: Container(
              width: 52,
              height: 52,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.terracottaLight : const Color(0xFFF5F0E8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? AppTheme.terracotta : AppTheme.border,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? AppTheme.terracotta : AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getMonth(int month) {
    const months = ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];
    return months[month - 1];
  }
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
        ..strokeWidth = path.strokeWidth * 0.6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final drawPath = Path();
      drawPath.moveTo(path.points.first.dx * 0.6, path.points.first.dy * 0.6);
      for (int i = 1; i < path.points.length; i++) {
        drawPath.lineTo(path.points[i].dx * 0.6, path.points[i].dy * 0.6);
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