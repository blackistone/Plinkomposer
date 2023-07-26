/* PLINKOMPOSE: The Plinko Composer
 *
 * Copyright 2021 Kevin Blackistone
 *
 * Requirements: A MIDI device to receive the MIDI data
 * Bus name will need to be changed based on bus.list() (line:67)
 * A FREE MIDI INSTRUMENT CAN BE DOWNLOADED AT https://tytel.org/helm/
 * A SAMPLE PATH TO LOAD INTO HELM IS INCLUDED AS "SampleInstrument.helm" in the project folder
 *
 * Design is intended for a 4:3 monitor in vertical orientation
 *
 * Produces harmonic melodies and chords in Dorian mode
 * Triads are determined by the last bottom slot into which a puck has fallen
 *
 * CONTROL:
 * Puck releases based on mouse position
 * [space] drop puck manually
 * [A]uto drop toggle
 * [Q]uits and send MIDI note offs
 * [R]eset MIDI
 * [C]ollect/clears pucks at the bottom of the board
 * [P]ause
 * [1,2,3] Choose Dorian, Mixolydian or Lydian Mode
 * Left / Right : Decrease / Increase Auto Drop
 *   Up / Down  : Increase / Decrease gravity
 *    + / -     : Increase or decrease bounce of new pucks
 *
 */

import themidibus.*;
import fisica.*;
import netP5.*;
import oscP5.*;

FWorld world;
PImage bgWood;
PImage puckImg;

MidiBus bus;

OscP5 oscP5;
static final int PORT = 12000;
NetAddress sendTo;

// MIDI Note Variables
// Dor -2 0 2 3 5 7 9 10 12 14 15 17 19 21 22 24 26 27 29 31
// Mix -2 0 2 4 5 7 9 10 12 14 16 17 19 21 22 24 26 28 29 31
// Lyd -1 0 2 4 6 7 9 11 12 14 16 18 19 21 23 24 26 28 30 31

// Dorian triads
int[][] dorian = {
  { 0, 3, 7, 12, 15, 19, 24, 27}, // I
  {-2, 3, 7, 9, 15, 19, 21, 27}, // 3
  {-2, 2, 5, 10, 14, 17, 22, 29}, // 7
  { 0, 3, 9, 12, 15, 21, 24, 31}, // 6
  { 3, 7, 9, 15, 19, 21, 27, 31}}; // 2


// Mixolydian triads
int[][] mixolydian = {
  { 0, 4, 7, 12, 16, 19, 24, 28}, // I
  {-2, 4, 7, 9, 16, 19, 21, 28}, // 3
  {-2, 2, 5, 10, 14, 17, 22, 29}, // 7
  { 0, 4, 9, 12, 16, 21, 24, 31}, // 6
  { 4, 7, 9, 16, 19, 21, 28, 31}}; // 2

// Lydian
int[][] lydian = {
  { 0, 4, 7, 12, 16, 19, 24, 28}, // I
  {-1, 4, 7, 9, 16, 19, 21, 28}, // 3
  {-1, 2, 6, 11, 14, 18, 23, 30}, // 7
  { 0, 4, 9, 12, 16, 21, 24, 31}, // 6
  { 4, 7, 9, 16, 19, 21, 27, 31}}; // 2

int mode = 0;
int progression = 0;
int baseNote = 38;
int[] chord = new int[3];
int[] counts = {0, 0, 0, 0, 0};

float pinsY = 125;

boolean clearBottom = true;  // Clears pucks from bottom slots
boolean paused = false;
boolean auto = true;
boolean chording = false;


// Control Variables
long oldTime;
int dropRate = 5000;
float bounce = 0.4;
int tone;

float paddleLoc;

void setup()
{
  size(1024, 1200);

  bus.list();
  bus = new MidiBus(this, -1, "IAC Bus 1");

  oscP5 = new OscP5(this, PORT);
  sendTo = new NetAddress("127.0.0.1", PORT);

  bgWood = loadImage("backG.png");
  puckImg = loadImage("puck.png");

  Fisica.init(this);
  Fisica.setScale(100); // scale: 150 pixel = 1 m

  world = new FWorld();
  world.setGravity(0, 700);
  world.setGrabbable(true);
  world.setEdges();

  // Draw pegs
  for (int j = 0; j < 4; j++) {
    float y = 150+j*2*pinsY;
    for (int i = 1; i < 7; ++i)
    {
      Pin pin = new Pin(j*2+1, i);
      pin.setPosition(i * width/7+int(random(20)), y);
      world.add(pin);
    }

    for (int i = 1; i < 6; ++i)
    {
      Pin pin = new Pin(j*2+2, i);
      pin.setPosition(i * width/6+int(random(20)), y+pinsY);
      world.add(pin);
    }
  }

  for (int i = 1; i < 4; i++) {
    Paddle padl = new Paddle(9, 95, i, 1);
    padl.setRotation(-PI/6);
    padl.setPosition(30, height/4 * i);
    world.add(padl);
    Paddle padr = new Paddle(9, 95, i, 2);
    padr.setRotation(PI/6);
    padr.setPosition(width-30, height/4 * i);
    world.add(padr);
  }

  for (int i = 0; i < 8; i++) {
    float h = 50+(abs(3.5-i)*20);
    Plank plank = new Plank(9, h); // can't be smaller than 9???
    plank.setPosition(width/9+i*(width/9), height-h/2 - 3);
    world.add(plank);
  }

  Puck puck = new Puck(bounce);                                // Creates a puck
  puck.setPosition(width/3, 40);                               // ... at top left ...
  puck.setVelocity(int(random(-240, 240)), random(0, 240));    // ... with random velocity.
  puck.setName("Ping pong ball #1");
  world.add(puck);

  clearMidi();    // reset MIDI notes in cases of lingering tones from quick exit
}

void drawBackground()
{
  tint(255, 64);
  image(bgWood, 0, 0);
}

void draw()
{
  if (paused)
  {
    return;
  }

  long time = millis();
  paddleLoc = (mouseX*.8) + (width/10);

  if ((time - oldTime > dropRate) && auto) {
    oldTime = time;
    Puck puck = new Puck(bounce);      // Creates a ping pong ball ...
    puck.setPosition(paddleLoc, 40);               // ... at top left ...
    puck.setVelocity(int(random(-240, 240)), random(0, 100));   // ... with random velocity.
    puck.setName("Ping pong ball #1");
    world.add(puck);
  }

  ArrayList<FBody> bodies = world.getBodies();

  for (FBody b : bodies)
  {
    if (b instanceof Puck)
    {
      if ( b.getY() > height-74) // If entering a slot
      {
        b.setDamping(6);
        if (b.getY() > height-40) { // If at the bottom

          // Choose the chord progression
          int a = abs(4 - floor(b.getX() / (width/9)) );
          progression = a;

          // from: basenote - 1 octave (12) - 2 (lowest mode shift) - 1 (safety)
          //   to: top note + 1 (safety)
          for (int i = baseNote-15; i < baseNote+32; i++)
          {
            bus.sendNoteOff(1, i, 0);
          }
          chording = false;

          if (clearBottom) ((Puck) b).delete();
        }
      }
    }
  }

  drawBackground();
  world.step();

  world.draw();

  // Draw release paddle outside of physica engine
  rectMode(CENTER);
  rect(paddleLoc, 8, 60, 8);
  textSize(16);
  textAlign(LEFT);
  if (auto) {
    text("Gravity: " + world.getGravity().y + "\n" +
      "Auto Drop Every: " + nf(float(dropRate)/1000, 2, 1) + "secs" + "\n" +
      "Bounce: " + nf(bounce, 1, 1), 10, 24);
  } else {

    text("Gravity: " + world.getGravity().y + "\n" +
      "Auto Drop OFF [rate 1/" + nf(float(dropRate)/1000, 2, 1) + "s]" + "\n" +
      "Bounce: " + nf(bounce, 1, 1), 10, 24);
  }
  textAlign(RIGHT);
  if (mode == 0) text("Dorian Mode", width - 10, 24);
  else if (mode == 1) text("Mixolydian Mode", width - 10, 24);
  else if (mode == 2) text("Lydian Mode", width-10, 24);
}

void contactStarted(FContact contact)
{
  FBody b1 = contact.getBody1();
  FBody b2 = contact.getBody2();

  if (b1 instanceof Pin && b2 instanceof Puck)
  {

    OscBundle bundled = new OscBundle();
    OscMessage type = new OscMessage("/plinko/type");
    OscMessage row = new OscMessage("/plinko/row");
    OscMessage col = new OscMessage("/plinko/col");
    OscMessage vel = new OscMessage("/plinko/vel");

    bus.sendNoteOff(1, tone, 96);

    float velocity = dist(b2.getVelocityX(), b2.getVelocityY(), 0, 0);
    if (velocity > 10) {
      if (mode == 0) tone = baseNote + dorian[progression][floor((b1.getY() - 150) / pinsY)];
      if (mode == 1) tone = baseNote + mixolydian[progression][floor((b1.getY() - 150) / pinsY)];
      if (mode == 2) tone = baseNote + lydian[progression][floor((b1.getY() - 150) / pinsY)];

      // scale volume by velocity of hit and pitch
      int midiVelocity = min((int)map(velocity, 0, 400, 16, 127-tone), 127);
      bus.sendNoteOn(1, tone, midiVelocity);

      type.add("pin");
      row.add( ((regions)b1).getRw() );
      col.add( ((regions)b1).getCl() );
      vel.add( velocity );
      bundled.add(type);
      bundled.add(row);
      bundled.add(col);
      bundled.add(vel);

      OscP5.flush(bundled, sendTo);
    }

    fill(#FFFFFF, 64);
    rectMode(CORNERS);
    rect(0, 0, width, height);
  }


  if (b1 instanceof Paddle && b2 instanceof Puck)
  {

    if (chording) {
      for (int i = 0; i < chord.length; i++) {

        bus.sendNoteOff(1, chord[i], 0);
      }
    }
    chording = true;

    int tranch = 2-((int)b1.getY()/ (height/4) -1);

    float velocity = dist(b2.getVelocityX(), b2.getVelocityY(), 0, 0);
    for (int i = 0; i < chord.length; i++) {

      if (mode == 0) chord[i] =  baseNote + dorian[progression][i + (i * tranch)] - 12;
      if (mode == 1) chord[i] =  baseNote + mixolydian[progression][i + (i * tranch)] - 12;
      if (mode == 2) chord[i] =  baseNote + lydian[progression][i + (i * tranch)] - 12;
      bus.sendNoteOn(1, chord[i], min((int)map(velocity, 0, 400, 64, 127), 127));
    }

    fill(#000000, 64);
    rectMode(CORNERS);
    rect(0, 0, width, height);
  }
}

void clearMidi() {

  for (int i = 0; i < 128; i++) {
    bus.sendNoteOff(1, i, 0);
  }
}
