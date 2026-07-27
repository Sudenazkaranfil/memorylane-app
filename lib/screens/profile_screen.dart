import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';
import '../services/journal_service.dart';
import 'edit_profile_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'help_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _username;
  String? _firstName;
  String? _lastName;
  String? _bio;
  String? _profileImageUrl;
  int _journalCount = 0;
  int _entryCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final username = await StorageService.getUsername();
    final token = await StorageService.getToken();
    final journals = await JournalService.getJournals();

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/auth/profile'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _firstName = data['firstName'];
          _lastName = data['lastName'];
          _bio = data['bio'];
          _profileImageUrl = data['profileImageUrl'];
        });
      }
    } catch (e) {}

    setState(() {
      _username = username ?? 'Gezgin';
      _journalCount = journals.length;
      _isLoading = false;
    });
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Çıkış yap', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
        content: Text('Hesabınızdan çıkış yapmak istiyor musunuz?', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
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
            child: const Text('Çıkış yap'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await StorageService.clearAll();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.terracotta))
          : SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              _buildStats(),
              _buildMenu(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditProfileScreen()),
              );
              if (updated == true) _loadProfile();
            },
            child: Stack(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.terracottaLight,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: _profileImageUrl != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Image.network(_profileImageUrl!, fit: BoxFit.cover),
                  )
                      : const Icon(Icons.person_outline, color: AppTheme.terracotta, size: 40),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppTheme.terracotta,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _firstName != null && _lastName != null
                ? '$_firstName $_lastName'
                : _username ?? 'Gezgin',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            '@${_username ?? ''}',
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
          if (_bio != null && _bio!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _bio!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Ajanda', _journalCount.toString(), Icons.book_outlined),
          _buildDivider(),
          _buildStatItem('Sayfa', _entryCount.toString(), Icons.article_outlined),
          _buildDivider(),
          _buildStatItem('Ülke', '0', Icons.public),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.terracotta, size: 24),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 48, color: AppTheme.border);
  }

  Widget _buildMenu() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          _buildMenuItem(Icons.person_outline, 'Profili Düzenle', () async {
            final updated = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EditProfileScreen()),
            );
            if (updated == true) _loadProfile();
          }),
          _buildMenuDivider(),
          _buildMenuItem(Icons.notifications_outlined, 'Bildirimler', () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Yakında!')));
          }),
          _buildMenuDivider(),
          _buildMenuItem(Icons.language, 'Dil', () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Yakında!')));
          }),
          _buildMenuDivider(),
          _buildMenuItem(Icons.help_outline, 'Yardım', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HelpScreen()),
            );
          }),
          _buildMenuDivider(),
          _buildMenuItem(Icons.logout, 'Çıkış Yap', _logout, isDestructive: true),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, VoidCallback onTap, {bool isDestructive = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: isDestructive ? Colors.red.shade400 : AppTheme.textSecondary, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 15, color: isDestructive ? Colors.red.shade400 : AppTheme.textPrimary),
              ),
            ),
            if (!isDestructive)
              Icon(Icons.chevron_right, color: AppTheme.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuDivider() {
    return Divider(height: 1, color: AppTheme.border, indent: 20, endIndent: 20);
  }
}