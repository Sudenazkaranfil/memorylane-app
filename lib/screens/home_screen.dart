import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';
import '../models/journal.dart';
import '../services/journal_service.dart';
import 'journal_detail_screen.dart';
import 'profile_screen.dart';
import 'explore_screen.dart';
import 'map_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _username;
  int _selectedIndex = 0;
  List<Journal> _journals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final username = await StorageService.getUsername();
    setState(() => _username = username ?? 'Gezgin');
    await _loadJournals();
  }

  Future<void> _loadJournals() async {
    try {
      final journals = await JournalService.getJournals();
      setState(() {
        _journals = journals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createJournal(String title, String visibility) async {
    try {
      final journal = await JournalService.createJournal(title, visibility);
      setState(() => _journals.add(journal));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ajanda oluşturulamadı')),
        );
      }
    }
  }

  Future<bool?> _showDeleteConfirmDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Ajandayı sil', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
        content: Text('Bu ajanda ve içindeki tüm sayfalar kalıcı olarak silinecek.', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
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
  }

  void _showCreateJournalDialog() {
    final titleController = TextEditingController();
    String selectedVisibility = 'PRIVATE';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.background,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Yeni Ajanda', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: titleController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Ajanda adı',
                  hintStyle: TextStyle(color: AppTheme.textSecondary),
                  filled: true,
                  fillColor: AppTheme.terracottaLight,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 16),
              Text('Gizlilik', style: AppTheme.caption.copyWith(fontWeight: FontWeight.w600, letterSpacing: 1)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setDialogState(() => selectedVisibility = 'PRIVATE'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: selectedVisibility == 'PRIVATE' ? AppTheme.terracotta : AppTheme.terracottaLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.lock_outline, size: 16, color: selectedVisibility == 'PRIVATE' ? Colors.white : AppTheme.terracotta),
                            const SizedBox(width: 6),
                            Text('Özel', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: selectedVisibility == 'PRIVATE' ? Colors.white : AppTheme.terracotta)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setDialogState(() => selectedVisibility = 'PUBLIC'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: selectedVisibility == 'PUBLIC' ? AppTheme.terracotta : AppTheme.terracottaLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.public, size: 16, color: selectedVisibility == 'PUBLIC' ? Colors.white : AppTheme.terracotta),
                            const SizedBox(width: 6),
                            Text('Herkese açık', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: selectedVisibility == 'PUBLIC' ? Colors.white : AppTheme.terracotta)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('İptal', style: TextStyle(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty) return;
                Navigator.pop(context);
                await _createJournal(titleController.text.trim(), selectedVisibility);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.terracotta,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Oluştur'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildJournalsTab();
      case 1:
        return const MapScreen();
      case 2:
        return const ExploreScreen();
      case 3:
        return const ProfileScreen();
      default:
        return _buildJournalsTab();
    }
  }

  Widget _buildJournalsTab() {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getGreeting(),
                            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, letterSpacing: 0.5),
                          ),
                          Text(
                            _username ?? 'Gezgin',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
                          ),
                        ],
                      ),
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(color: AppTheme.terracottaLight, borderRadius: BorderRadius.circular(21)),
                        child: const Icon(Icons.person_outline, color: AppTheme.terracotta, size: 22),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'AJANDALARIM',
                    style: AppTheme.caption.copyWith(fontWeight: FontWeight.w600, letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 16),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppTheme.terracotta))
                      : _journals.isEmpty
                      ? _buildEmptyState()
                      : _buildJournalList(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: _buildBody(),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
        onPressed: _showCreateJournalDialog,
        backgroundColor: AppTheme.terracotta,
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: AppTheme.terracotta,
        unselectedItemColor: AppTheme.textSecondary,
        backgroundColor: Colors.white,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.book_outlined), activeIcon: Icon(Icons.book), label: 'Ajandalar'),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), activeIcon: Icon(Icons.map), label: 'Harita'),
          BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), activeIcon: Icon(Icons.explore), label: 'Keşfet'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: AppTheme.terracottaLight, borderRadius: BorderRadius.circular(32)),
            child: const Icon(Icons.book_outlined, color: AppTheme.terracotta, size: 32),
          ),
          const SizedBox(height: 16),
          const Text('İlk ajandanı oluştur', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          Text('Gezi anılarını kaydetmeye\nhemen başla', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildJournalList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _journals.length,
      itemBuilder: (context, index) {
        final journal = _journals[index];
        return Dismissible(
          key: Key('journal_${journal.id}'),
          direction: DismissDirection.endToStart,
          background: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.red.shade400,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
          ),
          confirmDismiss: (direction) => _showDeleteConfirmDialog(),
          onDismissed: (direction) async {
            final journalId = journal.id;
            final journalIndex = _journals.indexWhere((j) => j.id == journalId);
            if (journalIndex != -1) {
              final removedJournal = _journals[journalIndex];
              setState(() => _journals.removeAt(journalIndex));
              try {
                await JournalService.deleteJournal(journalId);
              } catch (e) {
                setState(() => _journals.insert(journalIndex, removedJournal));
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Silinemedi, tekrar dene!')),
                  );
                }
              }
            }
          },
          child: GestureDetector(
            onTap: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => JournalDetailScreen(journal: journal)),
              );
              if (updated == true) await _loadJournals();
            },
            onLongPress: () async {
              final shouldDelete = await _showDeleteConfirmDialog();
              if (shouldDelete == true) {
                final journalId = journal.id;
                final journalIndex = _journals.indexWhere((j) => j.id == journalId);
                if (journalIndex != -1) {
                  final removedJournal = _journals[journalIndex];
                  setState(() => _journals.removeAt(journalIndex));
                  try {
                    await JournalService.deleteJournal(journalId);
                  } catch (e) {
                    setState(() => _journals.insert(journalIndex, removedJournal));
                  }
                }
              }
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(color: AppTheme.terracottaLight, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.book_outlined, color: AppTheme.terracotta),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(journal.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              journal.visibility == 'PUBLIC' ? Icons.public : Icons.lock_outline,
                              size: 12,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              journal.visibility == 'PUBLIC' ? 'Herkese açık' : 'Özel',
                              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().toLocal().hour;
    if (hour < 12) return 'Günaydın,';
    if (hour < 18) return 'İyi günler,';
    return 'İyi akşamlar,';
  }
}