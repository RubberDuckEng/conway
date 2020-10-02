import 'package:test/test.dart';
import 'package:conway/conway.dart';
import 'package:matcher/matcher.dart';

class _Endures extends Matcher {
  const _Endures();

  @override
  Description describe(Description description) {
    return description.add('endures');
  }

  @override
  bool matches(dynamic pickle, Map matchState) {
    WorldState world;
    try {
      world = WorldState.fromFixture(pickle);
    } catch (e) {
      matchState["parseError"] = e;
      return false;
    }
    WorldState nextWorld = next(world);
    String nextFixture = nextWorld.toFixture();
    matchState["nextWorld"] = nextFixture;
    return pickle == nextFixture;
  }

  @override
  Description describeMismatch(
      item, Description mismatchDescription, Map matchState, bool verbose) {
    if (matchState.containsKey("parseError")) {
      return mismatchDescription.add(matchState["parseError"].toString());
    }
    return mismatchDescription
        .add('$item-- evolved to -->\n${matchState["nextWorld"]}');
  }
}

const Matcher endures = _Endures();

class _EvolvesTo extends Matcher {
  final String targetFixture;

  const _EvolvesTo(this.targetFixture);

  @override
  Description describe(Description description) {
    return description.add('evolves to\n$targetFixture');
  }

  @override
  bool matches(dynamic pickle, Map matchState) {
    WorldState world;
    try {
      world = WorldState.fromFixture(pickle);
    } catch (e) {
      matchState["parseError"] = e;
      return false;
    }
    WorldState nextWorld = next(world);
    String nextFixture = nextWorld.toFixture();
    matchState["nextWorld"] = nextFixture;
    return targetFixture == nextFixture;
  }

  @override
  Description describeMismatch(
      item, Description mismatchDescription, Map matchState, bool verbose) {
    if (matchState.containsKey("parseError")) {
      return mismatchDescription.add(matchState["parseError"].toString());
    }
    return mismatchDescription
        .add('$item-- evolved to -->\n${matchState["nextWorld"]}');
  }
}

Matcher evolvesTo(String targetFixture) => _EvolvesTo(targetFixture);

void main() {
  test('World test', () {
    WorldState world = WorldState(10, 10);
    expect(world.getAt(1, 2), CellState.dead);
    world.setAt(1, 2, CellState.alive);

    // Make sure get does not clear the state.
    expect(world.getAt(1, 2), CellState.alive);
    expect(world.getAt(1, 2), CellState.alive);

    // Make sure you can clear after getting.
    world.setAt(1, 2, CellState.dead);
    expect(world.getAt(1, 2), CellState.dead);

    // Check out of bounds, both at once:
    expect(world.getAt(-1, -1), CellState.dead);
    world.setAt(-1, -1, CellState.alive);
    expect(world.getAt(-1, -1), CellState.dead);

    // Out of bounds one at a time:
    expect(world.getAt(-3, 7), CellState.dead);
    world.setAt(-3, 7, CellState.alive);
    expect(world.getAt(-3, 7), CellState.dead);

    expect(world.getAt(3, -7), CellState.dead);
    world.setAt(3, -7, CellState.alive);
    expect(world.getAt(3, -7), CellState.dead);

    // Out of bounds both positive:
    expect(world.getAt(11, 12), CellState.dead);
    world.setAt(11, 12, CellState.alive);
    expect(world.getAt(11, 12), CellState.dead);
  });

  test('All alive boundary test', () {
    WorldState world = WorldState(10, 10);
    world.setAll(CellState.alive);

    // Check off-by-one for width/height.
    expect(world.getAt(9, 7), CellState.alive);
    expect(world.getAt(10, 7), CellState.dead);
    expect(world.getAt(11, 7), CellState.dead);
    expect(world.getAt(7, 9), CellState.alive);
    expect(world.getAt(7, 10), CellState.dead);
    expect(world.getAt(7, 11), CellState.dead);

    expect(world.getAt(9, 9), CellState.alive);
    expect(world.getAt(10, 9), CellState.dead);
    expect(world.getAt(9, 10), CellState.dead);
  });

  test('Rectangular test', () {
    // Check that width/height not swapped.
    WorldState world = WorldState(5, 10);
    world.setAll(CellState.alive);
    expect(world.getAt(6, 9), CellState.dead);
    expect(world.getAt(9, 6), CellState.dead);
  });

  test('countAlive', () {
    WorldState world = WorldState(4, 4);
    expect(world.countAlive(), 0);
    world.setAt(1, 1, CellState.alive);
    expect(world.countAlive(), 1);
  });

  test('forEach control', () {
    WorldState world = WorldState(3, 7);
    expect(world.width, 3);
    expect(world.height, 7);
    expect(world.countAlive(), 0);
    world.setAll(CellState.alive);
    expect(world.countAlive(), 3 * 7);
    int count = 0;
    world.forEach((x, y, value) {
      ++count;
      expect(value, CellState.alive);
    });
    expect(count, 3 * 7);
  });

  test('one cell dies', () {
    WorldState world = WorldState(4, 4);
    expect(world.countAlive(), 0);
    world.setAt(1, 1, CellState.alive);
    expect(world.countAlive(), 1);
    WorldState newWorld = next(world);
    expect(world.countAlive(), 1);
    expect(newWorld.countAlive(), 0);
  });

  test('block endures', () {
    String block = '''
....
.xx.
.xx.
....
''';
    expect(block, endures);
  });

  test('behive endures', () {
    String behive = '''
......
..xx..
.x..x.
..xx..
......
''';
    expect(behive, endures);
  });

  test('loaf endures', () {
    String loaf = '''
......
..xx..
.x..x.
..x.x.
...x..
......
''';
    expect(loaf, endures);
  });

  test('boat endures', () {
    String boat = '''
.....
.xx..
.x.x.
..x..
.....
''';
    expect(boat, endures);
  });

  test('tub endures', () {
    String tub = '''
.....
..x..
.x.x.
..x..
.....
''';
    expect(tub, endures);
  });

  test('blinker blinks', () {
    String one = '''
.....
..x..
..x..
..x..
.....
''';
    String two = '''
.....
.....
.xxx.
.....
.....
''';
    expect(one, evolvesTo(two));
    expect(two, evolvesTo(one));
  });

  test('toad jumps', () {
    String one = '''
......
......
..xxx.
.xxx..
......
......
''';
    String two = '''
......
...x..
.x..x.
.x..x.
..x...
......
''';
    expect(one, evolvesTo(two));
    expect(two, evolvesTo(one));
  });

  test('beacon beckons', () {
    String one = '''
......
.xx...
.xx...
...xx.
...xx.
......
''';
    String two = '''
......
.xx...
.x....
....x.
...xx.
......
''';
    expect(one, evolvesTo(two));
    expect(two, evolvesTo(one));
  });

  test('toFixture empty world', () {
    WorldState world = WorldState(0, 0);
    expect(world.width, 0);
    expect(world.height, 0);
    expect(world.countAlive(), 0);
    expect(world.toFixture(), '');

    WorldState reconstructed = WorldState.fromFixture(world.toFixture());
    expect(reconstructed.width, 0);
    expect(reconstructed.height, 0);
    expect(reconstructed.countAlive(), 0);
  });

  test('toFixture empty 0x5', () {
    WorldState world = WorldState(0, 5);
    expect(world.width, 0);
    expect(world.height, 5);
    expect(world.countAlive(), 0);
    expect(world.toFixture(), '\n\n\n\n\n');

    WorldState reconstructed = WorldState.fromFixture(world.toFixture());
    expect(reconstructed.width, 0);
    expect(reconstructed.height, 5);
    expect(reconstructed.countAlive(), 0);
  });

  test('toFixture empty 5x0', () {
    WorldState world = WorldState(5, 0);
    expect(world.width, 5);
    expect(world.height, 0);
    expect(world.countAlive(), 0);
    expect(world.toFixture(), '');

    WorldState reconstructed = WorldState.fromFixture(world.toFixture());
    expect(reconstructed.width, 0);
    expect(reconstructed.height, 0); // Doesn't round-trip.
    expect(reconstructed.countAlive(), 0);
  });

  test('toFixture', () {
    WorldState world = WorldState(4, 5);
    expect(world.countAlive(), 0);
    world.setAt(1, 1, CellState.alive);
    world.setAt(1, 2, CellState.alive);
    world.setAt(2, 1, CellState.alive);
    world.setAt(2, 2, CellState.alive);
    world.setAt(2, 3, CellState.alive);
    expect(world.countAlive(), 5);
    expect(world.toFixture(), '''
....
.xx.
.xx.
..x.
....
''');
  });

  test('fromFixture empty', () {
    WorldState world = WorldState.fromFixture('');
    expect(world.width, 0);
    expect(world.height, 0);
    expect(world.countAlive(), 0);
  });

  test('fromFixture', () {
    WorldState world = WorldState.fromFixture('''
....
.xx.
.xx.
..x.
....
''');
    expect(world.width, 4);
    expect(world.height, 5);
    expect(world.countAlive(), 5);
    expect(world.getAt(1, 1), CellState.alive);
    expect(world.getAt(1, 2), CellState.alive);
    expect(world.getAt(2, 1), CellState.alive);
    expect(world.getAt(2, 2), CellState.alive);
    expect(world.getAt(2, 3), CellState.alive);
  });

  test('fromFixture invalid', () {
    expect(() {
      WorldState.fromFixture('x');
    }, throwsArgumentError);
    expect(() {
      WorldState.fromFixture('x\nx');
    }, throwsArgumentError);
    expect(() {
      WorldState.fromFixture('x\nxx\n');
    }, throwsArgumentError);
    expect(() {
      WorldState.fromFixture('xy\nxx\n');
    }, throwsArgumentError);
  });

  test('fromRLE Glider invalid', () {
    var world = WorldState.fromRLE(r'''
#C This is a glider.
x = 3, y = 3
bo$2bo$3o!
''');
    expect(world.toFixture(), '''
.x.
..x
xxx
''');
  });

  test('fromRLE empty', () {
    var world = WorldState.fromRLE(r'''
x = 3, y = 2
!
''');
    expect(world.width, 3);
    expect(world.height, 2);
  });

  test('newline in RLE', () {
    expect(
      WorldState.fromRLE(r'''#N Heavyweight spaceship
#O John Conway
#C A very well-known period 4 c/2 orthogonal spaceship.
#C www.conwaylife.com/wiki/index.php?title=Heavyweight_spaceship
x = 7, y = 5, rule = B3/S23
3b2o2b$bo4bo$o6b$o5bo$6o!''').toFixture(),
      WorldState.fromRLE(r'''#N Heavyweight spaceship
#O John Conway
#C A very well-known period 4 c/2 orthogonal spaceship.
#C www.conwaylife.com/wiki/index.php?title=Heavyweight_spaceship
x = 7, y = 5, rule = B3/S23
3b2o2b$bo4bo$
o6b$o5bo$6o!''').toFixture(),
    );
  });
}
