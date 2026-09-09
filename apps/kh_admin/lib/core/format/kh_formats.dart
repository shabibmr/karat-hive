/// Shared display formatters.
///
/// `DateFormat` and `NumberFormat` are immutable and reusable, so they are
/// built once here rather than per `build()`. Top-level `final`s in Dart
/// initialise lazily on first access, so this does not force locale data to
/// load at start-up.
///
/// Timestamps are stored UTC and displayed Gulf Standard Time (`BR-021`,
/// `C-01`, `C-02`) — these formatters render whatever `DateTime` they are
/// given, so callers remain responsible for converting to GST first.
library;

import 'package:intl/intl.dart';

/// Date with time, e.g. `04 Sep 2026, 14:30`.
final DateFormat khDateTimeFormat = DateFormat('dd MMM yyyy, HH:mm');

/// Date only, e.g. `04 Sep 2026`.
final DateFormat khDateFormat = DateFormat('dd MMM yyyy');

/// Localised medium date, e.g. `Sep 4, 2026`.
final DateFormat khShortDateFormat = DateFormat.yMMMd();

/// Grouped integer, e.g. `1,250`. Used for gram weights and AED amounts.
final NumberFormat khNumberFormat = NumberFormat('#,##0', 'en_US');
