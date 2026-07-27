import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import '../theme/app_theme.dart';
import '../models/journal.dart';
import '../models/entry.dart';
import '../services/journal_service.dart';
import '../services/entry_service.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  List<Journal> _journals = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();
  String _sortBy = 'newest';

  @override
  void initState() {
    super.initState();
    _loadJournals();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadJournals({String? search}) async {
    setState(() => _isLoading = true);
    try {
      final journals = await JournalService.getPublicJournals(
        search: search,
        sortBy: _sortBy,
      );
      setState(() {
        _journals = journals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Keşfet',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Gezginlerin hikayelerini keşfet',
                  style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  onChanged: (value) => _loadJournals(search: value),
                  decoration: InputDecoration(
                    hintText: 'Ajanda ara...',
                    hintStyle: TextStyle(color: AppTheme.textSecondary),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.terracotta),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear, color: AppTheme.textSecondary, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        _loadJournals();
                      },
                    )
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('En yeni', 'newest'),
                      const SizedBox(width: 8),
                      _buildFilterChip('En popüler', 'popular'),
                      const SizedBox(width: 8),
                      _buildFilterChip('En çok sayfa', 'most_pages'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.terracotta))
                : _journals.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.explore_outlined, size: 64, color: AppTheme.textSecondary.withOpacity(0.4)),
                  const SizedBox(height: 16),
                  Text(
                    _searchController.text.isNotEmpty
                        ? '"${_searchController.text}" ile ilgili ajanda bulunamadı'
                        : 'Henüz keşfedilecek ajanda yok',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: AppTheme.textSecondary),
                  ),
                  if (_searchController.text.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Farklı bir arama dene',
                      style: TextStyle(fontSize: 13, color: AppTheme.textSecondary.withOpacity(0.6)),
                    ),
                  ],
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _journals.length,
              itemBuilder: (context, index) {
                return _buildJournalCard(_journals[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _sortBy == value;
    return GestureDetector(
      onTap: () {
        setState(() => _sortBy = value);
        _loadJournals(search: _searchController.text);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.terracotta : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppTheme.terracotta : AppTheme.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildJournalCard(Journal journal) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ExploreJournalScreen(journal: journal),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.terracottaLight,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
              child: const Icon(Icons.book_outlined, color: AppTheme.terracotta, size: 32),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      journal.title,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.person_outline, size: 12, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          journal.username ?? 'Gezgin',
                          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.chevron_right, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class ExploreJournalScreen extends StatefulWidget {
  final Journal journal;

  const ExploreJournalScreen({super.key, required this.journal});

  @override
  State<ExploreJournalScreen> createState() => _ExploreJournalScreenState();
}

class _ExploreJournalScreenState extends State<ExploreJournalScreen> {
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
        title: Text(widget.journal.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.terracotta))
          : _entries.isEmpty
          ? Center(
        child: Text('Bu ajandada henüz sayfa yok', style: TextStyle(color: AppTheme.textSecondary)),
      )
          : Column(
        children: [
          Expanded(child: _buildPageView()),
          _buildThumbnailList(),
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
            left: 8, top: 0, bottom: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)]),
                  child: const Icon(Icons.chevron_left, color: AppTheme.textPrimary),
                ),
              ),
            ),
          ),
        if (_currentPage < _entries.length - 1)
          Positioned(
            right: 8, top: 0, bottom: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)]),
                  child: const Icon(Icons.chevron_right, color: AppTheme.textPrimary),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPage(Entry entry, int index) {
    return Container(
      margin: const EdgeInsets.fromLTRB(40, 16, 40, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
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
              bottom: 12, right: 12,
              child: Text(
                entry.date != null ? '${entry.date!.day} ${_getMonth(entry.date!.month)}' : '',
                style: TextStyle(fontSize: 11, color: AppTheme.textSecondary.withOpacity(0.6)),
              ),
            ),
            Positioned(
              top: 12, right: 12,
              child: Text(
                '${index + 1}/${_entries.length}',
                style: TextStyle(fontSize: 11, color: AppTheme.textSecondary.withOpacity(0.6)),
              ),
            ),
          ],
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
        widgets.add(Positioned.fill(child: CustomPaint(painter: DrawingPainter(drawingPaths))));
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
            onTap: () => _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
            child: Container(
              width: 52,
              height: 52,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.terracottaLight : const Color(0xFFF5F0E8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isSelected ? AppTheme.terracotta : AppTheme.border, width: isSelected ? 2 : 1),
              ),
              child: Center(
                child: Text('${index + 1}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isSelected ? AppTheme.terracotta : AppTheme.textSecondary)),
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