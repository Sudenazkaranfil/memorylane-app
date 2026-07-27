import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';
import '../services/storage_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();
  final _websiteController = TextEditingController();
  final _favoriteDestinationController = TextEditingController();
  bool _isLoading = false;
  String? _profileImageUrl;
  String? _localImagePath;

  static const String baseUrl = 'http://10.0.2.2:8080';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final token = await StorageService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/auth/profile'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _firstNameController.text = data['firstName'] ?? '';
          _lastNameController.text = data['lastName'] ?? '';
          _bioController.text = data['bio'] ?? '';
          _locationController.text = data['location'] ?? '';
          _websiteController.text = data['website'] ?? '';
          _favoriteDestinationController.text = data['favoriteDestination'] ?? '';
          _profileImageUrl = data['profileImageUrl'];
        });
      }
    } catch (e) {}
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _localImagePath = image.path);
    }
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      final token = await StorageService.getToken();
      String? imageUrl = _profileImageUrl;

      final response = await http.put(
        Uri.parse('$baseUrl/auth/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'bio': _bioController.text.trim(),
          'location': _locationController.text.trim(),
          'website': _websiteController.text.trim(),
          'favoriteDestination': _favoriteDestinationController.text.trim(),
          'profileImageUrl': imageUrl,
        }),
      );

      if (response.statusCode == 200 && mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil güncellendi!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Güncellenemedi, tekrar dene!')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _websiteController.dispose();
    _favoriteDestinationController.dispose();
    super.dispose();
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
        title: const Text('Profili Düzenle', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
        actions: [
          _isLoading
              ? const Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.terracotta)),
          )
              : TextButton(
            onPressed: _save,
            child: Text('Kaydet', style: TextStyle(color: AppTheme.terracotta, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.terracottaLight,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: _localImagePath != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.file(File(_localImagePath!), fit: BoxFit.cover),
                    )
                        : _profileImageUrl != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.network(_profileImageUrl!, fit: BoxFit.cover),
                    )
                        : const Icon(Icons.person_outline, color: AppTheme.terracotta, size: 48),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppTheme.terracotta,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildField('Ad', _firstNameController, 'Adınız'),
            const SizedBox(height: 16),
            _buildField('Soyad', _lastNameController, 'Soyadınız'),
            const SizedBox(height: 16),
            _buildField('Hakkında', _bioController, 'Kendinizden bahsedin...', maxLines: 3),
            const SizedBox(height: 16),
            _buildField('Konum', _locationController, 'İstanbul, Türkiye', prefixIcon: Icons.location_on_outlined),
            const SizedBox(height: 16),
            _buildField('Web Sitesi', _websiteController, 'https://...', prefixIcon: Icons.link),
            const SizedBox(height: 16),
            _buildField('Favori Destinasyon', _favoriteDestinationController, 'Paris, Tokyo...', prefixIcon: Icons.favorite_outline),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, String hint, {int maxLines = 1, IconData? prefixIcon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: AppTheme.caption.copyWith(fontWeight: FontWeight.w600, letterSpacing: 1)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppTheme.textSecondary),
            filled: true,
            fillColor: AppTheme.terracottaLight,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppTheme.textSecondary, size: 20) : null,
          ),
        ),
      ],
    );
  }
}