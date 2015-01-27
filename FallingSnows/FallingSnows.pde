Snow[] snows;
int DISPLAY_W   = 1280; 
int DISPLAY_H   = 720;

void setup(){
  size(DISPLAY_W, DISPLAY_H );
  snows = new Snow[100];
  for(int i = 0; i < snows.length; i++){
    snows[i] = new Snow();
  }
}

void draw(){
  background(0);
  for(int i = 0; i < snows.length; i++){
    snows[i].drawSnow();
  }
}

class Snow{
  int num;
  float[] x, y;
  float radius;
  float posX, posY;
  float speed;
  color col;
  
  Snow(){
    int r = (int)random(3);
    switch(r){
      case 0 : num = 30; break;
      case 1 : num = 45; break;
      case 2 : num = 60; break;
    }
    
    radius = random(5, 30);
    x = new float[360/num];
    y = new float[360/num];
    for(int i = 0; i < 360/num; i++){
      float angle = radians(i*num);
      x[i] = radius*cos(angle);
      y[i] = radius*sin(angle);
    }
    
    posX = random(width);
    posY = random(height);
    speed = random(3);
    col = color(random(200, 255), random(200, 255), random(200, 255), 128);
  }
  
  void drawSnow(){
    pushMatrix();
    translate(posX, posY);
    rotate(frameCount*0.02);
    fill(255, 80);
    noStroke();
    ellipse(0, 0, radius/2, radius/2);
    stroke(col);
    strokeWeight(2);
    for(int i = 0; i < x.length; i++){
      line(0, 0, x[i], y[i]);
    }
    popMatrix();
    
    posY += speed;
    if(posY > height) posY = 0;
  }
}
