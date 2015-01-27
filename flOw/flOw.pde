WaterFairy[] fairies;
int DISPLAY_W   = 1280; 
int DISPLAY_H   = 720;
int Pressed_N   = 0;
float BodyScale = 0.333;

void setup(){
  size(DISPLAY_W, DISPLAY_H);
  fairies    = new WaterFairy[1];
  fairies[0] = new WaterFairy();
}

void draw(){
  background(0, 80, 150);
  scale(BodyScale);
  for(int i = 0; i < fairies.length; i++){
    fairies[i].drawFairy();
  }
}

void mousePressed(){
  if( mouseButton == LEFT ) {
    WaterFairy wf = new WaterFairy();
    fairies = (WaterFairy[])append(fairies, wf);
  } else if( mouseButton == RIGHT ) {
    Pressed_N++;
  }
}

class WaterFairy{
  float[] x, y;
  float angle;
  PVector location;
  PVector velocity;
  PVector randloca;
  PVector acceleration;
  PVector mouse;
  float topspeed;
  static final int SPACE   = 60;
  static final int SEG_NUM = 8;
  static final int H_SIZE  = 60;
  static final int E_SIZE  = 30;
  
  WaterFairy(){
    x = new float[SEG_NUM];
    y = new float[SEG_NUM];
    location = new PVector(random(DISPLAY_W) / BodyScale, random(DISPLAY_H) / BodyScale);
    velocity = new PVector(0,0);
    randloca = new PVector(random(DISPLAY_W) / BodyScale, random(DISPLAY_H) / BodyScale);
    mouse    = new PVector(mouseX / BodyScale, mouseY / BodyScale);
    topspeed = 17;
  }
  
  void drawFairy(){
    mouse.set(mouseX / BodyScale, mouseY / BodyScale);
    if (random(1) < 0.01) {
      randloca = new PVector(random(DISPLAY_W) / BodyScale, random(DISPLAY_H) / BodyScale);
    }
    if (Pressed_N % 2 == 0) {
      acceleration = PVector.sub(randloca, location);
      acceleration.normalize();
      acceleration.mult(0.2);
    }
    if (Pressed_N % 2 == 1) {
      acceleration = PVector.sub(mouse, location);
      acceleration.mult(4);
      acceleration.normalize();
    }
    velocity.add(acceleration);
    velocity.limit(topspeed);
    location.add(velocity);
    
    drawBody(0, location.x, location.y);
    for (int i = 0; i < x.length-1; i++){
      drawBody(i+1, x[i], y[i]);
    }
  }
  
  void drawBody(int i, float mx, float my){
    calculateAngle(i, mx, my);
    pushMatrix();
    translate(x[i], y[i]);
    rotate(angle);
    switch(i){
      case 0 :
        noFill();
        stroke(255, 180);
        strokeWeight(2);
        arc(0, 0, 60, 60, HALF_PI, PI+HALF_PI);
        ellipse(-35, 0, 10, 10);
        break;
      case 1 :
        noFill();
        stroke(255, 180);
        strokeWeight(2);
        ellipse(0, 0, 30, 30);
        ellipse(0, 0, 15, 15);
        fill(255);
        ellipse(0, 0, 6, 6);
        ellipse(-SPACE/2, 0, 10, 10);
        
        noFill();
        stroke(255, 180);
        strokeWeight(2);
        ellipse(-SPACE/4, SPACE/3, 12, 12);
        ellipse(-SPACE/4, -SPACE/3, 12, 12);
        fill(255);
        ellipse(-SPACE/4, SPACE/3, 5, 5);
        ellipse(-SPACE/4, -SPACE/3, 5, 5);
        
        stroke(255, 180);
        strokeWeight(1);
        line(-SPACE/4, SPACE/3, -100, 70);
        line(-SPACE/4, -SPACE/3, -100, -70);
        fill(255);
        ellipse(-100, 70, 5, 5);
        ellipse(-100, -70, 5, 5);
        break;
      case 2 :
        noFill();
        stroke(255, 180);
        strokeWeight(2);
        ellipse(0, 0, 30, 30);
        ellipse(0, 0, 15, 15);
        fill(255);
        ellipse(0, 0, 6, 6);
        ellipse(-SPACE/2, 0, 10, 10);
        
        noFill();
        stroke(255, 180);
        strokeWeight(2);
        ellipse(-SPACE/4, SPACE/3, 12, 12);
        ellipse(-SPACE/4, -SPACE/3, 12, 12);
        fill(255);
        ellipse(-SPACE/4, SPACE/3, 5, 5);
        ellipse(-SPACE/4, -SPACE/3, 5, 5);
        
        stroke(255, 180);
        strokeWeight(1);
        line(-SPACE/4, SPACE/3, -100, 50);
        line(-SPACE/4, -SPACE/3, -100, -50);
        fill(255);
        ellipse(-100, 50, 5, 5);
        ellipse(-100, -50, 5, 5);
        break;
      case 3 :
        noFill();
        stroke(255, 180);
        strokeWeight(2);
        ellipse(0, 0, 25, 25);
        ellipse(0, 0, 10, 10);
        fill(255);
        ellipse(0, 0, 3, 3);
        ellipse(-SPACE/2, 0, 10, 10);
        break;
      case 4 :
        noFill();
        stroke(255, 180);
        strokeWeight(2);
        ellipse(0, 0, 25, 25);
        ellipse(0, 0, 10, 10);
        fill(255);
        ellipse(0, 0, 3, 3);
        ellipse(-SPACE/2, 0, 10, 10);
        break;
      case 5 :
        noFill();
        stroke(255, 180);
        strokeWeight(2);
        ellipse(0, 0, 20, 20);
        ellipse(0, 0, 5, 5);
        fill(255);
        ellipse(-SPACE/2, 0, 10, 10);
        break;
      case 6 :
        noFill();
        stroke(255, 180);
        strokeWeight(2);
        ellipse(0, 0, 20, 20);
        ellipse(0, 0, 5, 5);
        fill(255);
        ellipse(-SPACE/2, 0, 10, 10);
        break;
      case 7 :
        noFill();
        stroke(255, 180);
        strokeWeight(2);
        ellipse(0, 0, 8, 8);
        break;
    }
    popMatrix();
  }
  
  void calculateAngle(int i, float tx, float ty){
    float dx = tx - x[i];
    float dy = ty - y[i];
    angle = atan2(dy, dx);
    x[i] = tx - (cos(angle) * SPACE);
    y[i] = ty - (sin(angle) * SPACE);
  }
}
  

