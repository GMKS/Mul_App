// Modern Floating Category Card Widget
// Inspired by 3D floating card UI design

import 'package:flutter/material.dart';
import 'dart:math' as math;

class FloatingCategoryCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<Color> gradient;
  final bool isSelected;
  final VoidCallback onTap;
  final int index;

  const FloatingCategoryCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.gradient,
    required this.isSelected,
    required this.onTap,
    required this.index,
  });

  @override
  State<FloatingCategoryCard> createState() => _FloatingCategoryCardState();
}

class _FloatingCategoryCardState extends State<FloatingCategoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 2000 + (widget.index * 300)),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(
      begin: 0,
      end: 8,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _rotateAnimation = Tween<double>(
      begin: -0.02,
      end: 0.02,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: Transform.rotate(
            angle: _rotateAnimation.value,
            child: GestureDetector(
              onTap: widget.onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                width: 105,
                height: 140,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.isSelected
                        ? widget.gradient
                        : [Colors.white, Colors.grey.shade50],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        widget.isSelected ? widget.color : Colors.grey.shade200,
                    width: widget.isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.isSelected
                          ? widget.color.withOpacity(0.3)
                          : Colors.black.withOpacity(0.08),
                      blurRadius: widget.isSelected ? 15 : 8,
                      spreadRadius: widget.isSelected ? 1 : 0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Decorative background elements
                    Positioned(
                      top: -15,
                      right: -15,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.isSelected
                              ? Colors.white.withOpacity(0.15)
                              : widget.color.withOpacity(0.08),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -10,
                      left: -10,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.isSelected
                              ? Colors.white.withOpacity(0.15)
                              : widget.color.withOpacity(0.08),
                        ),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon with decorative container
                          Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: widget.isSelected
                                  ? Colors.white.withOpacity(0.25)
                                  : widget.color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              widget.icon,
                              color: widget.isSelected
                                  ? Colors.white
                                  : widget.color,
                              size: 24,
                            ),
                          ),
                          // Decorative dots/shapes
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: widget.isSelected
                                      ? Colors.white.withOpacity(0.5)
                                      : widget.color.withOpacity(0.3),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: widget.isSelected
                                      ? Colors.white.withOpacity(0.5)
                                      : widget.color.withOpacity(0.3),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: widget.isSelected
                                      ? Colors.white.withOpacity(0.5)
                                      : widget.color.withOpacity(0.3),
                                ),
                              ),
                            ],
                          ),
                          // Title at bottom
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: TextStyle(
                                  color: widget.isSelected
                                      ? Colors.white
                                      : Colors.grey.shade800,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Videos',
                                style: TextStyle(
                                  color: widget.isSelected
                                      ? Colors.white.withOpacity(0.8)
                                      : Colors.grey.shade500,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class CardPatternPainter extends CustomPainter {
  final Color color;

  CardPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw subtle pattern lines
    for (int i = 0; i < 5; i++) {
      final y = size.height * (i / 5);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y + 20),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// A horizontal scrollable row of floating category cards
class FloatingCategoryRow extends StatelessWidget {
  final List<CategoryItem> categories;
  final int selectedIndex;
  final Function(int) onCategorySelected;

  const FloatingCategoryRow({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(categories.length, (index) {
          final category = categories[index];
          return FloatingCategoryCard(
            title: category.title,
            icon: category.icon,
            color: category.color,
            gradient: category.gradient,
            isSelected: selectedIndex == index,
            onTap: () => onCategorySelected(index),
            index: index,
          );
        }),
      ),
    );
  }
}

class CategoryItem {
  final String title;
  final IconData icon;
  final Color color;
  final List<Color> gradient;

  CategoryItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.gradient,
  });
}
