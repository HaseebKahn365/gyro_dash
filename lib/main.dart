// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
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

  GameSimulator() : super() {
    camera = CameraComponent.withFixedResolution(
      width: 600,
      height: 1000,
    );
  }

  //adding a stream for compass events
  late StreamSubscription<CompassEvent> _compassStream;

  final Player myAppPlayer = Player();

  final dot = Dot();

  var angle = 0.0;
  @override
  void onMount() {
    super.onMount();

    //we will add the player here
    world.add(myAppPlayer);
    world.add(RectangleComponent(
      size: Vector2(10, 10),
      position: Vector2(-100, -100),
      angle: 0.0,
      anchor: Anchor.center,
      paint: Paint()..color = Color.fromARGB(255, 255, 253, 160).withOpacity(0.5),
    ));

    world.add(dot);

    //adding the compass stream
    _compassStream = FlutterCompass.events!.listen((CompassEvent event) {
      myAppPlayer.text2.text = 'Magnetometer Stream: ${event.heading}';
      myAppPlayer.text2.position = Vector2(80, 80);
      angle = event.heading!;
    });

    /*
    Now we need to fill the world with lots of dots to show the ground. We will use the magnetometer sensor to rotate the world.
    lets create lots of dots in the world.
    
     */

    camera.follow(myAppPlayer);
  }

  @override
  void update(double dt) {
    // developer.log('angle: $angle');

    dot.angle = angle * (3.14159 / 180); // Convert angle to radians and apply a factor to slow down the rotation

    super.update(dt);
    //rotate the entire grid using the angle
  }
}

class Dot extends PositionComponent {
  List<RectangleComponent> dotGrid() {
    List<RectangleComponent> dots = [];
    for (int i = -6000; i < 6000; i += 150) {
      for (int j = -10000; j < 7000; j += 150) {
        dots.add(
          RectangleComponent(
            size: Vector2(5, 5),
            position: Vector2(i.toDouble(), j.toDouble()),
            angle: 0.0,
            anchor: Anchor.center,
            paint: Paint()..color = Color.fromARGB(255, 255, 253, 160).withOpacity(0.5),
          ),
        );
      }
    }
    return dots;
  }

  @override
  void onLoad() {
    addAll(dotGrid());
    super.onMount();
  }
}

class Player extends PositionComponent with HasGameRef<GameSimulator> {
  late StreamSubscription<GyroscopeEvent> _gyroscopeStream; //gyroscope stream
  var _velocity = Vector2(0, 0); //velocity of the player
  late TextComponent text; // Declare text component here
  late TextComponent text2; // Declaring my text component here for the magnetometer

  @override
  void onMount() {
    anchor = Anchor.topCenter;
    //initializing my position as (100,100)

    text = TextComponent(
      text: 'velocity due to gyro is: 0, 0',
      scale: Vector2(0.7, 0.7),
    );

    text2 = TextComponent(
      text: 'magnetometer info is: 0, 0',
      scale: Vector2(0.7, 0.7),
    );
    //static postion for the text component
    _gyroscopeStream = gyroscopeEvents.listen((GyroscopeEvent event) {
      _velocity = Vector2(event.y, event.x);
      text.text = 'Gyro Stream: ${event.x.toStringAsFixed(3)}, ${event.y.toStringAsFixed(3)}';
      text.position = Vector2(80, 60);
      position += _velocity;
    });

    gameRef.add(text);
    gameRef.add(text2);

    super.onMount();
  }

  @override
  void update(double dt) {
    super.update(dt);
    //updating my position
    //we need to add translational motion to the player based on the gyroscope sensor
    // log('Player position: $position');

    //calculating the offset of the player from the center and adding this offset the position of the player
    //this will make the player move in the direction of the gyroscope sensor

    // developer.log('Player position: $position');

    //show in app the player position using the text just above the player
    // log('Player position: $position');
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // drawing the player
    canvas.drawCircle(position.toOffset(), 15, Paint()..color = const Color.fromARGB(255, 191, 203, 255));
  }
}




/*import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class CompassEvent {
  // The heading, in degrees, of the device around its Z
  // axis, or where the top of the device is pointing.
  final double? heading;

  // The heading, in degrees, of the device around its X axis, or
  // where the back of the device is pointing.
  final double? headingForCameraMode;

  // The deviation error, in degrees, plus or minus from the heading.
  // NOTE: for iOS this is computed by the platform and is reliable. For
  // Android several values are hard-coded, and the true error could be more
  // or less than the value here.
  final double? accuracy;

  CompassEvent.fromList(List<double>? data)
      : heading = data?[0] ?? null,
        headingForCameraMode = data?[1] ?? null,
        accuracy = (data == null) || (data[2] == -1) ? null : data[2];

  @override
  String toString() {
    return 'heading: $heading\nheadingForCameraMode: $headingForCameraMode\naccuracy: $accuracy';
  }
}

/// [FlutterCompass] is a singleton class that provides assess to compass events
/// The heading varies from 0-360, 0 being north.
class FlutterCompass {
  static final FlutterCompass _instance = FlutterCompass._();

  factory FlutterCompass() {
    return _instance;
  }

  FlutterCompass._();

  static const EventChannel _compassChannel =
      const EventChannel('hemanthraj/flutter_compass');
  static Stream<CompassEvent>? _stream;

  /// Provides a [Stream] of compass events that can be listened to.
  static Stream<CompassEvent>? get events {
    if (kIsWeb) {
      return Stream.empty();
    }
    _stream ??= _compassChannel
        .receiveBroadcastStream()
        .map((dynamic data) => CompassEvent.fromList(data?.cast<double>()));
    return _stream;
  }
}
 */