int DISPLAY_W   = 660; 
int DISPLAY_H   = 480;
int Pressed_N   = 0;
float BodyScale = 0.5;

void setup() {
  size(DISPLAY_W, DISPLAY_H);
  noStroke();
  colorMode(HSB, 360, 100, 100);

  for(int i = 0; i < BODY_MAX; i++) {
    bAngSpd[i] = random(1) * 5 + 1;
  }
}

float worldAngle = 0;

void draw() {
  background(208, 100, 58);
  scale(BodyScale);
  for(int i = MAX - 1; i > 0; i--) {
    hAng[i] = hAng[i-1] * 0.99;
  }
  hAng[0] = (sin(radians(hAngBase)) + 1) * 15 + 15;
  hAngBase += 3;

  for(int j = 0; j < BODY_MAX; j++) {
    for(int i = MAX - 1; i > 0; i--) {
      bAng[j][i] = bAng[j][i-1] * 1.05;
    }
    bAng[j][0] = sin(radians(bAngBase[j])) * 3;
    bAngBase[j] += bAngSpd[j];
  }

  hLightId += 0.3;
  if(hLightId >= 30) {
    hLightId = 0;
  }

  subDraw();
}

void subDraw() {

  translate(width,  height / 12);
  worldAngle -= 0.2;
  rotate(radians(sin(radians(worldAngle * 2)) * 30));

  drawHead();
  drawBody();
}

final int MAX = 30;
final int BODY_MAX = 9;
float[] hAng = new float[MAX];
float hAngBase = 0;
float[][] bAng = new float[BODY_MAX][MAX];
float[] bAngBase = new float[BODY_MAX];
float[] bAngSpd = new float[BODY_MAX];

float hLightId = 0;


void drawBody() {
  fill(0, 0, 360, 64);
  pushMatrix();
  float x = 0, y = 0;
  int rCount = 360 / BODY_MAX;
  for(int r = 0; r < 360 ;r += rCount) {

    pushMatrix();
    for(int i = 0; i < MAX; i++) {
      float deg = sin((radians((bAng[r / rCount][i])))) * 100;
      x = sin(radians(deg)) * 30 * sin(radians(r));
      y = cos(radians(deg)) * 30;
      translate(x, y);
      ellipse(-35, 0, 10, 10);
    }
    popMatrix();
  }
  popMatrix();
}

void drawHead() {
  pushMatrix();
  float x = 0, y = 0;
  for(int r = 0; r < 360 ;r += 20) {

    pushMatrix();
    float p = 1;
    for(int i = 0; i < MAX; i++) {
      p -= 0.04;
      float deg = sin((radians((hAng[i])))) * 100;
      x = sin(radians(deg)) * 25 * sin(radians(r)) * p;
      y = cos(radians(deg)) * 25;
      translate(x, y);

      boolean lightFlg = abs(((i % 30) - (int)hLightId)) < 1;
      
      if(lightFlg){
        fill(hAng[i] + 180, 360, 360, 196);
        ellipse(-35, 0, 10, 10);

      }else{
        fill(hAng[i] + 180, 360, 360, 64);
       ellipse(-35, 0, 10, 10);
      }
    }
    popMatrix();
  }
  popMatrix();
}
