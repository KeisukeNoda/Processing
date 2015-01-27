import processing.opengl.*;

final int MAX_JELLYFISH = 10;  //  くらげの数
Jellyfish[] jellyfish = new Jellyfish[MAX_JELLYFISH];
 
float halfWidth;    //  画面の横幅の半分
float halfHeight;   //  画面の縦幅の半分
float borderWidth;  //  折り返す横幅の位置
float borderHeight; //  折り返す縦幅の位置
 
void setup() {
  size(800, 800, OPENGL);
  halfWidth = width / 2;
  halfHeight = height / 2;
  borderWidth = width / 3 * 2;
  borderHeight = height / 3 * 2;
 
  //  球を粗くすることで処理速度を稼ぐ
  sphereDetail(3, 3);
 
  //  クラゲの生成
  for(int i = 0; i < MAX_JELLYFISH; i++){
    jellyfish[i] = new Jellyfish();
  }
}
 
 
void draw() {
  background(0);
  camera(0, 0, 500, 0, 0, 0, 0, 1, 0);
 
  for(int i = 0; i < MAX_JELLYFISH; i++){
    jellyfish[i].draw();  
    }
}
 
//  くらげクラス
class Jellyfish{
  static final int CAP_JOINT_COUNT = 10;  //  笠のポイントの数
  static final int LEG_COUNT = 4;         //  足の本数
  static final int ROUND_DEGREE = 360;    //  一周の角度
  static final int LEG_MOVE_POWER = 100;  //  足の動く強さ
  static final int HEAD_CURVE_POWER = 100;//  笠の動く強さ
  static final int HEAD_DETAIL = 30;      //  笠の細かさ(描画する角度の閾値)
 
  float[] capPointAngle = new float[CAP_JOINT_COUNT];  //  笠のそれぞれのポイントの広がり角度
  float capPointAngleBase = 0;  //  笠の動きのベース広がり角度
  float capPointAngleBaseSpd = 0;   //  笠の動きベースの速度
  float headWitherPower;            //  笠のしぼみ具合
 
  float[] legAngleBase = new float[LEG_COUNT];    //  足の動き角度
  float[] legAngleBaseSpd = new float[LEG_COUNT]; //  足の動き角度の速度
  float[][] legPointAngleBase = new float[LEG_COUNT][CAP_JOINT_COUNT];  //  足の各ポイントの動き角度
 
  PVector position = new PVector();  //  くらげの位置
  float directionAngle;              //  クラゲの向き
  int tellCounter;                   //  動きの揺れを伝える速度
  float headSize;                    //  笠の大きさ
 
  Jellyfish(){ 
    init();  
    position.x = random(width) - halfWidth;
    position.y = random(height) - halfHeight;
  }
 
  //  初期化
  void init(){
    //  足のくねくねの動きの速さを決める
    for (int i = 0; i < LEG_COUNT; i++) {
      legAngleBaseSpd[i] = random(1) * 2+ 1;
    }
 
    //  かさのくねくねの動きの速さを決める
    capPointAngleBaseSpd = random(1) + 1;
 
    //  笠の大きさを決める
    headSize = random(5) + 5;
 
    //  笠のしぼみ具合を決める
    headWitherPower = random(1) * 0.1 + 0.01;
 
    //  方向を決める
    directionAngle = random(ROUND_DEGREE);
  }
 
  void draw(){
    pushMatrix();
 
    //  クラゲ描画の基点を決める
    translate(position.x, position.y, position.z);
    rotateZ((radians(directionAngle)));
    rotateX((radians(-30)));
 
    act();
    drawLeg();
    drawHead();
    popMatrix();
  }
 
  //  笠と足の位置を再計算する
  protected void act(){
 
    //  笠のポイントの広がり角度を、末端のポイントに伝える
    for (int i = CAP_JOINT_COUNT - 1; i > 0; i--) {
      capPointAngle[i] = capPointAngle[i - 1] * 0.999 - (0.1 * i * i);
    }
    capPointAngleBase += capPointAngleBaseSpd;
    capPointAngle[0] = (sin(radians(capPointAngleBase)) + 2) * 15 + 15;
 
    //  足の動き角度を末端のポイントに伝える
    for (int j = 0; j < LEG_COUNT; j++) {
      for (int i = CAP_JOINT_COUNT - 1; i > 0; i--) {
        legPointAngleBase[j][i] = legPointAngleBase[j][i-1] * 1.05;
      }
      legPointAngleBase[j][0] = sin(radians(legAngleBase[j])) * 3;
      legAngleBase[j] += legAngleBaseSpd[j];
    }
 
    //  移動
    position.x += cos(radians(directionAngle - 90)) * abs(cos(radians((capPointAngleBase + 50) / 2))) * 0.5;
    position.y += sin(radians(directionAngle - 90)) * abs(cos(radians((capPointAngleBase + 50) / 2))) * 0.5;
 
    //  折り返し判定
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
 
  //  足を描画する
  protected void drawLeg() {
    noStroke();
    fill(128, 128, 255, 16);
    float x = 0, y = 0, z = 0;
    int rCount = ROUND_DEGREE / LEG_COUNT;
    for (int r = 0; r < ROUND_DEGREE ;r += rCount) {
 
      pushMatrix();
      for (int i = 0; i < CAP_JOINT_COUNT; i++) {
        float deg = sin((radians((legPointAngleBase[r / rCount][i])))) * LEG_MOVE_POWER;
        x = sin(radians(deg)) * 20 * sin(radians(r));
        y = cos(radians(deg)) * 20;
        z = sin(radians(deg)) * 20 * cos(radians(r));
        translate(x, y, z);
        sphere(10);
      }
      popMatrix();
    }
  }
 
  //  笠を描画する
  protected void drawHead() {
    strokeWeight(10);
    stroke(192, 192, 255, 4);
    fill(64, 64, 128, 128);
 
    for (int r = 0; r < ROUND_DEGREE ;r += HEAD_DETAIL) {
 
      float x = 0, y = 0, z = 0;
      float tx = 0, ty = 0, tz = 0;
 
      pushMatrix();
      float p = 1;
 
      //  1列ずつ描画していく
      beginShape(TRIANGLE_STRIP);
      for (int i = 0; i < CAP_JOINT_COUNT; i++) {
        p -= headWitherPower;
        float deg = sin((radians((capPointAngle[i])))) * HEAD_CURVE_POWER;
        x += sin(radians(deg)) * headSize * sin(radians(r)) * p;
        y += cos(radians(deg)) * headSize;
        z += sin(radians(deg)) * headSize * cos(radians(r)) * p;
        vertex(x, y, z);
 
        tx += sin(radians(deg)) * headSize * sin(radians(r + HEAD_DETAIL)) * p;
        ty += cos(radians(deg)) * headSize;
        tz += sin(radians(deg)) * headSize * cos(radians(r + HEAD_DETAIL)) * p;
        vertex(tx, ty, tz);
      }
      endShape();
      popMatrix();
    }
  }
}

