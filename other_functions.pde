// FixedSys
/* @pjs font="data/fixed.ttf"; */
PFont f6, f12, f24, f36;

void setupFont() {
  // fonts are different in javascript mode
  // Font used is fixedsys
  f6 = loadFont("Fixed_6.vlw");
  f12 = loadFont("Fixed_12.vlw");
  f24 = loadFont("Fixed_24.vlw");
  f36 = loadFont("Fixed_36.vlw");
  // font = createFont("fixed_v01", 48);
}

// Saves precious memories
void screenShot() {
  String name = "screenshots/screenshot-D"+day()+"M"+month()+"Y"+year()+"-H"+hour()+"M"+minute()+"S"+second()+".png";
  save(name);
  println("Screenshot saved: "+name);
}

int signum(float n){
  return (n < 0) ? -1 : 1;
}

// dimensions 26.5, 7
void redWing(float x, float y, float h) {
  float u = h/7;
  pushMatrix();
  translate(x, y);
  // R  
  beginShape();
  vertex(0, 0);
  vertex(.5*u, u);
  vertex(1.5*u, u);
  bezierVertex(u*(1.5+c), u, 2.5*u, u*(2-c), 2.5*u, 2*u);
  bezierVertex(2.5*u, u*(2+c), u*(1.5+c), 3*u, 1.5*u, 3*u);
  vertex(1*u, 3*u);
  vertex(1.5*u, 4*u);
  bezierVertex(u*(1.5+c*2), 4*u, 3.5*u, u*(2+c*2), 3.5*u, 2*u);
  bezierVertex(3.5*u, u*(2-c*2), u*(1.5+c*2), 0, 1.5*u, 0);
  endShape();

  beginShape();
  vertex(1*u, 1.5*u);
  vertex(1*u, 6.5*u);
  vertex(0*u, 7*u);
  vertex(0*u, 1*u);
  endShape();
  
  beginShape();
  vertex(1*u, 3*u);
  vertex(1.5*u, 3*u);
  bezierVertex(u*(1.5+c*2), 3*u, 3.5*u, u*(5-c*2), 3.5*u, 5*u);
  vertex(3.5*u, 6.5*u);
  vertex(2.5*u, 7*u);
  vertex(2.5*u, 5*u);
  bezierVertex(2.5*u, u*(5-c), u*(1.5+c), 4*u, 1.5*u, 4*u);
  endShape();
    
  translate(.5*u, 0);
  // E
  beginShape();
  vertex(3.5*u, 5*u);
  bezierVertex(u*(3.5), u*(5-2*c), u*(5.5-2*c), u*(3), 5.5*u, 3*u);
  bezierVertex(u*(5.5+2*c), u*(3), u*(7.5), u*(5-c*2), 7.5*u, 5*u);
  vertex(6.5*u, 5.5*u);
  vertex(5.5*u, 5.5*u);
  vertex(4.5*u, 5*u);
  vertex(6.5*u, 5*u);
  bezierVertex(u*(6.5), u*(5-c), u*(5.5+c), u*(4), 5.5*u, 4*u);
  bezierVertex(u*(5.5-c), u*(4), u*(4.5), u*(5-c), 4.5*u, 5*u);
  bezierVertex(u*(4.5), u*(5+c), u*(5.5-c), u*(6), 5.5*u, 6*u);
  vertex(7.5*u, 6*u);
  vertex(7*u, 7*u);
  vertex(5.5*u, 7*u);
  bezierVertex(u*(5.5-c*2), u*(7), u*3.5, u*(5+c*2), 3.5*u, 5*u);  
  endShape();
  
  translate(8*u, 0);
  // D
  beginShape();
  vertex(3*u, 2*u);
  vertex(4*u, 1.5*u);
  vertex(4*u, 7*u);
  vertex(3*u, 6.5*u);
  endShape();

  beginShape();
  vertex(2*u, 3*u);
  vertex(3*u, 3*u);
  vertex(2.5*u, 4*u);
  vertex(2*u, 4*u);
  bezierVertex(u*(2-c), 4*u, u, u*(5-c), u, u*5);
  bezierVertex(u, u*(5+c), u*(2-c), u*(6), u*2, u*6);
  bezierVertex(u*(2+c), u*6, u*3, u*(5+c), u*3, u*5);
  vertex(u*4, u*5);
  bezierVertex(u*4, u*(5+2*c), u*(2+2*c), u*7, u*2, u*7);
  bezierVertex(u*(2-2*c), u*7, 0, u*(5+2*c), 0, u*5);
  bezierVertex(0, u*(5-2*c), u*(2-2*c), u*3, u*2, u*3);
  endShape();
  
  translate(-4*u, 0);
  // W
  beginShape();
  vertex(-1.5*u, 0);
  vertex(9*u, 0);
  vertex(10*u, 6*u);
  vertex(9*u, 6*u);
  vertex(u*(8+1.0/6), u);
  vertex(-1*u, u);
  endShape();
  
  translate(8*u, 0);
  
  beginShape();
  vertex(2*u, 3*u);
  vertex(2.5*u, 6*u);
  vertex(3.5*u, 6*u);
  vertex(3*u, 3*u);
  endShape();
  
  beginShape();
  vertex(u*(3.375), 2.25*u);
  vertex(u*(3.875), u*(5.25));
  vertex(u*(4.75-1.0/6), u);
  vertex(u*14, u);
  vertex(u*14.5, 0);
  vertex(u*3.75, 0);
  endShape();
  
  translate(4*u, 0);
  // I
  beginShape();
  vertex(u*.5, u*2.5);
  vertex(u*.5, u*7);
  vertex(u*1.5, u*6.5);
  vertex(u*1.5, u*3);
  endShape();
  
  beginShape();
  vertex(u*.5, u*2);
  bezierVertex(u*.5, u*(2+c/2), u*(1-c/2), u*2.5, u*1, u*2.5);
  bezierVertex(u*(1+c/2), u*2.5, u*1.5, u*(2+c/2), u*1.5, u*2);
  bezierVertex(u*1.5, u*(2-c/2), u*(1+c/2), u*1.5, u*1, u*1.5);
  bezierVertex(u*(1-c/2), u*1.5, u*.5, u*(2-c/2), u*.5, u*2);
  endShape();
  // N
  beginShape();
  vertex(2*u, 2.5*u);
  vertex(2*u, 7*u);
  vertex(3*u, 6.5*u);
  vertex(3*u, 3*u);
  endShape();
  
  beginShape();
  vertex(3.5*u, 3*u);
  vertex(4*u, 3*u);
  bezierVertex(u*(4+c*2), u*3, u*6, u*(5-c*2), u*6, u*5);
  vertex(u*6, u*6.5);
  vertex(u*5, u*7);
  vertex(u*5, u*5);
  bezierVertex(u*5, u*(5-c), u*(4+c), u*4, u*4, u*4);
  vertex(u*3, u*4);
  endShape();
  
  translate(6*u, 0);
  // G
  beginShape();
  vertex(2.5*u, 1.5*u);
  vertex(3.5*u, 1.5*u);
  vertex(3*u, 2.5*u);
  vertex(2.5*u, 2.5*u);
  bezierVertex(u*(2.5-c), 2.5*u, u*1.5, u*(3.5-c), u*1.5, u*3.5);
  bezierVertex(u*1.5, u*(3.5+c), u*(2.5-c), u*(4.5), u*2.5, u*4.5);
  bezierVertex(u*(2.5+c), u*4.5, u*3.5, u*(3.5+c), u*3.5, u*3.5);
  vertex(u*3.5, u*1.5);
  vertex(u*4.5, u*1);
  vertex(u*4.5, u*3.5);
  bezierVertex(u*4.5, u*(3.5+2*c), u*(2.5+2*c), u*5.5, u*2.5, u*5.5);
  bezierVertex(u*(2.5-2*c), u*5.5, u*.5, u*(3.5+2*c), u*.5, u*3.5);
  bezierVertex(u*.5, u*(3.5-2*c), u*(2.5-2*c), u*1.5, u*2.5, u*1.5);
  endShape();
  
  beginShape();
  vertex(u*.5, u*5.5);
  vertex(u*.5, u*6);
  bezierVertex(u*.5, u*(6+c), u*(1.5-c), u*7, u*1.5, u*7);
  vertex(u*2.5, u*7);
  bezierVertex(u*(2.5+2*c), u*7, u*4.5, u*(5+c*2), u*4.5, u*5);
  vertex(u*4.5, u*4);
  bezierVertex(u*4.5, u*(4+c*2), u*(2.5+c*2), u*6, u*2.5, u*6);
  vertex(u*1.5, u*6);
  endShape();

  popMatrix();
}

