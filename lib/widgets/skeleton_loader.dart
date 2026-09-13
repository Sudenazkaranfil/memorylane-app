import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SkeletonBox extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const SkeletonBox({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.radius = 8,
  });

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: const Color(0xFFEADBCE),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

class HomeSkeletonLoader extends StatelessWidget {
  const HomeSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 110),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [
            const SkeletonBox(width: 44, height: 44, radius: 22),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SkeletonBox(width: 120, height: 14),
              const SizedBox(height: 6),
              const SkeletonBox(width: 80, height: 10),
            ]),
            const Spacer(),
            const SkeletonBox(width: 40, height: 40, radius: 20),
          ]),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: SkeletonBox(height: 270, radius: 24),
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: SkeletonBox(height: 64, radius: 20),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            const SkeletonBox(width: 100, height: 18),
            const Spacer(),
            const SkeletonBox(width: 60, height: 14),
          ]),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 195,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 3,
            itemBuilder: (context, index) => Container(
              width: 175,
              margin: const EdgeInsets.only(right: 12),
              child: const SkeletonBox(height: 195, radius: 20),
            ),
          ),
        ),
      ]),
    );
  }
}

class ExploreSkeletonLoader extends StatelessWidget {
  const ExploreSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SkeletonBox(width: 160, height: 28),
        const SizedBox(height: 6),
        const SkeletonBox(width: 220, height: 14),
        const SizedBox(height: 14),
        const SkeletonBox(height: 48, radius: 16),
        const SizedBox(height: 10),
        Row(children: List.generate(4, (i) => Container(
          margin: const EdgeInsets.only(right: 8),
          child: const SkeletonBox(width: 80, height: 34, radius: 20),
        ))),
        const SizedBox(height: 16),
        const SkeletonBox(height: 220, radius: 24),
        const SizedBox(height: 14),
        ...List.generate(3, (i) => const Padding(
          padding: EdgeInsets.only(bottom: 14),
          child: SkeletonBox(height: 200, radius: 20),
        )),
      ]),
    );
  }
}

class ProfileSkeletonLoader extends StatelessWidget {
  const ProfileSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(children: [
        Container(
          color: Colors.white,
          child: Column(children: [
            const SkeletonBox(height: 110, radius: 0),
            const SizedBox(height: 48),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(children: [
                const SkeletonBox(width: 160, height: 22),
                const SizedBox(height: 8),
                const SkeletonBox(width: 100, height: 14),
                const SizedBox(height: 12),
                const SkeletonBox(height: 14),
                const SizedBox(height: 6),
                const SkeletonBox(width: 200, height: 14),
                const SizedBox(height: 20),
                const SkeletonBox(height: 46, radius: 16),
                const SizedBox(height: 20),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 14),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: SkeletonBox(height: 72, radius: 24),
        ),
        const SizedBox(height: 14),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: SkeletonBox(height: 90, radius: 20),
        ),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, crossAxisSpacing: 10,
                mainAxisSpacing: 14, childAspectRatio: 0.72),
            itemCount: 6,
            itemBuilder: (_, __) => const SkeletonBox(radius: 12),
          ),
        ),
      ]),
    );
  }
}

class JournalDetailSkeletonLoader extends StatelessWidget {
  const JournalDetailSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const SkeletonBox(height: 200, radius: 0),
      const SizedBox(height: 12),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 72),
          child: const SkeletonBox(radius: 24),
        ),
      ),
    ]);
  }
}

class MapSkeletonLoader extends StatelessWidget {
  const MapSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(color: const Color(0xFFE8E0D8)),
      Positioned.fill(
          child: CustomPaint(painter: _MapSkeletonPainter())),
      Positioned(
        top: 14, left: 14, right: 14,
        child: SizedBox(
          height: 38,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            itemBuilder: (_, i) => Container(
              width: 100,
              margin: const EdgeInsets.only(right: 8),
              child: const SkeletonBox(height: 38, radius: 20),
            ),
          ),
        ),
      ),
      Positioned(
        bottom: 20, left: 16,
        child: const SkeletonBox(width: 160, height: 42, radius: 20),
      ),
      Positioned(
        bottom: 86, right: 16,
        child: Column(children: const [
          SkeletonBox(width: 42, height: 42, radius: 14),
          SizedBox(height: 8),
          SkeletonBox(width: 42, height: 42, radius: 14),
        ]),
      ),
    ]);
  }
}

class _MapSkeletonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4C5B0).withOpacity(0.3)
      ..style = PaintingStyle.fill;
    const spacing = 28.0;
    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}