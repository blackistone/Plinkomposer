# Plinkomposer
A plinko-game style randomized composition tool

## General Use
Design is intended for a 4:3 monitor in vertical orientation\
Sadly this means it currently doesn't show the full screen on some mac autoscaled laptop screens\
\
Produced using Processing 3.5.4, MIDI versions currently do not work in Processing 4, OSC-Only Version does\
Only tested on Mac.\
\
Produces harmonic melodies and chords in Dorian, Mixolydian or Lydian Mode\
Triads are determined by the last bottom slot into which a puck has fallen\
\
\
### CONTROL:
Puck releases based on mouse position\
[space] drop puck manually\
[A]uto drop toggle\
[Q]uits and send MIDI note offset\
[R]eset MIDI\
[C]ollect/clears pucks at the bottom of the board\
[P]ause\
[1,2,3] Choose Dorian, Mixolydian or Lydian Mode\
Left / Right : Decrease / Increase Auto Drop\
  Up / Down  : Increase / Decrease gravity\
   + / -     : Increase or decrease bounce of new pucks\
