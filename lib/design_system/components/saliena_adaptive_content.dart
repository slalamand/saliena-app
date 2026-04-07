import 'package:flutter/material.dart';

/// Constrains content width on wide screens (iPad / tablet).
///
/// On phones (width < [maxWidth]) this has zero visual effect — the
/// ConstrainedBox is simply larger than the screen so the child fills as
/// normal.  On an iPad the child is horizontally centred at [maxWidth].
///
/// Use this to wrap the *scrollable body content* of each screen so that
/// form fields, buttons, and lists never stretch to the full tablet width.
class SalienaAdaptiveContent extends StatelessWidget {
  const SalienaAdaptiveContent({
    super.key,
    required this.child,
    this.maxWidth = 480.0,
  });

  final Widget child;

  /// Maximum content width in logical pixels.  480 matches a comfortable
  /// phone-width column centred on a 13-inch iPad.
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
