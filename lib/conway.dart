import 'dart:typed_data';
import 'package:flutter/foundation.dart';

enum CellState {
  dead,
  alive,
}

class WorldState extends ChangeNotifier {
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

  factory WorldState.fromFixture(String pickle) {
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

  factory WorldState.fromRLE(String rle) {
    List<String> lines = rle.split('\n');
    bool haveSize = false;
    WorldState world;
    for (String line in lines) {
      if (line.isEmpty || line.startsWith('#')) {
        continue;
      }
      if (!haveSize) {
        // parse the size line.
        // Example: x = 3, y = 3
        int width;
        int height;
        List<String> attributes = line.split(',');
        for (String attribute in attributes) {
          List<String> keyValue = attribute.split('=');
          if (keyValue.length != 2) {
            throw ArgumentError('Invalid attribute: $attribute');
          }
          String key = keyValue[0].trim();
          String value = keyValue[1].trim();
          switch (key) {
            case 'x':
              width = int.parse(value);
              break;
            case 'y':
              height = int.parse(value);
              break;
          }
        }
        if (width == null || height == null) {
          throw ArgumentError('Did not file a width or height');
        }
        world = WorldState(width, height);
        haveSize = true;
        continue;
      }
      int x = 0;
      int y = 0;
      String runCountBuffer = '';
      int flushRunCount() {
        String buffer = runCountBuffer;
        runCountBuffer = '';
        if (buffer.isEmpty) return 1;
        return int.parse(buffer);
      }

      for (int i = 0; i < line.length; ++i) {
        String c = line[i];
        if (c == 'b') {
          x += flushRunCount();
          continue;
        }
        if (c == 'o') {
          int runCount = flushRunCount();
          for (int j = 0; j < runCount; ++j) {
            world.setAt(x, y, CellState.alive);
            x += 1;
          }
          continue;
        }
        if (c == '\$') {
          x = 0;
          y += flushRunCount();
          continue;
        }
        if (c == '!') {
          return world;
        }
        runCountBuffer += c;
      }
    }
    throw ArgumentError('Did not find ! to terminate the RLE.');
  }

  CellState getAt(int x, int y) {
    if (x < 0 || y < 0 || x >= width || y >= height) {
      return CellState.dead;
    }
    return CellState.values[_data[x + width * y]];
  }

  CellState getAtPosition(CellPosition position) =>
      getAt(position.x, position.y);

  // All mutations need to go through this function
  // or call notifyListeners themselves.
  void setAt(int x, int y, CellState value) {
    if (x < 0 || y < 0 || x >= width || y >= height) {
      return;
    }
    _data[x + width * y] = value.index;
    notifyListeners();
  }

  void setAtPosition(CellPosition position, CellState value) {
    setAt(position.x, position.y, value);
  }

  void toggle(CellPosition position) {
    switch (getAtPosition(position)) {
      case CellState.alive:
        setAtPosition(position, CellState.dead);
        break;
      case CellState.dead:
        setAtPosition(position, CellState.alive);
        break;
    }
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

  String toFixture() {
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

  @override
  bool operator ==(dynamic other) {
    if (other is! WorldState) {
      return false;
    }
    WorldState typedOther = other;
    if (width != typedOther.width || height != typedOther.height) {
      return false;
    }
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        if (getAt(x, y) != typedOther.getAt(x, y)) {
          return false;
        }
      }
    }
    return true;
  }
}

class CellPosition {
  final int x;
  final int y;

  CellPosition(this.x, this.y);

  String toString() {
    return 'CellPosition($x, $y)';
  }
}

typedef WorldStateCallback = Function(int x, int y, CellState value);

WorldState next(WorldState oldWorld) {
  WorldState newWorld = WorldState(oldWorld.width, oldWorld.height);

  oldWorld.forEach((int x, int y, CellState value) {
    int aliveNeighbors = oldWorld.countAliveNeighbors(x, y);
    // Any live cell with two or three live neighbours survives.
    if (value == CellState.alive) {
      if (aliveNeighbors == 2 || aliveNeighbors == 3) {
        newWorld.setAt(x, y, CellState.alive);
      }
    } else {
      // Any dead cell with three live neighbours becomes a live cell.
      if (aliveNeighbors == 3) {
        newWorld.setAt(x, y, CellState.alive);
      }
    }
    // All other live cells die in the next generation.
    // Similarly, all other dead cells stay dead.
  });

  return newWorld;
}
