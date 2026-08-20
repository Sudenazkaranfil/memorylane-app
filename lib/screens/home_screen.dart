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

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  String? _username;
  int _selectedIndex = 0;
  List<Journal> _myJournals = [];
  List<Journal> _savedJournals = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final username = await StorageService.getUsername();
    setState(() => _username = username ?? 'Gezgin');
    await _loadJournals();
  }

  Future<void> _loadJournals() async {
    try {
      final myJournals = await JournalService.getJournals();
      final savedJournals = await JournalService.getSavedJournals();
      setState(() {
        _myJournals = myJournals;
        _savedJournals = savedJournals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createJournal(String title, String visibility) async {
    try {
      final journal = await JournalService.createJournal(title, visibility);
      setState(() => _myJournals.add(journal));
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
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_getGreeting(), style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, letterSpacing: 0.5)),
                    Text(_username ?? 'Gezgin', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
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
          ),
          const SizedBox(height: 16),
          TabBar(
            controller: _tabController,
            labelColor: AppTheme.terracotta,
            unselectedLabelColor: AppTheme.textSecondary,
            indicatorColor: AppTheme.terracotta,
            indicatorSize: TabBarIndicatorSize.label,
            onTap: (index) => _loadJournals(),
            tabs: const [
              Tab(text: 'Ajandalarım'),
              Tab(text: 'Kaydettiklerim'),
            ],
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.terracotta))
                : TabBarView(
              controller: _tabController,
              children: [
                _buildJournalList(_myJournals, isOwn: true),
                _buildJournalList(_savedJournals, isOwn: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJournalList(List<Journal> journals, {required bool isOwn}) {
    if (journals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(color: AppTheme.terracottaLight, borderRadius: BorderRadius.circular(32)),
              child: Icon(isOwn ? Icons.book_outlined : Icons.bookmark_outline, color: AppTheme.terracotta, size: 32),
            ),
            const SizedBox(height: 16),
            Text(isOwn ? 'İlk ajandanı oluştur' : 'Henüz kayıt yok', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            Text(isOwn ? 'Gezi anılarını kaydetmeye başla' : 'Keşfet\'te ajandaları kaydet', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppTheme.terracotta,
      onRefresh: _loadJournals,
      child: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: journals.length,
        itemBuilder: (context, index) {
          final journal = journals[index];
          return isOwn ? _buildOwnJournalCard(journal) : _buildJournalCardContent(journal, isOwn: false);
        },
      ),
    );
  }

  Widget _buildOwnJournalCard(Journal journal) {
    return Dismissible(
      key: Key('journal_${journal.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: Colors.red.shade400, borderRadius: BorderRadius.circular(14)),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
      ),
      confirmDismiss: (direction) => _showDeleteConfirmDialog(),
      onDismissed: (direction) async {
        final journalId = journal.id;
        final journalIndex = _myJournals.indexWhere((j) => j.id == journalId);
        if (journalIndex != -1) {
          final removedJournal = _myJournals[journalIndex];
          setState(() => _myJournals.removeAt(journalIndex));
          try {
            await JournalService.deleteJournal(journalId);
          } catch (e) {
            setState(() => _myJournals.insert(journalIndex, removedJournal));
          }
        }
      },
      child: _buildJournalCardContent(journal, isOwn: true),
    );
  }

  Widget _buildJournalCardContent(Journal journal, {required bool isOwn}) {
    return GestureDetector(
      onTap: () async {
        final updated = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => JournalDetailScreen(journal: journal)),
        );
        if (updated == true) await _loadJournals();
      },
      onLongPress: isOwn ? () async {
        final shouldDelete = await _showDeleteConfirmDialog();
        if (shouldDelete == true) {
          final journalId = journal.id;
          final journalIndex = _myJournals.indexWhere((j) => j.id == journalId);
          if (journalIndex != -1) {
            final removedJournal = _myJournals[journalIndex];
            setState(() => _myJournals.removeAt(journalIndex));
            try {
              await JournalService.deleteJournal(journalId);
            } catch (e) {
              setState(() => _myJournals.insert(journalIndex, removedJournal));
            }
          }
        }
      } : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), bottomLeft: Radius.circular(14)),
              child: journal.coverImageUrl != null
                  ? Image.network(journal.coverImageUrl!, width: 80, height: 80, fit: BoxFit.cover)
                  : Container(
                width: 80,
                height: 80,
                color: AppTheme.terracottaLight,
                child: const Icon(Icons.book_outlined, color: AppTheme.terracotta, size: 32),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(journal.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(journal.visibility == 'PUBLIC' ? Icons.public : Icons.lock_outline, size: 12, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text(journal.visibility == 'PUBLIC' ? 'Herkese açık' : 'Özel', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                        if (!isOwn) ...[
                          const SizedBox(width: 8),
                          Text('@${journal.username ?? ''}', style: TextStyle(fontSize: 12, color: AppTheme.terracotta)),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.visibility_outlined, size: 12, color: AppTheme.textSecondary.withOpacity(0.6)),
                        const SizedBox(width: 4),
                        Text('${journal.viewCount}', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary.withOpacity(0.6))),
                        const SizedBox(width: 8),
                        Icon(Icons.bookmark_outline, size: 12, color: AppTheme.textSecondary.withOpacity(0.6)),
                        const SizedBox(width: 4),
                        Text('${journal.saveCount}', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary.withOpacity(0.6))),
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

  String _getGreeting() {
    final hour = DateTime.now().toLocal().hour;
    if (hour < 12) return 'Günaydın,';
    if (hour < 18) return 'İyi günler,';
    return 'İyi akşamlar,';
  }
}