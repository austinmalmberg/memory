import 'package:flutter/material.dart';
import 'package:flutter_memory/src/screens/memory/_game_state_factory.dart';
import 'package:flutter_memory/utils/difficulty.dart';
import 'package:provider/provider.dart';

import '_game_state.dart';
import '_selection.dart';

class MemoryScreen extends StatefulWidget {
  const MemoryScreen({super.key});

  @override
  State<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends State<MemoryScreen> {
  Difficulty difficulty = Difficulty.medium;

  @override
  Widget build(BuildContext context) {
    const double spacing = 10.0;

    return Scaffold(
      body: MultiProvider(
        providers: [
          ChangeNotifierProvider<GameState<IconData>>(
            create: (context) => GameStateFactory.getGameState(
              elements: <IconData>[
                Icons.android,
                Icons.accessible,
                Icons.ac_unit,
                Icons.person,
                Icons.music_note,
                Icons.agriculture,
                Icons.alarm,
                Icons.cabin,
                Icons.warning,
                Icons.pets,
              ],
              difficulty: difficulty,
            ),
          ),
          ChangeNotifierProvider<Selection>(
            create: (context) => Selection(null, null),
          ),
        ],
        builder: (context, _) => Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              Consumer<GameState<IconData>>(builder: (context, state, _) {
                // Hide retry button while game is running
                if (!state.gameOver) {
                  return const SizedBox.shrink();
                }

                return ElevatedButton(
                  onPressed: () {
                    context.read<Selection>().reset();
                    context.read<GameState<IconData>>().reset();
                  },
                  child: const Text('Retry'),
                );
              }),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Builder(builder: (context) {
                    int length = context.select<GameState<IconData>, int>(
                        (state) => state.length);

                    return AspectRatio(
                      aspectRatio: 4 / (length / 4).ceil(),
                      child: GridView.count(
                        mainAxisSpacing: spacing,
                        crossAxisSpacing: spacing,
                        shrinkWrap: true,
                        crossAxisCount: 4,
                        children: List.generate(
                          Provider.of<GameState<IconData>>(context,
                                  listen: false)
                              .length,
                          (index) => MemoryTile(
                            index: index,
                            peekDuration: const Duration(milliseconds: 1000),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              Center(
                child: Text(
                  difficulty.toString(),
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                '${Provider.of<GameState<IconData>>(context).remaining}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MemoryTile extends StatefulWidget {
  const MemoryTile({
    Key? key,
    required this.index,
    this.peekDuration = Duration.zero,
  }) : super(key: key);

  /// The index of the tile within the [GameState].
  final int index;

  /// The duration before the game starts when all icons are visible.
  final Duration peekDuration;

  @override
  State<MemoryTile> createState() => _MemoryTileState();
}

class _MemoryTileState extends State<MemoryTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final Duration fadeDuration = const Duration(milliseconds: 400);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this);

    resetWidget();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  void resetWidget() {
    _controller.duration = widget.peekDuration;

    // Show icon duration the peek duration
    _controller.forward().then((_) {
      // After the peek animation is over reset it
      // and update to the fade duration
      _controller.reset();
      _controller.duration = fadeDuration;

      // Call set state to update the widget
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Building tile at index ${widget.index}.');

    IconData iconData = context.select<GameState<IconData>, IconData>(
        (state) => state.elementAt(widget.index));

    bool found = context.select<GameState<IconData>, bool>(
        (state) => state.isFound(widget.index));

    bool gameOver =
        context.select<GameState<IconData>, bool>((state) => state.gameOver);

    // Start the animation when the match is found
    if (found && _controller.isDismissed) _controller.forward();

    // Reset the animation controller when the game is over
    // This shows the icon and prepares the tile for the next game
    if (gameOver) _controller.reset();

    bool isSelected = context.select<Selection, bool>(
        (selection) => selection.contains(widget.index));

    // show icon when the game is over, the tile is selected, or the icon is fading (match found)
    if (gameOver ||
        isSelected ||
        _controller.isCompleted ||
        _controller.isAnimating) {
      return FittedBox(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FadeTransition(
            opacity: Tween<double>(begin: 1.0, end: 0.0).animate(_controller),
            child: Icon(iconData),
          ),
        ),
      );
    }

    // show tile back
    return InkWell(
      onTap: () {
        Selection selection = context.read<Selection>();

        selection.add(widget.index);

        if (selection.madePair()) {
          context
              .read<GameState<IconData>>()
              .match(selection.first!, selection.second!);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
