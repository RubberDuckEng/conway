import 'package:flutter/material.dart';
import 'conway.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class ConwayPainter extends CustomPainter {
  final WorldState world;

  ConwayPainter(this.world);

  @override
  void paint(Canvas canvas, Size size) {
    double xStep = size.width / world.width;
    double yStep = size.height / world.height;

    Paint paint = Paint()..color = Colors.black;
    for (int y = 0; y < world.height; ++y) {
      for (int x = 0; x < world.width; ++x) {
        if (world.getAt(x, y) == CellState.alive) {
          canvas.drawRect(
              Rect.fromLTWH(x * xStep, y * yStep, xStep, yStep), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(ConwayPainter oldDelegate) {
    // This function assumes that the worlds are immutable. Really we should
    // call some deeper comparison operator.
    return world != oldDelegate.world;
  }
}

class ConwayGame extends StatelessWidget {
  final WorldState world;

  ConwayGame({Key key, this.world}) : super(key: key);

  Widget build(BuildContext context) {
    return CustomPaint(painter: ConwayPainter(world));
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  WorldState world;

  void _incrementWorld() {
    setState(() {
      world = next(world);
    });
  }

  @override
  void initState() {
    super.initState();
    world = WorldState.fromFixture('''
......
.xx...
.xx...
...xx.
...xx.
......
''');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ConwayGame(
              world: world,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementWorld,
        tooltip: 'Next',
        child: Icon(Icons.directions_run),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
