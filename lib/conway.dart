import 'dart:typed_data';

enum CellState {
  dead,
  alive,
}

class WorldState {
  Uint8List _data;

  final int width;
  final int height;

  void setAll(CellState state) {
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        setAt(x, y, state);
      }
    }
  }

  WorldState(this.width, this.height) {
    _data = Uint8List(width * height);
  }

  factory WorldState.fromString(String pickle) {
    if (pickle.isEmpty) {
      return WorldState(0, 0);
    }
    List<String> lines = pickle.split('\n');
    if (lines.length <= 1 || lines.last.isNotEmpty) {
      throw new ArgumentError(
          'Each line in pattern must be terminated with a newline (U+0A).');
    }
    int height = lines.length - 1;
    int width = lines[0].length;
    WorldState world = WorldState(width, height);
    for (int y = 0; y < height; ++y) {
      if (lines[y].length != width) {
        throw new ArgumentError(
            'Each line in pattern must be the same length. Expected $width. Found ${lines[y].length}.');
      }
      for (int x = 0; x < width; ++x) {
        String ch = lines[y][x];
        switch (ch) {
          case 'x':
            world.setAt(x, y, CellState.alive);
            break;
          case '.':
            // Cells in a newly created world default to dead.
            break;
          default:
            throw new ArgumentError('Invalid character "$ch" in pattern.');
        }
      }
    }
    return world;
  }

  CellState getAt(int x, int y) {
    if (x < 0 || y < 0 || x >= width || y >= height) {
      return CellState.dead;
    }
    return CellState.values[_data[x + width * y]];
  }

  void setAt(int x, int y, CellState value) {
    if (x < 0 || y < 0 || x >= width || y >= height) {
      return;
    }
    _data[x + width * y] = value.index;
  }

  void forEach(WorldStateCallback callback) {
    for (int y = 0; y < height; ++y) {
      for (int x = 0; x < width; ++x) {
        callback(x, y, getAt(x, y));
      }
    }
  }

  int countAliveNeighbors(int x, int y) {
    int count = 0;
    for (int dx = -1; dx <= 1; ++dx) {
      for (int dy = -1; dy <= 1; ++dy) {
        if (dx == 0 && dy == 0) {
          continue;
        }
        if (getAt(x + dx, y + dy) == CellState.alive) {
          ++count;
        }
      }
    }
    return count;
  }

  int countAlive() {
    int count = 0;
    forEach((int x, int y, CellState value) {
      if (value == CellState.alive) {
        ++count;
      }
    });
    return count;
  }

  @override
  String toString() {
    StringBuffer buffer = StringBuffer();
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        switch (getAt(x, y)) {
          case CellState.alive:
            buffer.write('x');
            break;
          case CellState.dead:
            buffer.write('.');
            break;
        }
      }
      buffer.write('\n');
    }
    return buffer.toString();
  }
}

typedef WorldStateCallback = Function(int x, int y, CellState value);

WorldState next(WorldState oldWorld) {
  WorldState newWorld = WorldState(oldWorld.width, oldWorld.height);

  oldWorld.forEach((int x, int y, CellState value) {
    int aliveNeighbors = oldWorld.countAliveNeighbors(x, y);
    // Any live cell with two or three live neighbours survives.
    if (value == CellState.alive) {
      if (aliveNeighbors >= 2) {
        newWorld.setAt(x, y, CellState.alive);
      }
    } else {
      // Any dead cell with three live neighbours becomes a live cell.
      if (aliveNeighbors >= 3) {
        newWorld.setAt(x, y, CellState.alive);
      }
    }
    // All other live cells die in the next generation.
    // Similarly, all other dead cells stay dead.
  });

  return null;
}
