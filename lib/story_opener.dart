// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

part 'hideable.dart';
part 'route.dart';
part 'story_opener_controller.dart';

typedef StoryOpenerKey = GlobalKey<StoryOpenerHideableState>;

/// A container that grows to fill the screen to reveal new content when tapped.
///
/// While the container is closed, it shows the [Widget] returned by
/// [closedBuilder]. When the container is tapped it grows to fill the entire
/// size of the surrounding [Navigator] while fading out the widget returned by
/// [closedBuilder] and fading in the widget returned by [openBuilder]. When the
/// container is closed again via the callback provided to [openBuilder] or via
/// Android's back button, the animation is reversed: The container shrinks back
/// to its original size while the widget returned by [openBuilder] is faded out
/// and the widget returned by [closedBuilder] is faded back in.
///
/// By default, the container is in the closed state. During the transition from
/// closed to open and vice versa the widgets returned by the [openBuilder] and
/// [closedBuilder] exist in the tree at the same time. Therefore, the widgets
/// returned by these builders cannot include the same global key.
///
class StoryOpener extends StatefulWidget {
  /// Creates an [StoryOpener].
  ///
  /// All arguments except for [key] must not be null. The arguments
  /// [openBuilder] and [closedBuilder] are required.
  const StoryOpener({
    super.key,
    required this.index,
    required this.controller,
    required this.closedBuilder,
    required this.openBuilder,
    this.closedShape = const RoundedRectangleBorder(),
    this.openShape = const RoundedRectangleBorder(),
    this.onOpen,
    this.onClosed,
    this.transitionDuration = const Duration(milliseconds: 600),
    this.useRootNavigator = false,
    this.routeSettings,
    this.clipBehavior = Clip.antiAlias,
  });

  /// Index of opener
  final int index;

  /// Map if indexed items
  final StoryOpenerController controller;

  /// Called to obtain the child for the container in the closed state.
  ///
  /// The [Widget] returned by this builder is faded out when the container
  /// opens and at the same time the widget returned by [openBuilder] is faded
  /// in while the container grows to fill the surrounding [Navigator].
  ///
  /// The `action` callback provided to the builder can be called to open the
  /// container.
  final Widget Function(
    BuildContext context,
    void Function() action,
  ) closedBuilder;

  /// Called to obtain the child for the container in the open state.
  ///
  /// The [Widget] returned by this builder is faded in when the container
  /// opens and at the same time the widget returned by [closedBuilder] is
  /// faded out while the container grows to fill the surrounding [Navigator].
  ///
  /// The `action` callback provided to the builder can be called to close the
  /// container.
  final Widget Function(
    BuildContext context,
    void Function(int) action,
  ) openBuilder;

  /// Shape of the container while it is closed.
  ///
  /// When the container is opened it will transition from this shape to
  /// [openShape]. When the container is closed, it will transition back to this
  /// shape.
  ///
  /// Defaults to a [RoundedRectangleBorder] with a [Radius.circular] of 4.0.
  ///
  /// See also:
  ///
  ///  * [Material.shape], which is used to implement this property.
  final ShapeBorder closedShape;

  /// Shape of the container while it is open.
  ///
  /// When the container is opened it will transition from [closedShape] to
  /// this shape. When the container is closed, it will transition from this
  /// shape back to [closedShape].
  ///
  /// Defaults to a rectangular.
  ///
  /// See also:
  ///
  ///  * [Material.shape], which is used to implement this property.
  final ShapeBorder openShape;

  /// Called when the container was opened
  final void Function()? onOpen;

  /// Called when the container was popped.
  final void Function()? onClosed;

  /// The time it will take to animate the container from its closed to its
  /// open state and vice versa.
  ///
  /// Defaults to 300ms.
  final Duration transitionDuration;

  /// The [useRootNavigator] argument is used to determine whether to push the
  /// route for [openBuilder] to the Navigator furthest from or nearest to
  /// the given context.
  ///
  /// By default, [useRootNavigator] is false and the route created will push
  /// to the nearest navigator.
  final bool useRootNavigator;

  /// Provides additional data to the [openBuilder] route pushed by the Navigator.
  final RouteSettings? routeSettings;

  /// The [closedBuilder] will be clipped (or not) according to this option.
  ///
  /// Defaults to [Clip.antiAlias], and must not be null.
  ///
  /// See also:
  ///
  ///  * [Material.clipBehavior], which is used to implement this property.
  final Clip clipBehavior;

  @override
  State<StoryOpener> createState() => _StoryOpenerState();
}

class _StoryOpenerState<T> extends State<StoryOpener> {
  @override
  void initState() {
    super.initState();
    widget.controller._addKey(
      index: widget.index,
    );
  }

  Future<void> _open() async {
    widget.onOpen?.call();
    await Navigator.of(
      context,
      rootNavigator: widget.useRootNavigator,
    ).push(
      _Route(
        index: widget.index,
        storyController: widget.controller,
        closedShape: widget.closedShape,
        openBuilder: widget.openBuilder,
        openShape: widget.openShape,
        hideableKey: widget.controller._indexKeys[widget.index]!,
        transitionDuration: widget.transitionDuration,
        useRootNavigator: widget.useRootNavigator,
        routeSettings: widget.routeSettings,
      ),
    );
    widget.onClosed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final Widget closedWidget = widget.closedBuilder(
      context,
      _open,
    );
    widget.controller._syncWidget(
      index: widget.index,
      widget: closedWidget,
    );

    return _Hideable(
      key: widget.controller._indexKeys[widget.index],
      child: Material(
        color: Colors.transparent,
        shape: widget.closedShape,
        clipBehavior: widget.clipBehavior,
        child: closedWidget,
      ),
    );
  }
}
