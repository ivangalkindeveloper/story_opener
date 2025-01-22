part of 'story_opener.dart';

class _Route<T> extends ModalRoute<T> {
  _Route({
    required this.index,
    required this.storyController,
    required this.hideableKey,
    required this.openBuilder,
    required ShapeBorder closedShape,
    required this.openShape,
    required this.transitionDuration,
    required this.useRootNavigator,
    required RouteSettings? routeSettings,
  })  : closedWidget = storyController._indexWidgets[index],
        _shapeTween = ShapeBorderTween(
          begin: closedShape,
          end: openShape,
        ),
        _closedOpacityTween = _getClosedOpacityTween(),
        _openOpacityTween = _getOpenOpacityTween(),
        super(settings: routeSettings);

  static _FlippableTweenSequence<double> _getClosedOpacityTween() =>
      _FlippableTweenSequence<double>(
        <TweenSequenceItem<double>>[
          TweenSequenceItem<double>(
            tween: ConstantTween<double>(1.0),
            weight: 1,
          ),
        ],
      );

  static _FlippableTweenSequence<double> _getOpenOpacityTween() =>
      _FlippableTweenSequence<double>(
        <TweenSequenceItem<double>>[
          TweenSequenceItem<double>(
            tween: ConstantTween<double>(0.0),
            weight: 1 / 5,
          ),
          TweenSequenceItem<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            weight: 1 / 5,
          ),
          TweenSequenceItem<double>(
            tween: ConstantTween<double>(1.0),
            weight: 3 / 5,
          ),
        ],
      );

  final int index;
  final StoryOpenerController storyController;
  final GlobalKey<StoryOpenerHideableState> hideableKey;
  GlobalKey<StoryOpenerHideableState>? popedKey;
  Widget? closedWidget;

  final Widget Function(
    BuildContext context,
    void Function(int) action,
  ) openBuilder;
  final ShapeBorder openShape;
  final ShapeBorderTween _shapeTween;

  @override
  final Duration transitionDuration;
  final bool useRootNavigator;

  final _FlippableTweenSequence<double> _closedOpacityTween;
  final _FlippableTweenSequence<double> _openOpacityTween;

  static final TweenSequence<Color?> _scrimFadeInTween = TweenSequence<Color?>(
    <TweenSequenceItem<Color?>>[
      TweenSequenceItem<Color?>(
        tween: ColorTween(begin: Colors.transparent, end: Colors.black54),
        weight: 1 / 5,
      ),
      TweenSequenceItem<Color>(
        tween: ConstantTween<Color>(Colors.black54),
        weight: 4 / 5,
      ),
    ],
  );
  static final Tween<Color?> _scrimFadeOutTween = ColorTween(
    begin: Colors.transparent,
    end: Colors.black54,
  );

  // Key used for the widget returned by [OpenContainer.openBuilder] to keep
  // its state when the shape of the widget tree is changed at the end of the
  // animation to remove all the craft that was necessary to make the animation
  // work.
  final GlobalKey _openBuilderKey = GlobalKey();

  // Defines the position and the size of the (opening) [OpenContainer] within
  // the bounds of the enclosing [Navigator].
  final RectTween _rectTween = RectTween();

  AnimationStatus? _lastAnimationStatus;
  AnimationStatus? _currentAnimationStatus;

  @override
  TickerFuture didPush() {
    _takeMeasurements(
      navigatorContext: hideableKey.currentContext!,
    );

    animation!.addStatusListener(
      _listener,
    );

    return super.didPush();
  }

  void _listener(AnimationStatus status) {
    _lastAnimationStatus = _currentAnimationStatus;
    _currentAnimationStatus = status;
    switch (status) {
      case AnimationStatus.dismissed:
        _toggleHideable(hide: false);

      case AnimationStatus.completed:
        _toggleHideable(hide: true);

      case AnimationStatus.forward:
      case AnimationStatus.reverse:
        break;
    }
  }

  @override
  bool didPop(T? result) {
    if (result is int && storyController._indexKeys[result] != null) {
      popedKey = storyController._indexKeys[result];
      closedWidget = storyController._indexWidgets[result];
      popedKey!.currentState!
        ..placeholderSize = null
        ..isVisible = false;
      hideableKey.currentState!
        ..placeholderSize = null
        ..isVisible = true;
    }
    _takeMeasurements(
      navigatorContext: subtreeContext!,
      delayForSourceRoute: true,
    );
    return super.didPop(result);
  }

  @override
  void dispose() {
    if (hideableKey.currentState?.isVisible == false) {
      // This route may be disposed without dismissing its animation if it is
      // removed by the navigator.
      SchedulerBinding.instance.addPostFrameCallback(
        (
          Duration duration,
        ) =>
            _toggleHideable(
          hide: false,
        ),
      );
    }
    animation!.removeStatusListener(
      _listener,
    );
    super.dispose();
  }

  void _toggleHideable({
    required bool hide,
  }) {
    if (popedKey?.currentState != null) {
      popedKey!.currentState!
        ..placeholderSize = null
        ..isVisible = !hide;
      return;
    }
    if (hideableKey.currentState != null) {
      hideableKey.currentState!
        ..placeholderSize = null
        ..isVisible = !hide;
    }
  }

  void _takeMeasurements({
    required BuildContext navigatorContext,
    bool delayForSourceRoute = false,
  }) {
    final GlobalKey<StoryOpenerHideableState> key = popedKey ?? hideableKey;
    final RenderBox navigator = Navigator.of(
      navigatorContext,
      rootNavigator: useRootNavigator,
    ).context.findRenderObject()! as RenderBox;
    final Size navSize = _getSize(navigator);
    _rectTween.end = Offset.zero & navSize;

    void takeMeasurementsInSourceRoute([Duration? _]) {
      if (!navigator.attached || key.currentContext == null) {
        return;
      }
      _rectTween.begin = _getRect(
        key,
        navigator,
      );
      key.currentState!.placeholderSize = _rectTween.begin!.size;
    }

    if (delayForSourceRoute) {
      SchedulerBinding.instance.addPostFrameCallback(
        takeMeasurementsInSourceRoute,
      );
    } else {
      takeMeasurementsInSourceRoute();
    }
  }

  Size _getSize(
    RenderBox render,
  ) {
    assert(render.hasSize);
    return render.size;
  }

  // Returns the bounds of the [RenderObject] identified by `key` in the
  // coordinate system of `ancestor`.
  Rect _getRect(
    GlobalKey key,
    RenderBox ancestor,
  ) {
    assert(key.currentContext != null);
    assert(ancestor.hasSize);
    final RenderBox render =
        key.currentContext!.findRenderObject()! as RenderBox;
    assert(render.hasSize);
    return MatrixUtils.transformRect(
      render.getTransformTo(ancestor),
      Offset.zero & render.size,
    );
  }

  bool get _transitionWasInterrupted {
    bool wasInProgress = false;
    bool isInProgress = false;

    switch (_currentAnimationStatus) {
      case AnimationStatus.completed:
      case AnimationStatus.dismissed:
        isInProgress = false;
      case AnimationStatus.forward:
      case AnimationStatus.reverse:
        isInProgress = true;
      case null:
        break;
    }
    switch (_lastAnimationStatus) {
      case AnimationStatus.completed:
      case AnimationStatus.dismissed:
        wasInProgress = false;
      case AnimationStatus.forward:
      case AnimationStatus.reverse:
        wasInProgress = true;
      case null:
        break;
    }
    return wasInProgress && isInProgress;
  }

  void _close(
    int index,
  ) =>
      Navigator.of(
        subtreeContext!,
      ).pop(
        index,
      );

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Align(
      alignment: Alignment.topLeft,
      child: AnimatedBuilder(
        animation: animation,
        builder: (
          BuildContext context,
          Widget? child,
        ) {
          if (animation.isCompleted) {
            return SizedBox.expand(
              child: Material(
                color: Colors.transparent,
                shape: openShape,
                child: Builder(
                  key: _openBuilderKey,
                  builder: (
                    BuildContext context,
                  ) =>
                      openBuilder(
                    context,
                    _close,
                  ),
                ),
              ),
            );
          }

          final Animation<double> curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.fastOutSlowIn,
            reverseCurve:
                _transitionWasInterrupted ? null : Curves.fastOutSlowIn.flipped,
          );
          TweenSequence<double>? closedOpacityTween, openOpacityTween;
          Animatable<Color?>? scrimTween;

          switch (animation.status) {
            case AnimationStatus.dismissed:
            case AnimationStatus.forward:
              closedOpacityTween = _closedOpacityTween;
              openOpacityTween = _openOpacityTween;
              scrimTween = _scrimFadeInTween;
            case AnimationStatus.reverse:
              if (_transitionWasInterrupted) {
                closedOpacityTween = _closedOpacityTween;
                openOpacityTween = _openOpacityTween;
                scrimTween = _scrimFadeInTween;
                break;
              }
              closedOpacityTween = _closedOpacityTween.flipped;
              openOpacityTween = _openOpacityTween.flipped;
              scrimTween = _scrimFadeOutTween;
            case AnimationStatus.completed:
              assert(false); // Unreachable.
          }
          assert(closedOpacityTween != null);
          assert(openOpacityTween != null);
          assert(scrimTween != null);

          final Rect rect = _rectTween.evaluate(curvedAnimation)!;

          return SizedBox.expand(
            child: ColoredBox(
              color: scrimTween!.evaluate(
                    curvedAnimation,
                  ) ??
                  Colors.transparent,
              child: Align(
                alignment: Alignment.topLeft,
                child: Transform.translate(
                  offset: Offset(
                    rect.left,
                    rect.top,
                  ),
                  child: SizedBox(
                    width: rect.width,
                    height: rect.height,
                    child: Material(
                      color: Colors.transparent,
                      clipBehavior: Clip.antiAlias,
                      animationDuration: Duration.zero,
                      shape: _shapeTween.evaluate(curvedAnimation),
                      child: Stack(
                        fit: StackFit.passthrough,
                        children: <Widget>[
                          // Closed child fading out.
                          FittedBox(
                            fit: BoxFit.fitWidth,
                            alignment: Alignment.topLeft,
                            child: SizedBox(
                              width: _rectTween.begin!.width,
                              height: _rectTween.begin!.height,
                              child: FadeTransition(
                                opacity: closedOpacityTween!.animate(
                                  animation,
                                ),
                                child: closedWidget,
                              ),
                            ),
                          ),

                          // Open child fading in.
                          FittedBox(
                            fit: BoxFit.fitWidth,
                            alignment: Alignment.topLeft,
                            child: SizedBox(
                              width: _rectTween.end!.width,
                              height: _rectTween.end!.height,
                              child: FadeTransition(
                                opacity: openOpacityTween!.animate(
                                  animation,
                                ),
                                child: Builder(
                                  key: _openBuilderKey,
                                  builder: (
                                    BuildContext context,
                                  ) =>
                                      openBuilder(
                                    context,
                                    _close,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  bool get maintainState => true;

  @override
  Color? get barrierColor => null;

  @override
  bool get opaque => true;

  @override
  bool get barrierDismissible => false;

  @override
  String? get barrierLabel => null;
}

class _FlippableTweenSequence<T> extends TweenSequence<T> {
  _FlippableTweenSequence(this._items) : super(_items);

  final List<TweenSequenceItem<T>> _items;
  _FlippableTweenSequence<T>? _flipped;

  _FlippableTweenSequence<T>? get flipped {
    if (_flipped == null) {
      final List<TweenSequenceItem<T>> newItems = <TweenSequenceItem<T>>[];
      for (int i = 0; i < _items.length; i++) {
        newItems.add(TweenSequenceItem<T>(
          tween: _items[i].tween,
          weight: _items[_items.length - 1 - i].weight,
        ));
      }
      _flipped = _FlippableTweenSequence<T>(newItems);
    }
    return _flipped;
  }
}
