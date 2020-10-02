import 'conway.dart';

final List<WorldState> examples = [
  WorldState.fromRLE(r'''#N 55p9h3v0.rle
#O Paul Tooke, 2001
#C http://conwaylife.com/wiki/55P9H3V0
#C http://conwaylife.com/patterns/55p9h3v0.rle
x = 21, y = 13, rule = B3/S23
6b3o3b3o$2bob2o3bobo3b2obo$b3o3bobobobo3b3o$o3bo4bobo4bo3bo$bo7bobo7bo
$8bobobo$8bobobo2$10bo$9bobo$7b2o3b2o$7bobobobo$7b2o3b2o!''').withPadding(100),
  WorldState.fromRLE(r'''#N Sir Robin
#O Adam P. Goucher, Tom Rokicki; 2018
#C The first elementary knightship to be found in Conway's Game of Life.
#C http://conwaylife.com/wiki/Sir_Robin
x = 31, y = 79, rule = B3/S23
4b2o$4bo2bo$4bo3bo$6b3o$2b2o6b4o$2bob2o4b4o$bo4bo6b3o$2b4o4b2o3bo$o9b
2o$bo3bo$6b3o2b2o2bo$2b2o7bo4bo$13bob2o$10b2o6bo$11b2ob3obo$10b2o3bo2b
o$10bobo2b2o$10bo2bobobo$10b3o6bo$11bobobo3bo$14b2obobo$11bo6b3o2$11bo
9bo$11bo3bo6bo$12bo5b5o$12b3o$16b2o$13b3o2bo$11bob3obo$10bo3bo2bo$11bo
4b2ob3o$13b4obo4b2o$13bob4o4b2o$19bo$20bo2b2o$20b2o$21b5o$25b2o$19b3o
6bo$20bobo3bobo$19bo3bo3bo$19bo3b2o$18bo6bob3o$19b2o3bo3b2o$20b4o2bo2b
o$22b2o3bo$21bo$21b2obo$20bo$19b5o$19bo4bo$18b3ob3o$18bob5o$18bo$20bo$
16bo4b4o$20b4ob2o$17b3o4bo$24bobo$28bo$24bo2b2o$25b3o$22b2o$21b3o5bo$
24b2o2bobo$21bo2b3obobo$22b2obo2bo$24bobo2b2o$26b2o$22b3o4bo$22b3o4bo$
23b2o3b3o$24b2ob2o$25b2o$25bo2$24b2o$26bo!''').withPadding(100),
  WorldState.fromRLE(r'''#N Heavyweight spaceship
#O John Conway
#C A very well-known period 4 c/2 orthogonal spaceship.
#C www.conwaylife.com/wiki/index.php?title=Heavyweight_spaceship
x = 7, y = 5, rule = B3/S23
3b2o2b$bo4bo$o6b$o5bo$6o!''').withPadding(40),
  WorldState.fromRLE(r'''#N Pentadecathlon
#O John Conway
#C 10 cells placed in a row evolve into this object, which is the most natural oscillator of period greater than 3. In fact, it is the fifth or sixth most common oscillator overall, being about as frequent as the clock, but much less frequent than the blinker, toad, beacon or pulsar.
#C www.conwaylife.com/wiki/index.php?title=Pentadecathlon
x = 10, y = 3, rule = B3/S23
2bo4bo2b$2ob4ob2o$2bo4bo!''').withPadding(15),
  WorldState.fromRLE(r'''#N p60glidershuttle.rle
#C http://conwaylife.com/wiki/P60_glider_shuttle
#C http://conwaylife.com/patterns/p60glidershuttle.rle
x = 35, y = 7, rule = B3/S23
2bo4bo$2ob4ob2o$2bo4bo$16bo$17b2o8bo4bo$16b2o7b2ob4ob2o$27bo4bo!''')
      .withPadding(10),
];
