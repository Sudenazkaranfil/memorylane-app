import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

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
                      Text('Yardım & Destek',
                          style: GoogleFonts.playfairDisplay(
                              fontSize: 17, fontWeight: FontWeight.w800,
                              color: Colors.white, letterSpacing: -0.3)),
                      Text('Gezgin Kılavuzu & SSS',
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
              _buildSection('Başlarken', Icons.explore_outlined, [
                _buildFaq('Nasıl ajanda oluştururum?',
                    'Ana ekranda "Anını Bırak" butonuna bas, ajanda adını ve gizlilik ayarını seç.'),
                _buildFaq('Sayfama nasıl içerik eklerim?',
                    'Ajandana gir, + butonuna bas. Fotoğraf, yazı, emoji, konum veya çizim ekleyebilirsin.'),
                _buildFaq('Sayfamı nasıl kaydederim?',
                    'Canvas editörde sağ üstteki "Kaydet" butonuna bas.'),
              ]),
              const SizedBox(height: 20),
              _buildSection('Gizlilik & Paylaşım', Icons.lock_outline_rounded, [
                _buildFaq('Ajandamı herkese açık yapabilir miyim?',
                    'Evet! Ajandana gir, sağ üstteki üç nokta menüsünden "Herkese aç" seç.'),
                _buildFaq('Özel ajandamı kimler görebilir?',
                    'Özel ajandanı sadece sen görebilirsin.'),
                _buildFaq('Herkese açık ajandamı kim görebilir?',
                    'Herkese açık ajandalar Keşfet ekranında ve haritada görünür.'),
              ]),
              const SizedBox(height: 20),
              _buildSection('Harita & Konum', Icons.map_outlined, [
                _buildFaq('Haritada konumum neden görünmüyor?',
                    'Sayfa eklerken konum eklediğinden emin ol. Konum olmadan haritada görünmez.'),
                _buildFaq('Haritam ve Keşfet haritası arasındaki fark nedir?',
                    'Haritam sadece senin konumlarını gösterir. Keşfet haritası herkese açık konumları gösterir.'),
              ]),
              const SizedBox(height: 20),
              _buildSection('Hesap Ayarları', Icons.person_outline_rounded, [
                _buildFaq('Şifremi nasıl değiştiririm?',
                    'Giriş ekranında "Şifreni mi unuttun?" linkine tıkla, e-posta ile sıfırlayabilirsin.'),
                _buildFaq('Hesabımı nasıl silebilirim?',
                    'Hesap silme özelliği yakında eklenecek. Şimdilik destek için bize ulaşabilirsin.'),
              ]),
              const SizedBox(height: 22),

              // Bize ulaş
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.terracottaLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppTheme.terracotta.withOpacity(0.35), width: 1.4),
                  boxShadow: [BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(
                          color: AppTheme.terracotta,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(child: Icon(
                            Icons.mail_outline_rounded,
                            color: Colors.white, size: 22)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Bize Ulaşın', style: GoogleFonts.playfairDisplay(
                                fontSize: 15, fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary)),
                            const SizedBox(height: 4),
                            Text('Sorunların, önerilerin veya yolculuk hikayelerin için:',
                                style: AppTheme.sansBody(
                                    size: 12, color: const Color(0xFF523F31))),
                            const SizedBox(height: 6),
                            Text('destek@seyahood.app',
                                style: AppTheme.sansBody(
                                    size: 13, weight: FontWeight.w700,
                                    color: AppTheme.terracotta)),
                          ])),
                    ]),
              ),
              const SizedBox(height: 22),

              // Gizlilik politikası linki
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Row(children: [
                    Icon(Icons.shield_outlined,
                        size: 11, color: AppTheme.terracotta),
                    const SizedBox(width: 6),
                    Text('YASAL & GÜVENCE',
                        style: AppTheme.sansBody(
                            size: 11, weight: FontWeight.w700,
                            color: AppTheme.terracotta)),
                  ]),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppTheme.border),
                    boxShadow: [BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8, offset: const Offset(0, 3))],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 4),
                      leading: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: AppTheme.terracottaLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.shield_outlined,
                            color: AppTheme.terracotta, size: 20),
                      ),
                      title: Text('Gizlilik Politikası',
                          style: AppTheme.sansBody(
                              size: 14, weight: FontWeight.w700,
                              color: AppTheme.textPrimary)),
                      subtitle: Text('Kişisel veri koruma ve saklama kuralları',
                          style: AppTheme.sansBody(
                              size: 11, color: AppTheme.textSecondary)),
                      trailing: Icon(Icons.arrow_forward_ios_rounded,
                          color: AppTheme.textSecondary, size: 14),
                      onTap: () => Navigator.pushNamed(context, '/privacy'),
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> faqs) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Row(children: [
          Icon(icon, size: 14, color: AppTheme.terracotta),
          const SizedBox(width: 6),
          Text(title.toUpperCase(), style: AppTheme.sansBody(
              size: 11, weight: FontWeight.w700,
              color: AppTheme.terracotta)),
        ]),
      ),
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.border),
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Column(children: faqs),
        ),
      ),
    ]);
  }

  Widget _buildFaq(String question, String answer) {
    return Theme(
      data: ThemeData().copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
        title: Text(question, style: AppTheme.sansBody(
            size: 14, weight: FontWeight.w600, color: AppTheme.textPrimary)),
        iconColor: AppTheme.terracotta,
        collapsedIconColor: AppTheme.textSecondary,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF7F2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppTheme.border.withOpacity(0.6)),
            ),
            child: Text(answer, style: AppTheme.sansBody(
                size: 13, color: AppTheme.textSecondary)),
          ),
        ],
      ),
    );
  }
}