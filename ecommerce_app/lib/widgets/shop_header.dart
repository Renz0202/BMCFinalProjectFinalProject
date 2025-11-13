import 'package:flutter/material.dart';

/// A responsive AppBar-style header inspired by modern e-commerce sites.
///
/// - Shows brand logo + name.
/// - On medium/large screens, shows a prominent search field in the center.
/// - Accepts trailing actions (cart, notifications, profile, etc.).
class ShopHeader extends StatelessWidget implements PreferredSizeWidget {
  const ShopHeader({
    super.key,
    required this.titleWidget,
    this.onSearchChanged,
    this.hintText = 'Search products... ',
    this.actions = const <Widget>[],
  });

  /// Typically a Row with logo + brand name
  final Widget titleWidget;

  /// Called as the user types in the search field (wide screens only)
  final ValueChanged<String>? onSearchChanged;

  final String hintText;

  /// Trailing icons (cart, notifications, profile, etc.)
  final List<Widget> actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 900; // Show expanded search on tablet/desktop

    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      centerTitle: false,
      titleSpacing: isWide ? 24 : 8,
      title: isWide
          ? Row(
              children: [
                // Brand
                Flexible(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: titleWidget,
                  ),
                ),
                const SizedBox(width: 16),
                // Search
                if (onSearchChanged != null)
                  Expanded(
                    flex: 5,
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              onChanged: onSearchChanged,
                              decoration: InputDecoration(
                                hintText: hintText,
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            )
          : titleWidget,
      actions: actions,
    );
  }
}
