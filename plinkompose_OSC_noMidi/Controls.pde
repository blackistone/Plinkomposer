/* Controls.pde
 * 
 * Copyright 2021 Kevin Blackistone
 * A part of Plinkompose - the plinko composer
 *
 * Handler for keyboard input
 * 
 * 
 */ 
 
void keyPressed()
{

  if (key == CODED)
  {
    if (keyCode == UP)
    {
      world.setGravity(0, world.getGravity().y*100*1.125);
    }
    else if (keyCode == DOWN)
    {
      world.setGravity(0, world.getGravity().y*100/1.125);
    }
   
    else if (keyCode == RIGHT)
    {
      dropRate = max(400, dropRate - 200);
    }
    else if (keyCode == LEFT)
    {
      dropRate += 200;
    }
    
  }
  else if (key == ' ') // Switch sound on or off
  {
    Puck puck = new Puck(bounce);      // Creates a ping pong ball ...
    puck.setPosition(paddleLoc, 20);               // ... at top left ...
    puck.setVelocity(map(mouseX, 0, width, -200, 200), 0);   // ... with random velocity.
    puck.setName("Ping pong ball #1");
    world.add(puck);
    oldTime = millis();
  }

  else if (key == 'p' || key == 'P') // Switch between paused and not paused
  {
    paused = !paused;
  }
  else if (key == 'a' || key == 'A')
  {
    auto = !auto;
  }
  else if (key == 'c' || key == 'C') // [c]atch or clear balls in the bottom
  {
    clearBottom = !clearBottom;
  }
  else if (key == '=' || key == '+') // [c]atch or clear balls in the bottom
  {
    bounce = min(0.9, bounce + 0.1);
  }
  else if (key == '-' || key == '_') // [c]atch or clear balls in the bottom
  {
    bounce = max(0.1, bounce - 0.1);
  }
}
