import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const Color primaryTosca = Color(0xFF006D66);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildNavItem(0, Icons.link_rounded, "Shorten"),
          _buildNavItem(1, Icons.qr_code_2, "Generate"),
          _buildCenterItem(),
          _buildNavItem(3, Icons.history_rounded, "History"),
          _buildNavItem(4, Icons.person_outline_rounded, "Profile"),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isActive = currentIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(
                icon,
                color: isActive ? primaryTosca : Colors.grey[400],
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isActive ? primaryTosca : Colors.grey[400],
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                ),
              ),
              if (isActive)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: primaryTosca,
                    shape: BoxShape.circle,
                  ),
                )
              else
                const SizedBox(height: 9), // Placeholder for dot
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterItem() {
    bool isActive = currentIndex == 2;
    return Expanded(
      child: InkWell(
        onTap: () => onTap(2),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Transform.translate(
                offset: const Offset(0, -12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: primaryTosca,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: primaryTosca.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -8),
                child: Text(
                  "Scan",
                  style: TextStyle(
                    fontSize: 11,
                    color: isActive ? primaryTosca : Colors.grey[800],
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
              if (isActive)
                Transform.translate(
                  offset: const Offset(0, -4),
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: primaryTosca,
                      shape: BoxShape.circle,
                    ),
                  ),
                )
              else
                Transform.translate(
                  offset: const Offset(0, -4),
                  child: const SizedBox(height: 5), // Placeholder for dot
                ),
            ],
          ),
        ),
      ),
    );
  }
}
