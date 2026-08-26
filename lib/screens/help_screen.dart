import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

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
        title: const Text('Yardım', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSection('Başlarken', [
            _buildFaq('Nasıl ajanda oluştururum?', 'Ana ekranda sağ alttaki + butonuna bas, ajanda adını ve gizlilik ayarını seç.'),
            _buildFaq('Sayfama nasıl içerik eklerim?', 'Ajandana gir, + butonuna bas. Fotoğraf, yazı, emoji, konum veya çizim ekleyebilirsin.'),
            _buildFaq('Sayfamı nasıl kaydederim?', 'Canvas editörde sağ üstteki "Kaydet" butonuna bas.'),
          ]),
          const SizedBox(height: 24),
          _buildSection('Gizlilik', [
            _buildFaq('Ajandamı herkese açık yapabilir miyim?', 'Evet! Ajandana gir, sağ üstteki üç nokta menüsünden "Herkese aç" seç.'),
            _buildFaq('Özel ajandamı kimler görebilir?', 'Özel ajandanı sadece sen görebilirsin.'),
            _buildFaq('Public ajandamı kim görebilir?', 'Herkese açık ajandalar Keşfet ekranında ve haritada görünür.'),
          ]),
          const SizedBox(height: 24),
          _buildSection('Harita', [
            _buildFaq('Haritada konumum neden görünmüyor?', 'Sayfa eklerken konum eklediğinden emin ol. Konum olmadan haritada görünmez.'),
            _buildFaq('Haritamda ve Keşfet haritasında ne fark var?', 'Haritam sadece senin konumlarını gösterir. Keşfet haritası herkese açık konumları gösterir.'),
          ]),
          const SizedBox(height: 24),
          _buildSection('Hesap', [
            _buildFaq('Şifremi nasıl değiştiririm?', 'Şu an şifre değiştirme özelliği geliştirme aşamasında, yakında eklenecek.'),
            _buildFaq('Hesabımı nasıl silebilirim?', 'Hesap silme özelliği yakında eklenecek. Şimdilik destek için bize ulaşabilirsin.'),
          ]),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.terracottaLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Bize Ulaş', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
                const SizedBox(height: 8),
                Text('Sorunların veya önerilerin için:', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                const SizedBox(height: 8),
                Text('support@memorylane.app', style: TextStyle(fontSize: 13, color: AppTheme.terracotta, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSection('Yasal', [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Gizlilik Politikası', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
              trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
              onTap: () => Navigator.pushNamed(context, '/privacy'),
            ),
          ]),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> faqs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary, letterSpacing: 1)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(children: faqs),
        ),
      ],
    );
  }

  Widget _buildFaq(String question, String answer) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      title: Text(question, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
      iconColor: AppTheme.terracotta,
      collapsedIconColor: AppTheme.textSecondary,
      children: [
        Text(answer, style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5)),
      ],
    );
  }
}
