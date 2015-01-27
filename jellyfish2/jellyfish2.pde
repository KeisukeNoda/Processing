final int MAX_JELLYFISH = 10; 
Jellyfish[] jellyfish = new Jellyfish[MAX_JELLYFISH];

int DISPLAY_W   = 1280; 
int DISPLAY_H   = 720;
int Pressed_N   = 0;
float BodyScale = 0.555;

float borderWidth;
float borderHeight;
 
void setup() {
  size(DISPLAY_W, DISPLAY_H);
  colorMode(HSB, 360, 100, 100);
  
  borderWidth = width / 3 * 2;
  borderHeight = height / 3 * 2;
  
  for(int i = 0; i < MAX_JELLYFISH; i++){
    jellyfish[i] = new Jellyfish();
  }
}
 
 
void draw() {
  background(208, 100, 58);
  scale(BodyScale);
  for(int i = 0; i < MAX_JELLYFISH; i++){
    jellyfish[i].draw();  
    }
}


class Jellyfish{
  static final int CAP_JOINT_COUNT = 15;
  static final int LEG_COUNT = 4;
  static final int ROUND_DEGREE = 360;
  static final int LEG_MOVE_POWER = 150;
  static final int HEAD_CURVE_POWER = 100;
  static final int HEAD_DETAIL = 80;
 
  float[] capPointAngle = new float[CAP_JOINT_COUNT];
  float capPointAngleBase = 0;
  float capPointAngleBaseSpd = 0;
  float headWitherPower;
 
  float[] legAngleBase = new float[LEG_COUNT];
  float[] legAngleBaseSpd = new float[LEG_COUNT];
  float[][] legPointAngleBase = new float[LEG_COUNT][CAP_JOINT_COUNT];
 
  PVector position = new PVector();
  float directionAngle;
  float faceAngle;
  int tellCounter;               
  float headSize;              
 
  Jellyfish(){ 
    init();  
    position.x = random(width) - width / 2;
    position.y = random(height) - height / 2;
  }
   void init(){
    for (int i = 0; i < LEG_COUNT; i++) {
      legAngleBaseSpd[i] = random(1) * 2+ 1;
    }
   
    capPointAngleBaseSpd = random(1) + 1;
    headSize = random(5) + 5;
    headWitherPower = random(1) * 0.1 + 0.01;
    directionAngle = random(ROUND_DEGREE);
    faceAngle = random(-50, 50);
  }
 
 
 
  void draw(){
    pushMatrix();
    translate(width / 2 / BodyScale,  height / 2 / BodyScale);
    translate(position.x / BodyScale, position.y / BodyScale);
    rotate(radians(faceAngle));
 
    act();
    drawLeg();
    drawHead();
    popMatrix();
  }
 
  protected void act(){
 
    for (int i = CAP_JOINT_COUNT - 1; i > 0; i--) {
      capPointAngle[i] = capPointAngle[i - 1] * 0.999 - (0.1 * i * i);
    }
    capPointAngleBase += capPointAngleBaseSpd;
    capPointAngle[0] = (sin(radians(capPointAngleBase)) + 2) * 15 + 15;
 
    for (int j = 0; j < LEG_COUNT; j++) {
      for (int i = CAP_JOINT_COUNT - 1; i > 0; i--) {
        legPointAngleBase[j][i] = legPointAngleBase[j][i-1] * 1.05;
      }
      legPointAngleBase[j][0] = sin(radians(legAngleBase[j])) * 3;
      legAngleBase[j] += legAngleBaseSpd[j];
    }

    position.x += cos(radians(directionAngle - 90)) * abs(cos(radians((capPointAngleBase + 50) / 2))) * 3.5;
    position.y += sin(radians(directionAngle - 90)) * abs(cos(radians((capPointAngleBase + 50) / 2))) * 3.5;
 
    boolean returnFlag = false;
    if(position.x < -borderWidth){
      position.x = -borderWidth;
      returnFlag = true;
    }else if(position.x > borderWidth){
      position.x = borderWidth;
      returnFlag = true;
    }else if(position.y < -borderHeight){
      position.y = -borderHeight;
      returnFlag = true;
    }else if(position.y > borderHeight){
      position.y = borderHeight;
      returnFlag = true;
    }    
    if(returnFlag){
      directionAngle += ROUND_DEGREE / 2;
    }
  }
 
  protected void drawLeg() {
    noStroke();
    fill(204, 70, 70);
    float x = 0, y = 0;
    int rCount = ROUND_DEGREE / LEG_COUNT;
    for (int r = 0; r < ROUND_DEGREE ;r += rCount) {
 
      pushMatrix();
      for (int i = 0; i < CAP_JOINT_COUNT; i++) {
        float deg = sin((radians((legPointAngleBase[r / rCount][i])))) * LEG_MOVE_POWER;
        x = sin(radians(deg)) * 20 * sin(radians(r));
        y = cos(radians(deg)) * 10;
        translate(x, y);
        stroke(255, 180);
        strokeWeight(2);
        ellipse(0, 0, 4, 4);
        ellipse(0, 0, 1, 1);
      }
      popMatrix();
    }
  }
 
  protected void drawHead() {
    strokeWeight(10);
    stroke(192, 192, 255, 4);
    fill(280, 3, 80);
 
    for (int r = 0; r < ROUND_DEGREE ;r += HEAD_DETAIL) {
 
      float x = 0, y = 0;
      float tx = 0, ty = 0;
 
      pushMatrix();
      float p = 1;
 
      beginShape(TRIANGLE_STRIP);
      for (int i = 0; i < CAP_JOINT_COUNT; i++) {
        p -= headWitherPower;
        float deg = sin((radians((capPointAngle[i])))) * HEAD_CURVE_POWER;
        x += sin(radians(deg)) * headSize * sin(radians(r)) * p;
        y += cos(radians(deg)) * headSize;
        vertex(x, y);
 
        tx += sin(radians(deg)) * headSize * sin(radians(r + HEAD_DETAIL)) * p;
        ty += cos(radians(deg)) * headSize;
        vertex(tx, ty);
      }
      endShape();
      popMatrix();
    }
  }
}
