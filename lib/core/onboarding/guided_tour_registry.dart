import 'package:flutter/material.dart';

/// Central registry mapping target identifiers to UI elements.
/// Enables decoupled spotlight overlays without tight widget coupling.
class GuidedTourRegistry {
  GuidedTourRegistry._();

  static final Map<String, GlobalKey> _targetKeys = {};

  /// Register a key for a specific target id.
  static void register(String id, GlobalKey key) {
    _targetKeys[id] = key;
  }

  /// Unregister a target key upon widget disposal.
  static void unregister(String id) {
    _targetKeys.remove(id);
  }

  /// Retrieve the registered GlobalKey for a target id.
  static GlobalKey? getKey(String id) => _targetKeys[id];

  /// Computes the screen-space bounding Rect of the target widget.
  /// Returns null if the widget is not currently mounted or rendered.
  static Rect? getTargetRect(String id) {
    final key = _targetKeys[id];
    if (key == null) return null;

    final context = key.currentContext;
    if (context == null || !context.mounted) return null;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return null;

    final offset = renderBox.localToGlobal(Offset.zero);
    return offset & renderBox.size;
  }
}

/// A wrapper widget that registers its child with the [GuidedTourRegistry].
class TourTarget extends StatefulWidget {
  final String id;
  final Widget child;

  const TourTarget({
    super.key,
    required this.id,
    required this.child,
  });

  @override
  State<TourTarget> createState() => _TourTargetState();
}

class _TourTargetState extends State<TourTarget> {
  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    GuidedTourRegistry.register(widget.id, _key);
  }

  @override
  void didUpdateWidget(covariant TourTarget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id) {
      GuidedTourRegistry.unregister(oldWidget.id);
      GuidedTourRegistry.register(widget.id, _key);
    }
  }

  @override
  void dispose() {
    GuidedTourRegistry.unregister(widget.id);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _key,
      child: widget.child,
    );
  }
}
