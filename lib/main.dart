// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:developer';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

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
    super.onMount();

    //we will add the player here
    add(Player());
  }
}

class Player extends PositionComponent with HasGameRef<GameSimulator> {
  late StreamSubscription<GyroscopeEvent> _gyroscopeStream; //gyroscope stream
  var _velocity = Vector2(0, 0); //velocity of the player
  late TextComponent text; // Declare text component here

  @override
  void onMount() {
    //initializing my position as (100,100)
    position = Vector2(100, 100);
    text = TextComponent(
      text: 'velocity due to gyro is: 0, 0',
      size: Vector2(10, 10),
      scale: Vector2(0.7, 0.7),
    )
      ..anchor = Anchor.topCenter
      ..x = position.x + 50
      ..y = position.y - 20; //static postion for the text component
    _gyroscopeStream = gyroscopeEvents.listen((GyroscopeEvent event) {
      _velocity = Vector2(event.y, event.x);
      text.text = 'Gyro Stream: ${event.x.toStringAsFixed(3)}, ${event.y.toStringAsFixed(3)}';
    });

    gameRef.add(text);

    super.onMount();
  }

  @override
  void update(double dt) {
    super.update(dt);
    //updating my position
    position += _velocity * dt * 100;
    // log('Player position: $position');

    //show in app the player position using the text just above the player
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // drawing the player
    canvas.drawCircle(position.toOffset(), 15, Paint()..color = Color.fromARGB(255, 191, 203, 255));
  }
}
