part of 'story_opener.dart';

final class StoryOpenerItem {
  StoryOpenerItem({
    required this.child,
  }) : key = StoryOpenerKey();

  final StoryOpenerKey key;
  final Widget child;
}
