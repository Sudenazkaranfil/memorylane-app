import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(children: [
        // Dark header
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppTheme.navDark,
            borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(28)),
            boxShadow: [BoxShadow(
                color: AppTheme.navDark.withOpacity(0.3),
                blurRadius: 16, offset: const Offset(0, 6))],
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
              child: Row(children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 18),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.1),
                    padding: const EdgeInsets.all(8),
                  ),
                ),
                const SizedBox(width: 8),
                Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Gizlilik Politikası',
                          style: GoogleFonts.playfairDisplay(
                              fontSize: 17, fontWeight: FontWeight.w800,
                              color: Colors.white, letterSpacing: -0.3)),
                      Text('Seyahood Veri Güvenliği',
                          style: AppTheme.sansBody(
                              size: 11, weight: FontWeight.w600,
                              color: AppTheme.terracotta)),
                    ]),
              ]),
            ),
          ),
        ),

        // Body
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.border),
                  boxShadow: [BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Row(children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.terracottaLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppTheme.terracotta.withOpacity(0.35)),
                    ),
                    child: const Center(child: Icon(Icons.shield_outlined,
                        color: AppTheme.terracotta, size: 24)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Şeffaf & Güvenli Seyahat',
                            style: GoogleFonts.playfairDisplay(
                                fontSize: 14, fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary)),
                        const SizedBox(height: 2),
                        Text('Son güncelleme: Ağustos 2026',
                            style: AppTheme.sansBody(
                                size: 11, weight: FontWeight.w600,
                                color: AppTheme.terracotta)),
                      ])),
                ]),
              ),
              const SizedBox(height: 20),
              _buildSection('1. Giriş',
                  'Seyahood olarak kişisel verilerinizin güvenliğine önem veriyoruz. Bu Gizlilik Politikası, uygulamamızı kullandığınızda hangi verileri topladığımızı, bu verileri nasıl kullandığımızı ve haklarınızı açıklamaktadır.',
                  icon: Icons.info_outline_rounded),
              _buildSection('2. Topladığımız Veriler',
                  '• Hesap Bilgileri: Kayıt sırasında kullanıcı adı ve e-posta adresi topluyoruz.\n\n• Profil Bilgileri: Ad, soyad, biyografi, konum ve profil fotoğrafı gibi isteğe bağlı bilgiler.\n\n• İçerik Verileri: Oluşturduğunuz ajandalar, sayfalar, fotoğraflar, çizimler ve konum etiketleri.\n\n• Kullanım Verileri: Uygulama içi etkileşimler ve tercihler.',
                  icon: Icons.folder_open_outlined),
              _buildSection('3. Verilerin Kullanımı',
                  'Topladığımız veriler şu amaçlarla kullanılmaktadır:\n\n• Hesabınızı oluşturmak ve yönetmek\n• Uygulama özelliklerini sunmak ve geliştirmek\n• Fotoğraflarınızı güvenli şekilde depolamak\n• Gerekli sistem bildirimleri göndermek\n• Güvenlik ve doğrulama işlemleri',
                  icon: Icons.auto_stories_outlined),
              _buildSection('4. Veri Paylaşımı',
                  'Kişisel verilerinizi üçüncü taraflarla satmıyor veya kiralamıyoruz. Verileriniz yalnızca aşağıdaki hizmet sağlayıcılarla paylaşılmaktadır:\n\n• Cloudinary: Fotoğraf depolama hizmeti\n• Render: Sunucu altyapısı\n• OpenStreetMap/Nominatim: Harita ve konum hizmetleri',
                  icon: Icons.cloud_done_outlined),
              _buildSection('5. Veri Güvenliği',
                  'Verilerinizin güvenliği için endüstri standardı önlemler alıyoruz:\n\n• Şifreler bcrypt algoritması ile hashlenerek saklanır\n• Tüm iletişim HTTPS protokolü ile şifrelenir\n• JWT token\'ları ile güvenli oturum yönetimi sağlanır\n• Veriler güvenli bulut sunucularında saklanır',
                  icon: Icons.lock_outline_rounded),
              _buildSection('6. Veri Saklama',
                  'Verileriniz hesabınız aktif olduğu sürece saklanır. Hesabınızı silmeniz durumunda tüm kişisel verileriniz 30 gün içinde kalıcı olarak silinir.',
                  icon: Icons.hourglass_empty_rounded),
              _buildSection('7. Haklarınız',
                  'Kişisel verileriniz üzerinde aşağıdaki haklara sahipsiniz:\n\n• Verilerinize erişim talep etme\n• Yanlış verilerin düzeltilmesini isteme\n• Verilerinizin silinmesini talep etme\n• Veri işlemeye itiraz etme\n\nBu haklarınızı kullanmak için noreply.memorylane@gmail.com adresine yazabilirsiniz.',
                  icon: Icons.verified_user_outlined),
              _buildSection('8. Çerezler ve Takip',
                  'Uygulamamız çerez kullanmamaktadır. Kullanıcı tercihleriniz yalnızca cihazınızda yerel olarak saklanır.',
                  icon: Icons.cookie_outlined),
              _buildSection('9. Çocukların Gizliliği',
                  '13 yaşın altındaki çocuklardan bilerek kişisel veri toplamıyoruz.',
                  icon: Icons.family_restroom_outlined),
              _buildSection('10. Politika Güncellemeleri',
                  'Bu gizlilik politikasını zaman zaman güncelleyebiliriz. Önemli değişiklikler olduğunda uygulama üzerinden bildirim göndereceğiz.',
                  icon: Icons.update_rounded),
              _buildSection('11. İletişim',
                  'Gizlilik politikamız veya kişisel verilerinizle ilgili sorularınız için:\n\nE-posta: noreply.memorylane@gmail.com\n\nSeyahood ekibi olarak gizliliğinize saygı duyuyor ve verilerinizi korumayı taahhüt ediyoruz.',
                  icon: Icons.mail_outline_rounded, isContact: true),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildSection(String title, String content,
      {required IconData icon, bool isContact = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isContact ? AppTheme.terracottaLight : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: isContact
                ? AppTheme.terracotta.withOpacity(0.4) : AppTheme.border,
            width: isContact ? 1.4 : 1.0),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 18, color: AppTheme.terracotta),
          const SizedBox(width: 8),
          Expanded(child: Text(title,
              style: GoogleFonts.playfairDisplay(
                  fontSize: 15, fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary))),
        ]),
        const SizedBox(height: 10),
        Text(content, style: TextStyle(
            fontSize: 13.5,
            color: isContact
                ? const Color(0xFF523F31) : AppTheme.textSecondary,
            height: 1.6)),
      ]),
    );
  }
}