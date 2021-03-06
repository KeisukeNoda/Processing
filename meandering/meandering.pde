int xWidth = 600, yHeight = 600;

int totalWorms = 5;
Worm[] worms;

Meander m1 = new Meander();

boolean clear = true;
boolean arg;

void setup() {
  size(xWidth, yHeight, P2D);
  //noBackground();
  noStroke();
  fill(0,0,51);
  rect(0,0,width,height);
  ellipseMode(CENTER);
  colorMode(HSB, 12);
  worms = new Worm[totalWorms];
  for (int i=0; i<totalWorms; i++){
    worms[i] = new Worm(150, random(5,100), random(0.04,0.25));
  }
}
 void draw(){
  loopx(); 
 }
void loopx() {
  drawState();

  for (int i=0; i<totalWorms; i++){
    worms[i].wriggle();
  }
    
  m1.move();
} 

void drawState(){
  if (clear){
    fill(0,100,0);
    noStroke();
    rect(0,0,width,height);
  }
}

void keyReleased () {
  if (key == ' ' && clear) { 
    clear = false;
  } else if (key == ' ' && !clear) {
    clear = true;
  }
}

class Meander {
  float border = 50;
  float left = 0, right = width , bottom = border, top = height - border;
  float xMax = 5, yMax = 3;
  float xPos = xWidth/2, yPos = yHeight/2;
  float xLimit, yLimit, xSpeed, ySpeed, xDelta, yDelta;
  
  Meander (){}
  
  void move(){
    if (mousePressed){
      left = mouseX;
      right = mouseX;
      bottom = mouseY;
      top = mouseY;
    } else {
      left = 0;
      right = width;
      bottom = 0;
      top = height;
    }
  
  
    if (xPos < left){
      xDelta = random(0,1);
    } else if (xPos > right){
      xDelta = random (-1,0);
    } else {
      xDelta = random(-1,1);
    }
    
    if (yPos < bottom){
      yDelta = random(0,1);
    } else if (yPos > top){
      yDelta = random (-1,0);
    } else {
      yDelta = random(-1,1);
    }
    
    xSpeed = xSpeed + xDelta;
    ySpeed = ySpeed + yDelta;
    
    if (xSpeed > xMax){
      xSpeed = xMax;
    } else if (xSpeed < -xMax){
      xSpeed = -xMax;
    }
    
    if (ySpeed > yMax){
      ySpeed = yMax;
    } else if (ySpeed < -yMax){
      ySpeed = -yMax;
    }
    
    xPos = xPos + xSpeed;
    yPos = yPos + ySpeed;
  }
}     

class Worm {
  int total = 150;
  float counter = 1;
  float increment;
  float waveSize;
  float[] dist = new float[total];
  float[] xPos = new float[total];
  float[] yPos = new float[total];
  float xpd, xpd2, ypd, ypd2;
  float acceleration = .6;
  float friction = .4;

  float dx, dy, d;
  float xp=xWidth/2, yp=yHeight/2, xp2, yp2;

  int binary = (int)random(6);
  
  Worm (int numOfSegments, float ws, float inc) {
    int total = numOfSegments;
    waveSize = ws;
    increment = inc;
  }

  void wriggle(){
    elasticity();
    movePoints();
    pushArray();
    setPoints();
    drawLine();
  }

  void elasticity(){
    xp2 = xp2 * acceleration + (m1.xPos - xp) * friction;
    yp2 = yp2 * acceleration + (m1.yPos - yp) * friction;
    xp = xp + xp2;
    yp = yp + yp2;
  }
  
  void movePoints(){
    for (int i=1; i<=total-1; i++){
      xpd2 = xpd2 * acceleration + (xPos[i] - xPos[i-1]) * friction;
      ypd2 = ypd2 * acceleration + (yPos[i] - yPos[i-1]) * friction;
      xpd = xpd + xpd2;
      ypd = ypd + ypd2;
      xPos[i] = xpd;
      yPos[i] = ypd;
    }
  }

  void pushArray(){
    for (int i=total-2; i>total/2; i--){
      dist[i+1] = dist[i]*.95;
    }
    for (int i=total/2; i>0; i--){
      dist[i+1] = dist[i]*1.005;
    }
    dist[1] = (sin(counter) * 3) + 3.1;
    counter = counter + increment;
  }

  void setPoints(){
    xPos[0] = xp;
    yPos[0] = yp;
    for (int i=1; i<total; i++){
      dx = xPos[i] - xPos[i-1];
      dy = yPos[i] - yPos[i-1];
      d = sqrt(sq(dx) + sq(dy));

      xPos[i] = xPos[i-1] + dx * (dist[i]) / d;
      yPos[i] = yPos[i-1] + dy * (dist[i]) / d;
    }
  }
  
  void drawLine(){
    if (binary == 1){
      for (int i=total-1; i>20; i--){
        stroke((total-i) % (12), 100, (total-i)/12.5f);
        strokeWeight(1);
        line(xPos[i], yPos[i], xPos[i - 1], yPos[i - 1]);
      }
    } else {
      for (int i=total-1; i>20; i--){
        stroke((total-i) % (12), 100, (total-i)/12.5f);
        strokeWeight(1);
        point(xPos[i], yPos[i]);
      }
    }
  }
} 
