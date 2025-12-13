/// @docImport 'material_list_tile.dart';
library;

import 'package:flutter/material.dart';

/// A headline for a section of list tiles.
///
/// This might be placed above a [MaterialListTile] or a group of them to
/// indicate a new section.
///
/// The [MaterialListTile] should be [MaterialListTileBorder.closed] then.
class MaterialListTileHeadline extends StatelessWidget {
  /// The headline widget.
  ///
  /// This is usually a [Text] widget.
  final Widget child;

  const MaterialListTileHeadline(this.child, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListTileTheme(
      child: Padding(
        padding: EdgeInsets.only(top: 12),
        child: Transform.translate(
          offset: const Offset(0, 4),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal:
                  (Theme.of(context).listTileTheme.contentPadding?.horizontal ??
                      8) /
                  2,
            ),
            title: DefaultTextStyle(
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
              child: child,
            ),
            dense: true,
          ),
        ),
      ),
    );
  }
}
