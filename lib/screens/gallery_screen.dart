import 'package:flutter/material.dart';
import 'package:thirtysix_pics/theme/theme.dart';

class GalleryScreen extends StatelessWidget {
  final String tripName;
  final String dateLabel;
  final int photoCount;

  const GalleryScreen({
    super.key,
    required this.tripName,
    required this.dateLabel,
    required this.photoCount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                children: [
                  _RoundIconButton(
                    icon: Icons.arrow_back_ios_new,
                    tooltip: 'Back to library',
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tripName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: AppFonts.heading,
                            fontWeight: FontWeight.bold,
                            fontSize: 21,
                            color: AppColors.foreground,
                          ),
                        ),
                        Text(
                          '$photoCount/36 · $dateLabel',
                          style: TextStyle(
                            fontFamily: AppFonts.mono,
                            fontSize: 10.5,
                            color: AppColors.foregroundSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _RoundIconButton(
                    icon: Icons.ios_share,
                    tooltip: 'Share options',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _FilmPerforationRow(count: photoCount),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 18,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.82,
                ),
                itemCount: photoCount,
                itemBuilder: (context, index) => _PolaroidPhoto(index: index),
              ),
            ),
            _ActionToolbar(),
          ],
        ),
      ),
    );
  }
}

const _scenePalette = [
  [Color(0xFFE9C68A), Color(0xFFC98A52), Color(0xFFA8622F)],
  [Color(0xFF8FB9C9), Color(0xFF3E6E7E), Color(0xFF2E5E6E)],
  [Color(0xFFD9A79A), Color(0xFFA8522F), Color(0xFF8E4224)],
  [Color(0xFF9FC9A8), Color(0xFF3E7E5C), Color(0xFF2E6E4C)],
  [Color(0xFFD9C79A), Color(0xFFA8842F), Color(0xFF8E6E24)],
  [Color(0xFFC98A9A), Color(0xFF7C3E4F), Color(0xFF6E2E3E)],
];

class _PolaroidPhoto extends StatelessWidget {
  final int index;

  const _PolaroidPhoto({required this.index});

  @override
  Widget build(BuildContext context) {
    final colors = _scenePalette[index % _scenePalette.length];
    final rotation = (index.isEven ? -1.0 : 1.0) * (1.5 + (index % 3));
    return Transform.rotate(
      angle: rotation * 3.14159265 / 180,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(3),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 14, offset: const Offset(0, 8)),
          ],
        ),
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [colors[0], colors[1]],
                    stops: const [0.0, 0.65],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 10 + (index % 3) * 14,
                      top: 10,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFF6EFE0)),
                      ),
                    ),
                    Positioned.fill(
                      child: CustomPaint(painter: _MountainPainter(color: colors[2])),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 4,
              right: 2,
              child: Text(
                'No.${(index + 1).toString().padLeft(2, '0')}',
                style: const TextStyle(fontFamily: 'Courier Prime', fontSize: 8.5, color: Color(0xFF8A7B6C)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MountainPainter extends CustomPainter {
  final Color color;
  _MountainPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, size.height * 0.65)
      ..lineTo(size.width * 0.4, size.height * 0.3)
      ..lineTo(size.width * 0.65, size.height * 0.65)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MountainPainter oldDelegate) => oldDelegate.color != color;
}

class _FilmPerforationRow extends StatelessWidget {
  final int count;

  const _FilmPerforationRow({required this.count});

  @override
  Widget build(BuildContext context) {
    final dots = count.clamp(6, 14);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          dots,
          (i) => Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.foregroundSoft.withOpacity(0.5)),
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _RoundIconButton({required this.icon, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      shape: const CircleBorder(),
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.border)),
            child: Icon(icon, size: 16, color: AppColors.foreground),
          ),
        ),
      ),
    );
  }
}

class _ActionToolbar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.border),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 18, offset: const Offset(0, 8))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ToolbarAction(icon: Icons.ios_share, label: 'SHARE'),
            const SizedBox(width: 26),
            _ToolbarAction(icon: Icons.download_outlined, label: 'SAVE ALL'),
            const SizedBox(width: 26),
            _ToolbarAction(icon: Icons.print_outlined, label: 'PRINT'),
          ],
        ),
      ),
    );
  }
}

class _ToolbarAction extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ToolbarAction({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 19, color: AppColors.foreground),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontFamily: AppFonts.mono, fontSize: 8.5, letterSpacing: .5, color: AppColors.foreground),
          ),
        ],
      ),
    );
  }
}
