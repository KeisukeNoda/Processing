int size = 700;
int textHeight = 30;
int border = 50;
int n = 0;
float h = sqrt(size*size - (size/2)*(size/2));

void setup()
{
  size(size,(int)h);
  textFont(createFont("Tempus Sans ITC", 25));
  smooth();
  fill(0);
  noStroke();
}

void draw()
{
  background(255);
  text("n = " + n, 10, textHeight);
  
  drawTris(0, n+1, new PVector(border, h-border),
           new PVector(width/2, border), new PVector(width-border, h-border));
}

void mousePressed()
{
  if((mouseButton == LEFT) && (n < 9)) n++;
  else if((mouseButton == RIGHT) && (n > 0)) n--;
}

void drawTris(int level, int maxLevels, PVector left, PVector top, PVector right)
{
  level++;
  
  if(level >= maxLevels) {
    triangle(left.x, left.y, top.x, top.y, right.x, right.y);
  } else {
    PVector a = PVector.add(left, PVector.div(PVector.sub(top, left), 2));
    PVector b = PVector.add(right, PVector.div(PVector.sub(top, right), 2));
    PVector c = PVector.add(left, PVector.div(PVector.sub(right, left), 2));

    drawTris(level, maxLevels, a, top, b);
    drawTris(level, maxLevels, left, a, c);
    drawTris(level, maxLevels, c, b, right);
  }
}


