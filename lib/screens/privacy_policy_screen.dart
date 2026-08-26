import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
        title: const Text('Gizlilik Politikası', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSection('Gizlilik Politikası',
              'Son güncelleme: Ağustos 2026\n\nMemoryLane ("uygulama", "biz") olarak gizliliğinize önem veriyoruz. Bu politika, kişisel verilerinizi nasıl topladığımızı, kullandığımızı ve koruduğumuzu açıklar.'),
          _buildSection('Topladığımız Veriler',
              '• Hesap bilgileri: kullanıcı adı, e-posta adresi\n• Profil bilgileri: ad, soyad, biyografi, konum, profil fotoğrafı\n• İçerik verileri: ajandalar, sayfalar, fotoğraflar, çizimler\n• Konum verileri: sayfalara eklediğiniz konum bilgileri'),
          _buildSection('Verileri Nasıl Kullanıyoruz',
              '• Hesabınızı oluşturmak ve yönetmek\n• Uygulama özelliklerini sunmak\n• Fotoğraflarınızı güvenli şekilde depolamak (Cloudinary)\n• E-posta bildirimleri göndermek'),
          _buildSection('Veri Güvenliği',
              'Verileriniz şifrelenerek güvenli sunucularda saklanır. Şifreleriniz bcrypt algoritması ile hashlenir. JWT token\'ları ile güvenli oturum yönetimi sağlanır.'),
          _buildSection('Üçüncü Taraf Hizmetler',
              '• Cloudinary: fotoğraf depolama\n• Render: sunucu altyapısı\n• OpenStreetMap: harita hizmetleri\n• Nominatim: konum arama'),
          _buildSection('Verilerinizin Kontrolü',
              '• Hesabınızı istediğiniz zaman silebilirsiniz\n• Profil bilgilerinizi düzenleyebilirsiniz\n• Ajandalarınızı ve sayfalarınızı silebilirsiniz\n• Verilerinizin silinmesi için support@memorylane.app adresine yazabilirsiniz'),
          _buildSection('Çocukların Gizliliği',
              '13 yaşın altındaki çocuklardan bilerek veri toplamıyoruz. Bu tür bir durumun farkına varırsak ilgili verileri derhal sileriz.'),
          _buildSection('Politika Değişiklikleri',
              'Bu politikayı zaman zaman güncelleyebiliriz. Önemli değişiklikler olduğunda uygulama üzerinden bildirim göndereceğiz.'),
          _buildSection('İletişim',
              'Gizlilik politikamız hakkında sorularınız için:\nnoreply.memorylane@gmail.com'),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          Text(content, style: TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.6)),
        ],
      ),
    );
  }
}