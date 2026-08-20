import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/user_service.dart';
import '../services/journal_service.dart';
import '../models/journal.dart';
import 'explore_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final String username;
  const UserProfileScreen({super.key, required this.username});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  Map<String, dynamic>? _user;
  Map<String, dynamic>? _followStatus;
  List<Journal> _journals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final user = await UserService.getUserProfile(widget.username);
      final followStatus = await UserService.getFollowStatus(widget.username);
      final journals = await JournalService.getPublicJournals();
      final userJournals = journals.where((j) => j.username == widget.username).toList();

      setState(() {
        _user = user;
        _followStatus = followStatus;
        _journals = userJournals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFollow() async {
    try {
      final following = await UserService.toggleFollow(widget.username);
      setState(() {
        _followStatus!['following'] = following;
        if (following) {
          _followStatus!['followerCount'] = (_followStatus!['followerCount'] as int) + 1;
        } else {
          _followStatus!['followerCount'] = (_followStatus!['followerCount'] as int) - 1;
        }
      });
    } catch (e) {}
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
        title: Text('@${widget.username}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.terracotta))
          : SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildJournals(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final isFollowing = _followStatus?['following'] ?? false;
    final followerCount = _followStatus?['followerCount'] ?? 0;
    final followingCount = _followStatus?['followingCount'] ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(color: AppTheme.terracottaLight, borderRadius: BorderRadius.circular(40)),
            child: _user?['profileImageUrl'] != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Image.network(_user!['profileImageUrl'], fit: BoxFit.cover),
            )
                : const Icon(Icons.person_outline, color: AppTheme.terracotta, size: 40),
          ),
          const SizedBox(height: 12),
          Text(
            _user?['firstName'] != null && _user?['lastName'] != null
                ? '${_user!['firstName']} ${_user!['lastName']}'
                : widget.username,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
          ),
          Text('@${widget.username}', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          if (_user?['bio'] != null && _user!['bio'].isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(_user!['bio'], textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5)),
          ],
          if (_user?['location'] != null && _user!['location'].isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.textSecondary),
                const SizedBox(width: 4),
                Text(_user!['location'], style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStat('Ajanda', _journals.length.toString()),
              const SizedBox(width: 32),
              _buildStat('Takipçi', followerCount.toString()),
              const SizedBox(width: 32),
              _buildStat('Takip', followingCount.toString()),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 160,
            height: 40,
            child: ElevatedButton(
              onPressed: _toggleFollow,
              style: ElevatedButton.styleFrom(
                backgroundColor: isFollowing ? Colors.white : AppTheme.terracotta,
                foregroundColor: isFollowing ? AppTheme.terracotta : Colors.white,
                side: isFollowing ? BorderSide(color: AppTheme.terracotta) : null,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Text(isFollowing ? 'Takip Ediliyor' : 'Takip Et', style: const TextStyle(fontWeight: FontWeight.w500)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
        Text(label, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      ],
    );
  }

  Widget _buildJournals() {
    if (_journals.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Text('Henüz public ajanda yok', style: TextStyle(color: AppTheme.textSecondary)),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ajandalar', style: AppTheme.caption.copyWith(fontWeight: FontWeight.w600, letterSpacing: 1.5)),
          const SizedBox(height: 12),
          ...(_journals.map((journal) => GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ExploreJournalScreen(journal: journal))),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.border)),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), bottomLeft: Radius.circular(14)),
                    child: journal.coverImageUrl != null
                        ? Image.network(journal.coverImageUrl!, width: 72, height: 72, fit: BoxFit.cover)
                        : Container(width: 72, height: 72, color: AppTheme.terracottaLight, child: const Icon(Icons.book_outlined, color: AppTheme.terracotta)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(journal.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
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
                  const Padding(padding: EdgeInsets.only(right: 12), child: Icon(Icons.chevron_right, color: AppTheme.textSecondary)),
                ],
              ),
            ),
          ))).toList(),
        ],
      ),
    );
  }
}