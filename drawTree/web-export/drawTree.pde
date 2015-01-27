int textHeight = 30, n = 1;
float theta = PI / 6;

void setup(){
  size(800, 600);
  textFont(createFont("Tempus Sans ITC", 25));
  fill(0);
  smooth();
}

void draw(){
  background(255);
  text("n = " + n, 10, textHeight);
  translate(width/2,height);
  
  if (n == 0) {
    return;
  }
  
  line(0,0,0,-height * 2/5);
  translate(0,-height * 2/5);
  branch(n, float(height/5));
}

void mousePressed(){
  if((mouseButton == LEFT) && (n < 15)) n++;
  else if((mouseButton == RIGHT) && (n > 0)) n--;
}

void branch(int p, float h){

  h *= 0.75;

  if (h > height / 5 * Math.pow(0.75, p)) {
    pushMatrix();
    rotate(theta);
    line(0, 0, 0, -h);
    translate(0, -h);
    branch(p, h);
    popMatrix();

    pushMatrix();
    rotate(-theta);
    line(0, 0, 0, -h);
    translate(0, -h);
    branch(p, h);
    popMatrix();
  }
}


