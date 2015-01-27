float x, y;
float px,py;
float rdm;
float count=60;
float inc;

int ns=10;
int hInc=7;
int div = 40;
float strk=1.3;
int blockSize = 13;

void setup(){
  size(600, 530);
  background(255,250,245);
  smooth();
  stroke(255,250,245);
  strokeWeight(strk);
  frameRate(900);
  fill(51);
  rectMode(CORNERS);
  rect(100,70,width-100,height-70);
  pushMatrix();
  noStroke();
  fill(255,250,245);
  translate(width * 0.21, height * 0.25);
  rectMode(CENTER);
  for(int i = 0; i < letters.length; i++)
  {
     int xPos = 0;
     int yPos = 0;
    
     // for each letter, draw pixel dots
     for(int j = 0; j < letters[i].length; j++)
     {
        if(letters[i][j] == 1)
        {
          rect(xPos, yPos, blockSize, blockSize);
        }
        
        xPos += blockSize;
        
        if(j % 4 == 3)
        {
          xPos = 0;
          yPos += blockSize; 
        }
     }
     
     translate(blockSize * 6, 0);
  }
  popMatrix();
  
  // draw jumping letters
  pushMatrix();
  translate(width * 0.21, height * 0.65);
  rectMode(CENTER);
  for(int i = 0; i < letters.length; i++)
  {
     int xPos = 0;
     int yPos = 0;
    
     // for each letter, draw pixel dots
     for(int j = 0; j < letters[i].length; j++)
     {
        if(letters[i][j] == 1)
        {
          pushMatrix();
          translate(xPos, yPos);
          rotate(radians(random(-10, 10)));
          rect(0, 0, blockSize, blockSize);
          popMatrix();
        }
        
        xPos += blockSize;
        
        if(j % 4 == 3)
        {
          xPos = 0;
          yPos += blockSize; 
        }
     }
     
     translate(blockSize * 6, 0);
  }
  popMatrix();
}

void draw(){
  if(inc>25){  inc=25;  }
  else{  inc = count/div;  }
  rdm=random(0,300);
  y=noise(rdm)*ns+count;
  line(px, py, x, y);
  py=y;
  px=x;
  x+=hInc;   
  if(x > width + 10){ 
    noStroke();
    x=0;
    count = count + inc;
    py=y;
    px=x;
    stroke(255,250,245);
  }
  if (count>height-80){  noLoop();  }
}

int[][] letters = {
  
  { 1, 1, 1, 0, // n
    1, 0, 0, 1,
    1, 0, 0, 1,
    1, 0, 0, 1,
    1, 0, 0, 1 },
 
 { 0, 0, 0, 0, // o
   0, 1, 1, 0,
   1, 0, 0, 1,
   1, 0, 0, 1,
   0, 1, 1, 0 },   
   
 { 0, 1, 0, 0, // i
   0, 0, 0, 0,
   0, 1, 0, 0,
   0, 1, 0, 0,
   0, 1, 0, 0 },
   
 { 0, 1, 1, 0, // s
   1, 0, 0, 0,
   1, 1, 0, 0,
   0, 0, 1, 0,
   1, 1, 1, 0 }, 
   
 { 0, 1, 1, 0, // e
   1, 0, 0, 1,
   1, 1, 1, 0,
   1, 0, 0, 0,
   0, 1, 1, 1 }
};


