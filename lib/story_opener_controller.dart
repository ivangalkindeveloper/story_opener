part of 'story_opener.dart';

final class StoryOpenerController {
  StoryOpenerController();

  final Map<int, StoryOpenerKey> _indexKeys = {};
  final Map<int, Widget> _indexWidgets = {};

  void _addKey({
    required int index,
  }) =>
      _indexKeys[index] = StoryOpenerKey();

  void _syncWidget({
    required int index,
    required Widget widget,
  }) =>
      _indexWidgets[index] = widget;

  void clear() {
    _indexKeys.clear();
    _indexWidgets.clear();
  }
}
