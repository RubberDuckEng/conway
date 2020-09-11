import 'package:test/test.dart';
import 'package:conway/conway.dart';

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
    WorldState world = WorldState(4, 4);
    expect(world.countAlive(), 0);
    world.setAt(1, 1, CellState.alive);
    world.setAt(1, 2, CellState.alive);
    world.setAt(2, 1, CellState.alive);
    world.setAt(2, 2, CellState.alive);
    expect(world.countAlive(), 4);
    WorldState newWorld = next(world);
    expect(world.countAlive(), 4);
    expect(newWorld.countAlive(), 4);
  });

  test('blinker blinks', () {
    WorldState world = WorldState.fromString('''
.....
..x..
..x..
..x..
.....
''');
    world = next(world);
    expect(world.toString(), '''
.....
.....
.xxx.
.....
.....
''');
  });

  test('beacon beckons', () {
    WorldState world = WorldState.fromString('''
......
.xx...
.xx...
...xx.
...xx.
......
''');
    world = next(world);
    expect(world.toString(), '''
......
.xx...
.x....
....x.
...xx.
......
''');
  });

  test('toString empty world', () {
    WorldState world = WorldState(0, 0);
    expect(world.width, 0);
    expect(world.height, 0);
    expect(world.countAlive(), 0);
    expect(world.toString(), '');

    WorldState reconstructed = WorldState.fromString(world.toString());
    expect(reconstructed.width, 0);
    expect(reconstructed.height, 0);
    expect(reconstructed.countAlive(), 0);
  });

  test('toString empty 0x5', () {
    WorldState world = WorldState(0, 5);
    expect(world.width, 0);
    expect(world.height, 5);
    expect(world.countAlive(), 0);
    expect(world.toString(), '\n\n\n\n\n');

    WorldState reconstructed = WorldState.fromString(world.toString());
    expect(reconstructed.width, 0);
    expect(reconstructed.height, 5);
    expect(reconstructed.countAlive(), 0);
  });

  test('toString empty 5x0', () {
    WorldState world = WorldState(5, 0);
    expect(world.width, 5);
    expect(world.height, 0);
    expect(world.countAlive(), 0);
    expect(world.toString(), '');

    WorldState reconstructed = WorldState.fromString(world.toString());
    expect(reconstructed.width, 0);
    expect(reconstructed.height, 0); // Doesn't round-trip.
    expect(reconstructed.countAlive(), 0);
  });

  test('toString', () {
    WorldState world = WorldState(4, 5);
    expect(world.countAlive(), 0);
    world.setAt(1, 1, CellState.alive);
    world.setAt(1, 2, CellState.alive);
    world.setAt(2, 1, CellState.alive);
    world.setAt(2, 2, CellState.alive);
    world.setAt(2, 3, CellState.alive);
    expect(world.countAlive(), 5);
    expect(world.toString(), '''
....
.xx.
.xx.
..x.
....
''');
  });

  test('fromString empty', () {
    WorldState world = WorldState.fromString('');
    expect(world.width, 0);
    expect(world.height, 0);
    expect(world.countAlive(), 0);
  });

  test('fromString', () {
    WorldState world = WorldState.fromString('''
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

  test('fromString invalid', () {
    expect(() {
      WorldState.fromString('x');
    }, throwsArgumentError);
    expect(() {
      WorldState.fromString('x\nx');
    }, throwsArgumentError);
    expect(() {
      WorldState.fromString('x\nxx\n');
    }, throwsArgumentError);
    expect(() {
      WorldState.fromString('xy\nxx\n');
    }, throwsArgumentError);
  });
}
