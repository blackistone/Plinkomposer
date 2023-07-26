/* PLINKOMPOSE: The Plinko Composer
 *
 * Copyright 2021 Kevin Blackistone
 *
 * Requirements: A MIDI device to receive the MIDI data
 *
 * Design is intended for a 4:3 monitor in vertical orientation
 *
 *
 * CONTROL:
 * Puck releases based on mouse position
 * [space] drop puck manually
 * [A]uto drop toggle
 * [C]ollect/clears pucks at the bottom of the board
 * [P]ause
 * Left / Right : Decrease / Increase Auto Drop
 *   Up / Down  : Increase / Decrease gravity
 *    + / -     : Increase or decrease bounce of new pucks
 *
 */

import fisica.*;
import netP5.*;
import oscP5.*;

FWorld world;
PImage bgWood;
PImage puckImg;

//OscP5 oscP5;
static final int PORT = 12000;
NetAddress sendTo;

float pinsY = 125;

boolean clearBottom = true;  // Clears pucks from bottom slots
boolean paused = false;
boolean auto = true;


// Control Variables
long oldTime;
int dropRate = 5000;
float bounce = 0.4;
int tone;

float paddleLoc;

void setup()
{
  size(1024, 1200);

  //oscP5 = new OscP5(this, PORT);
  sendTo = new NetAddress("127.0.0.1", PORT);

  bgWood = loadImage("backG.png");
  puckImg = loadImage("puck.png");

  Fisica.init(this);
  Fisica.setScale(100); // scale: 150 pixel = 1 m

  world = new FWorld();
  world.setGravity(0, 700);
  world.setGrabbable(true);
  world.setEdges();

  setWorld();

  Puck puck = new Puck(bounce);                                // Creates a puck
  puck.setPosition(width/3, 40);                               // ... at top left ...
  puck.setVelocity(int(random(-240, 240)), random(0, 240));    // ... with random velocity.
  puck.setName("Ping pong ball #1");
  world.add(puck);
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
          int a = ceil(b.getX() / (width/9));
          println(a);
          OscBundle bundled = new OscBundle();
          OscMessage type = new OscMessage("/plinko/type");
          OscMessage row = new OscMessage("/plinko/row");
          OscMessage col = new OscMessage("/plinko/col");
          OscMessage vel = new OscMessage("/plinko/vel");

          type.add("slot");
          row.add( 0 );
          col.add( a );
          vel.add( 0.0f );
          bundled.add(type);
          bundled.add(row);
          bundled.add(col);
          bundled.add(vel);

          OscP5.flush(bundled, sendTo);

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
}

void contactStarted(FContact contact)
{
  FBody b1 = contact.getBody1();
  FBody b2 = contact.getBody2();

  OscBundle bundled = new OscBundle();
  OscMessage type = new OscMessage("/plinko/type");
  OscMessage row = new OscMessage("/plinko/row");
  OscMessage col = new OscMessage("/plinko/col");
  OscMessage vel = new OscMessage("/plinko/vel");

  if (b1 instanceof Pin && b2 instanceof Puck)
  {

    float velocity = dist(b2.getVelocityX(), b2.getVelocityY(), 0, 0);
    if (velocity > 10) {

      type.add("pin");
      row.add( ((regions)b1).getRw() );
      println(((regions)b1).getRw(), ((regions)b1).getCl());
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
    int tranch = 2-((int)b1.getY()/ (height/4) -1);
    float velocity = dist(b2.getVelocityX(), b2.getVelocityY(), 0, 0);

    type.add("paddle");
    row.add( ((regions)b1).getRw() );
    println(((regions)b1).getRw(), ((regions)b1).getCl());
    col.add( ((regions)b1).getCl() );
    vel.add( velocity );
    bundled.add(type);
    bundled.add(row);
    bundled.add(col);
    bundled.add(vel);

    OscP5.flush(bundled, sendTo);

    fill(#000000, 64);
    rectMode(CORNERS);
    rect(0, 0, width, height);
  }
}

void setWorld() {
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
}
