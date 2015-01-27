int n = 0;
void setup(){
  size(600, 400);
  textFont(createFont("Tempus Sans ITC", 24));
  fill(0);
  smooth();
}

void drawDragon(int p, float length, int sign){ // p:# of recursive, length, sign: rotational direction
  if(0 == p){ // finish recursive call
    line(0, 0, length, 0);
    return;
  }

  length *= sqrt(.5);
  pushMatrix();
  rotate(radians(45 * sign));
  drawDragon(--p, length, 1);
  popMatrix();

  pushMatrix();
  translate(length * cos(radians(45 * sign)), length * sin(radians(45 * sign)));
  rotate(radians(-45 * sign));
  drawDragon(p, length, -1);
  popMatrix();
}

void mousePressed(){
  if((mouseButton == LEFT) && (n < 15)) n++;
  else if((mouseButton == RIGHT) && (n > 0)) n--;
}

void draw(){
  background(255);
  text("n = " + n, 10, 30);
  translate(width / 4, height / 2);
  drawDragon(n, width / 2, 1);
}

