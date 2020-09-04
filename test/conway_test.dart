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
}
