import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

//we are gonna have a dingle screen in this game:
/*
Simulator: Here we can simulate the gyroscope sensor and magnetometer.
The concept of gyroscope is to control the motion of the player in the game.
the magnetometer is used to rotate the world. The world is filled with rounded dots to show that the player is moving and also rotating the world (actually the world will rotate not the player).


lets keep the game simple and focus on the gyroscope and magnetometer.

 */

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gyro Dash',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Gyro Dash'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                // Navigate to the second screen using a named route.
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameWidget(
                      game: GameSimulator(),
                    ),
                  ),
                );
              },
              child: Text('Launch screen'),
            ),
          ],
        ),
      ),
    );
  }
}

class GameSimulator extends FlameGame {
  @override
  Color backgroundColor() {
    return const Color.fromARGB(255, 25, 25, 25);
  }

  @override
  void onMount() {
    // TODO: implement onMount
    super.onMount();

    //we will add the player here
    add(Player());
  }
}

class Player extends PositionComponent {
  late StreamSubscription<Gyroscope.Event> _gyroscopeSubscription;

  @override
  void onMount() {
    position = Vector2(100, 100);

    super.onMount();
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // drawing the player
    canvas.drawCircle(position.toOffset(), 15, Paint()..color = Color.fromARGB(255, 191, 203, 255));
  }
}
