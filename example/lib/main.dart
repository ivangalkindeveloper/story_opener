import 'package:flutter/material.dart';
import 'package:story_opener/story_opener.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Map<int, StoryOpenerItem> _indexItems = {
    0: StoryOpenerItem(
      child: StoryCard(
        color: Colors.lightBlue,
      ),
    ),
    1: StoryOpenerItem(
      child: StoryCard(
        color: Colors.yellow,
      ),
    ),
    2: StoryOpenerItem(
      child: StoryCard(
        color: Colors.deepOrange,
      ),
    ),
    3: StoryOpenerItem(
      child: StoryCard(
        color: Colors.indigo,
      ),
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Story Opener"),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 16,
            ),
            SizedBox(
              height: 120,
              child: ListView.separated(
                cacheExtent: _indexItems.length * 80,
                scrollDirection: Axis.horizontal,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                itemBuilder: (
                  BuildContext context,
                  int index,
                ) =>
                    StoryOpener(
                  index: index,
                  indexItems: _indexItems,
                  closedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  openShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  closedBuilder: (
                    BuildContext context,
                    void Function() openStory,
                  ) =>
                      GestureDetector(
                    onTap: openStory,
                    child: _indexItems[index]!.child,
                  ),
                  openBuilder: (
                    BuildContext context,
                    void Function(int) closeStory,
                  ) =>
                      StoryScreen(
                    closeStory: closeStory,
                  ),
                ),
                separatorBuilder: (
                  BuildContext context,
                  int index,
                ) =>
                    SizedBox(
                  width: 8,
                ),
                itemCount: _indexItems.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StoryCard extends StatelessWidget {
  const StoryCard({
    super.key,
    required this.color,
  });

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      width: 80,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: color,
        ),
      ),
    );
  }
}

class StoryScreen extends StatelessWidget {
  const StoryScreen({
    super.key,
    required this.closeStory,
  });

  final void Function(int) closeStory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: List.generate(
              4,
              (
                int index,
              ) =>
                  Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 16,
                    ),
                    child: MaterialButton(
                      child: Text(
                        index.toString(),
                      ),
                      onPressed: () => closeStory(index),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
