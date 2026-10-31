import 'package:flutter/material.dart';
import 'package:thirtysix_pics/services/film_stock.dart';
import 'package:thirtysix_pics/theme/theme.dart';
import 'package:thirtysix_pics/widgets/stock_thumbnail.dart';

/// Shows the "Load New Film" bottom sheet and resolves with the trip name and
/// film stock the user chose, or null if they cancelled.
Future<({String name, FilmStock stock})?> showNewRollSheet(BuildContext context) {
  return showModalBottomSheet<({String name, FilmStock stock})>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _NewRollSheet(),
  );
}

class _NewRollSheet extends StatefulWidget {
  const _NewRollSheet();

  @override
  State<_NewRollSheet> createState() => _NewRollSheetState();
}

class _NewRollSheetState extends State<_NewRollSheet> {
  final _controller = TextEditingController();
  FilmStock _selected = FilmStock.classic;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.fromLTRB(28, 14, 28, MediaQuery.of(context).padding.bottom + 28),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
         child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 22),
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.background,
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(Icons.local_movies_outlined, color: AppColors.primary, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              'Load New Film',
              style: TextStyle(
                fontFamily: AppFonts.heading,
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: AppColors.cardForeground,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Every roll holds 36 shots. Choose wisely.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: AppColors.cardForeground.withOpacity(0.65),
              ),
            ),
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'TRIP NAME',
                style: TextStyle(
                  fontFamily: AppFonts.mono,
                  fontSize: 10.5,
                  letterSpacing: 1.5,
                  color: AppColors.cardForeground.withOpacity(0.6),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              autofocus: false,
              style: TextStyle(fontFamily: AppFonts.heading, fontSize: 19, color: AppColors.cardForeground),
              decoration: InputDecoration(
                hintText: 'New Trip',
                hintStyle: TextStyle(color: AppColors.cardForeground.withOpacity(0.35)),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary, width: 2)),
              ),
            ),
            const SizedBox(height: 26),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'STARTING FILM STOCK',
                style: TextStyle(
                  fontFamily: AppFonts.mono,
                  fontSize: 10.5,
                  letterSpacing: 1.5,
                  color: AppColors.cardForeground.withOpacity(0.6),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: FilmStock.values.map((stock) {
                final isSelected = stock == _selected;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => setState(() => _selected = stock),
                      child: Column(
                        children: [
                          Container(
                            height: 84,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.border,
                                width: isSelected ? 2.5 : 1,
                              ),
                            ),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(9),
                                  child: StockThumbnail(stock: stock),
                                ),
                                if (isSelected)
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: Container(
                                      width: 18,
                                      height: 18,
                                      decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
                                      child: Icon(Icons.check, size: 12, color: AppColors.primaryForeground),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            stock.label,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? AppColors.cardForeground
                                  : AppColors.cardForeground.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            stock.descriptor,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10.5,
                              height: 1.25,
                              color: AppColors.cardForeground.withOpacity(0.65),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final name = _controller.text.trim();
                  Navigator.pop(context, (name: name.isEmpty ? 'New Trip' : name, stock: _selected));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.primaryForeground,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: const Text('Load Roll', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              ),
            ),
            const SizedBox(height: 14),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: AppColors.cardForeground.withOpacity(0.6))),
            ),
          ],
         ),
        ),
      ),
    );
  }
}
