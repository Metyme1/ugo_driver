import 'package:flutter/material.dart';

/// Lightweight responsive helpers available on every [BuildContext].
///
/// Breakpoints (portrait-only app):
///   compact  — width < 360 px  (small phones)
///   regular  — 360 – 599 px   (most phones, default design target)
///   large    — ≥ 600 px        (tablets / large phones)
extension Responsive on BuildContext {
  double get _w => MediaQuery.sizeOf(this).width;

  bool get isCompact => _w < 360;
  bool get isLarge   => _w >= 600;

  /// Pick one of three values based on the current size bucket.
  T rv<T>(T compact, T regular, T large) =>
      isCompact ? compact : (isLarge ? large : regular);

  // ── Spacing ────────────────────────────────────────────────────────────────

  /// Horizontal screen padding (left/right insets for content areas).
  double get hPad => rv(16.0, 20.0, 28.0);

  /// Vertical section padding (top/bottom for scroll content).
  double get vPad => rv(14.0, 16.0, 24.0);

  /// Standard gap between sibling items (cards, list rows).
  double get gap => rv(10.0, 12.0, 16.0);

  // ── Icon containers ────────────────────────────────────────────────────────

  /// Size of a square icon-container (avatar circle, card icon box).
  double get iconBox => rv(40.0, 48.0, 56.0);

  /// Glyph size of icons placed inside [iconBox].
  double get iconGlyph => rv(20.0, 24.0, 28.0);

  // ── Typography ─────────────────────────────────────────────────────────────

  /// Screen / page headline (top of auth flows, section titles in headers).
  double get fsHeadline => rv(20.0, 24.0, 28.0);

  /// Card / list item title.
  double get fsTitle => rv(14.0, 15.0, 17.0);

  /// Regular body copy.
  double get fsBody => rv(13.0, 14.0, 15.0);

  /// Small captions, labels, timestamps.
  double get fsCaption => rv(10.0, 12.0, 13.0);
}
