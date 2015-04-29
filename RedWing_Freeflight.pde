
/* RedWing */
/**
 * Coded by Lambert Wang
 * github.com/magellantoo
 */


/**
 * RedWing is a colorful 2d side-scrolling flying adventure.
 *
 * Heavily inspired by the game Luftrausers.
 */

import org.gamecontrolplus.gui.*;
import org.gamecontrolplus.*;
import net.java.games.input.*;
import ddf.minim.*;

final String VERSION = "Beta 0.30";

Minim minim;

// Game uses 'screens' to change between states
int screen;
World world;  
// 0 = playing the game
// 1 = main menu

boolean paused = false;

// Input method for players to control the game
Input keyboard;
Input mouse;
ControlIO control;
Configuration config;
ControlDevice gpad;
Input gamepad = null;
Input player;

void setup() {
  // Drawing parameters
  colorMode(HSB);
  smooth();
  // Optimized for 60 fps
  frameRate(60);

  // Fixedsys in sizes 12, 24, 36, and 48
  setupFont();

  noCursor();

  // 4:3
  //size(800, 600);
  //size(1024, 768);
  //size(1280, 960);

  // 16:9
  //size(800, 450);
  //size(1280, 720);
  size(1366, 768);
  //size(1440, 810);

  minim = new Minim(this);
  setupAudio();

  // Active resizing works fine during gameplay
  // Need to re-initialize menus when screen is resized on a menu screen
  // Each time the frame size changes, draw() is called once
  if (frame != null) {
    frame.setResizable(true);
  }

  // Initialize game
  keyboard = new Input();
  mouse = new Input();
  player = keyboard;
  world = new World();

  // Default screen is menu
  world.menuMain();
  screen = 1;
}

void draw() {
  // Determines which screen to show
  switch(screen){
    case 0: 
      if(paused) {
        // Placeholder background
        background(255);
        pauseText();
      } else {
        world.render();

      }
      break;
    case 1:
      world.menuMainRender();
      break;
  }
  playMusic();
}

public void pause() { // Toggles paused and unpaused states
  if (paused) {
    loop();
    paused = false;
  } else {
    noLoop();
    paused = true;
    pauseText();
  }
}

public void pauseText() {
    noStroke();
    fill(128, 255, 255);
    redWing(width/4, height/8, min(width*7/(2*26.5), height/4+32));
    
    textFont(f24);
    fill(0);
    text("PAUSED", width/2-46, height/2-64);
    text("R restart", width/2-70, height/2);
    text("P unpause", width/2-70, height/2+32);
    text("M to menu", width/2-70, height/2+64);
}

void setupGamepad(){
  if (gpad == null) {
    control = ControlIO.getInstance(this);
      gpad = control.getMatchedDevice("gamepad");
  
    if (gpad == null) {
      println("No suitable device configured");
    } else {
      gamepad = new Input();
    }
  }
}

