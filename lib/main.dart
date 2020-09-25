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
      home: MyHomePage(title: 'Conway\'s Game of Life'),
    );
  }
}

class ConwayPainter extends CustomPainter {
  final WorldState world;

  ConwayPainter(this.world) : super(repaint: world);

  CellPosition findHitCell(Offset offset, Size size) {
    double xStep = size.width / world.width;
    double yStep = size.height / world.height;

    return CellPosition(
      offset.dx ~/ xStep,
      offset.dy ~/ yStep,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    double xStep = size.width / world.width;
    double yStep = size.height / world.height;

    Paint paint = Paint()..color = Colors.white;
    canvas.drawRect(Offset.zero & size, paint);
    paint.color = Colors.black;
    for (int y = 0; y < world.height; ++y) {
      for (int x = 0; x < world.width; ++x) {
        if (world.getAt(x, y) == CellState.alive) {
          canvas.drawRect(
              Rect.fromLTWH(x * xStep, y * yStep, xStep, yStep), paint);
        }
      }
    }
  }

  // We pass the world to the superclass as the
  // repaint listener, we always return false.
  @override
  bool shouldRepaint(ConwayPainter oldDelegate) => false;
}

typedef CellPositionCallback = void Function(CellPosition position);

class ConwayGame extends StatelessWidget {
  final WorldState world;
  final CellPositionCallback onToggle;

  ConwayGame({Key key, this.world, this.onToggle}) : super(key: key);

  GestureTapUpCallback _createOnTapUp(
      ConwayPainter painter, BuildContext context) {
    if (onToggle == null) {
      return null;
    }
    return (TapUpDetails details) {
      CellPosition position =
          painter.findHitCell(details.localPosition, context.size);
      // It's possible painter might want borders
      // or other non-cell positions in the future
      // but for now we assume all pixels inside painter
      // represent valid positions.
      assert(position != null);
      onToggle(position);
    };
  }

  Widget build(BuildContext context) {
    var painter = ConwayPainter(world);
    return GestureDetector(
      onTapUp: _createOnTapUp(painter, context),
      child: CustomPaint(painter: painter),
    );
  }
}

class RLEEntryField extends StatelessWidget {
  final ValueChanged<WorldState> onWorldAvailable;

  RLEEntryField({Key key, this.onWorldAvailable}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLines: null,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'RLE',
      ),
      onSubmitted: (String value) {
        try {
          onWorldAvailable(WorldState.fromRLE(value));
        } catch (ex) {
          final snackBar = SnackBar(
            content: Text('RLE Parse Error'),
          );
          Scaffold.of(context).showSnackBar(snackBar);
        }
      },
    );
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
........................
.xx....xx....xx....xx...
.xx....xx....xx....xx...
...xx....xx....xx....xx.
...xx....xx....xx....xx.
........................
........................
........................
........................
........................
''');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(color: Colors.black12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1.0,
              child: ConwayGame(
                  world: world,
                  onToggle: (CellPosition position) {
                    setState(() {
                      world.toggle(position);
                    });
                  }),
            ),
            RLEEntryField(
              onWorldAvailable: (WorldState value) {
                setState(() {
                  world = value;
                });
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementWorld,
        tooltip: 'Next',
        child: Icon(Icons.directions_run),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
