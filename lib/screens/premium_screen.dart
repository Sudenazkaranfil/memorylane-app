import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/subscription_service.dart';
import '../theme/app_theme.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  bool _isYearly = false;
  bool _isLoading = true;
  String _currentPlan = 'FREE';

  static const List<_ComparisonFeature> _features = [
    _ComparisonFeature(
      icon: Icons.auto_stories_rounded,
      label: 'Ajanda sayısı',
      free: '5',
      plus: '20',
      pro: 'Sınırsız',
    ),
    _ComparisonFeature(
      icon: Icons.description_outlined,
      label: 'Ajanda başına sayfa',
      free: '15',
      plus: '40',
      pro: 'Sınırsız',
    ),
    _ComparisonFeature(
      icon: Icons.block_flipped,
      label: 'Reklamsız deneyim',
      free: null,
      plus: '✓',
      pro: '✓',
    ),
    _ComparisonFeature(
      icon: Icons.font_download_outlined,
      label: 'Premium canvas fontları',
      free: null,
      plus: null,
      pro: '✓',
    ),
    _ComparisonFeature(
      icon: Icons.high_quality_outlined,
      label: '4K kalitede dışa aktarma',
      free: null,
      plus: null,
      pro: '✓',
    ),
    _ComparisonFeature(
      icon: Icons.dashboard_customize_outlined,
      label: 'Paylaşım şablonları',
      free: '2/6',
      plus: '4/6',
      pro: '6/6',
    ),
    _ComparisonFeature(
      icon: Icons.support_agent_rounded,
      label: 'Öncelikli destek',
      free: null,
      plus: null,
      pro: '✓',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    try {
      final status = await SubscriptionService.getStatus();
      if (!mounted) return;
      setState(() {
        _currentPlan = status.plan;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _handlePurchase(String planLabel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(context).padding.bottom + 24,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: AppTheme.terracottaLight,
              shape: BoxShape.circle,
            ),
            child: const Center(
                child: Text('⏳', style: TextStyle(fontSize: 26))),
          ),
          const SizedBox(height: 16),
          Text('$planLabel yakında aktif oluyor',
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                  fontSize: 17, fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          Text(
              'Satın alma altyapısı tamamlandığında bu plana '
              'buradan hemen abone olabileceksin.',
              textAlign: TextAlign.center,
              style: AppTheme.sansBody(
                  size: 13, color: AppTheme.textSecondary)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Anladım'),
            ),
          ),
        ]),
      ),
    );
  }

  String _planLabel(String plan) {
    switch (plan) {
      case 'PLUS':
        return 'Plus';
      case 'PRO':
        return 'PRO';
      default:
        return 'Free';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(children: [
        SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildBillingToggle(),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(children: [
                  _buildPlanCard(
                    planKey: 'PLUS',
                    title: 'Seyahood Plus',
                    ctaLabel: "Plus'a Geç",
                    emoji: '🌿',
                    color: AppTheme.sage,
                    monthlyPrice: 49.99,
                    yearlyPrice: 479.99,
                    highlight: false,
                    tagline: 'Daha fazla ajanda ve reklamsız deneyim',
                  ),
                  const SizedBox(height: 16),
                  _buildPlanCard(
                    planKey: 'PRO',
                    title: 'Seyahood PRO',
                    ctaLabel: "PRO'ya Geç",
                    emoji: '👑',
                    color: AppTheme.terracotta,
                    monthlyPrice: 99.99,
                    yearlyPrice: 959.99,
                    highlight: true,
                    tagline: 'Sınırsız ajanda ve tüm premium özellikler',
                  ),
                ]),
              ),
              const SizedBox(height: 28),
              _buildComparisonTable(),
              const SizedBox(height: 16),
              _buildRestoreRow(),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 24),
            ]),
          ),
        ),
        Positioned(
          top: 12, left: 12,
          child: SafeArea(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  shape: BoxShape.circle,
                  boxShadow: [AppTheme.softShadow],
                ),
                child: const Icon(Icons.close_rounded,
                    color: AppTheme.textPrimary, size: 20),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 56, 24, 28),
      decoration: const BoxDecoration(
        color: AppTheme.navDark,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: const Center(
              child: Text('👑', style: TextStyle(fontSize: 30))),
        ),
        const SizedBox(height: 16),
        Text('Seyahood Premium',
            style: GoogleFonts.playfairDisplay(
                fontSize: 24, fontWeight: FontWeight.w700,
                color: Colors.white, letterSpacing: -0.5)),
        const SizedBox(height: 6),
        Text('Seyahatlerini sınırsız sayfada anlat',
            textAlign: TextAlign.center,
            style: AppTheme.sansBody(
                size: 13, color: Colors.white.withOpacity(0.7))),
        const SizedBox(height: 14),
        if (!_isLoading)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Text('Mevcut plan: ${_planLabel(_currentPlan)}',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                    color: Colors.white.withOpacity(0.85))),
          ),
      ]),
    );
  }

  Widget _buildBillingToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.terracottaLight,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(children: [
        Expanded(child: _billingOption('Aylık', !_isYearly, false)),
        Expanded(child: _billingOption('Yıllık · %20 indirim', _isYearly, true)),
      ]),
    );
  }

  Widget _billingOption(String label, bool selected, bool isYearlyValue) {
    return GestureDetector(
      onTap: () => setState(() => _isYearly = isYearlyValue),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.navDark : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Center(
          child: Text(label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : AppTheme.textSecondary)),
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String planKey,
    required String title,
    required String ctaLabel,
    required String emoji,
    required Color color,
    required double monthlyPrice,
    required double yearlyPrice,
    required bool highlight,
    required String tagline,
  }) {
    final price = _isYearly ? yearlyPrice : monthlyPrice;
    final period = _isYearly ? '/yıl' : '/ay';
    final isCurrent = _currentPlan == planKey;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: highlight ? color : AppTheme.border,
            width: highlight ? 2 : 1),
        boxShadow: [highlight ? AppTheme.cardShadow : AppTheme.softShadow],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Row(children: [
                  Text(title,
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 17, fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary)),
                  if (highlight) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('ÖNERİLEN',
                          style: TextStyle(fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                    ),
                  ],
                ]),
                const SizedBox(height: 2),
                Text(tagline,
                    style: AppTheme.sansBody(
                        size: 12, color: AppTheme.textSecondary)),
              ])),
        ]),
        const SizedBox(height: 16),
        Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('₺${price.toStringAsFixed(2)}',
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 26, fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary)),
              const SizedBox(width: 4),
              Text(period,
                  style: AppTheme.sansBody(
                      size: 13, color: AppTheme.textSecondary)),
            ]),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isCurrent ? null : () => _handlePurchase(title),
            style: ElevatedButton.styleFrom(
              backgroundColor: isCurrent ? AppTheme.border : color,
              foregroundColor: isCurrent ? AppTheme.textSecondary : Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(isCurrent ? 'Mevcut Planın' : ctaLabel,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w800)),
          ),
        ),
      ]),
    );
  }

  Widget _buildComparisonTable() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.cardDecoration,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Detaylı Karşılaştırma',
            style: GoogleFonts.playfairDisplay(
                fontSize: 16, fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary)),
        const SizedBox(height: 4),
        Text('Free, Plus ve PRO plan farkları',
            style: AppTheme.sansBody(size: 12, color: AppTheme.textSecondary)),
        const SizedBox(height: 16),
        Row(children: [
          const Expanded(flex: 3, child: SizedBox()),
          Expanded(
              flex: 2,
              child: Center(
                  child: Text('Free',
                      style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w700,
                          color: AppTheme.textSecondary)))),
          Expanded(
              flex: 2,
              child: Center(
                  child: Text('Plus',
                      style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w800,
                          color: AppTheme.sage)))),
          Expanded(
              flex: 2,
              child: Center(
                  child: Text('PRO',
                      style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w800,
                          color: AppTheme.terracotta)))),
        ]),
        const SizedBox(height: 8),
        const Divider(height: 1, color: AppTheme.border),
        ..._features.map(_buildFeatureRow),
      ]),
    );
  }

  Widget _buildFeatureRow(_ComparisonFeature f) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
          border:
              Border(bottom: BorderSide(color: AppTheme.border, width: 0.5))),
      child: Row(children: [
        Expanded(
            flex: 3,
            child: Row(children: [
              Icon(f.icon, size: 15, color: AppTheme.terracotta),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(f.label,
                      style: AppTheme.sansBody(
                          size: 12, weight: FontWeight.w600))),
            ])),
        Expanded(flex: 2, child: Center(child: _buildFeatureValue(f.free))),
        Expanded(flex: 2, child: Center(child: _buildFeatureValue(f.plus))),
        Expanded(flex: 2, child: Center(child: _buildFeatureValue(f.pro))),
      ]),
    );
  }

  Widget _buildFeatureValue(String? value) {
    if (value == null) {
      return const Icon(Icons.remove_rounded, size: 15, color: AppTheme.textMuted);
    }
    if (value == '✓') {
      return const Icon(Icons.check_circle_rounded,
          size: 16, color: AppTheme.sage);
    }
    return Text(value,
        style: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary));
  }

  Widget _buildRestoreRow() {
    return Center(
      child: TextButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                  'Satın almalar RevenueCat entegrasyonu ile geri yüklenebilecek')));
        },
        child: const Text('Satın Alımları Geri Yükle'),
      ),
    );
  }
}

class _ComparisonFeature {
  final IconData icon;
  final String label;
  final String? free;
  final String? plus;
  final String? pro;

  const _ComparisonFeature({
    required this.icon,
    required this.label,
    required this.free,
    required this.plus,
    required this.pro,
  });
}
