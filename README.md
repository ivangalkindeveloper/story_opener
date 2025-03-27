## Story Opener
Package provides widgets for open/close like stories with TweenSequence animation:

<div align="center">

  <a href="">![Pub Likes](https://img.shields.io/pub/likes/story_opener?color=success)</a>
  <a href="">![Pub Version](https://img.shields.io/pub/v/story_opener?color=important)</a>
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="License: MIT"></a>

</div>

<div align="center">
  <a href="https://www.buymeacoffee.com/ivangalkin" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" height="32px" width= "128px"></a>
</div>

![Demo](asset/demo.gif)

## Usage
1) Import the package:
```dart
import 'package:story_opener/story_opener.dart';
```
2) Create StoryOpenerController - it remembers which cards are wrapped for further animation of the transition from the open state to the closed one.
```dart
final StoryOpenerController controller = StoryOpenerController();
```

3) Create a list of widgets from which the opening will occur and pass the initial index for the first opening and the necessary parameters of the closed and open states:
```dart
StoryOpener(
    index: index,
    controller: controller,
    closedBuilder: (
        BuildContext context,
        void Function() openStory,
    ) =>
        GestureDetector(
            onTap: openStory,
            child: StoryCard(),
        ),
    openBuilder: (
        BuildContext context,
        void Function(int) closeStory,
    ) =>
        StoryScreen(
            closeStory: closeStory,
        ),
)
```
Internal closures are necessary to initiate the transition.
In the closed state, a closure is passed that accepts an int parameter - this is the currently selected index, to which it will be necessary to go in the opposite direction.

Done.
The logic of the transition inside different stories should be located only inside the widget of the open state and it has nothing to do with the current package for the animation of opening and closing stories.

## Acknowledgments
A huge thanks to the authors of the [animations](https://pub.dev/packages/animations) package, since the basis of the code is taken from this package and the OpenContainer resource.

## Additional information
For more details see example project. And feel free to open an issue if you find any bugs or errors or suggestions.
