boolean playing;
boolean solvedPuzzle;

color ColorOfbackground = color(204);
color ColorOfTile       = color(255, 127, 127);
color ColorOfTile2      = color(112, 163, 224);
color ColorOfTile3      = color(142, 225, 188);
color ColorOfempty      = color(51);
color ColorOfhighlight  = color(255, 183, 183);
color ColorOfhighlight2 = color(168, 194, 245);
color ColorOfhighlight3 = color(255, 214, 178);
color ColorOfhighlight4 = color(186, 225, 200);

int newSpacePosition;
int newSpaceX, newSpaceY;
int score;

button[] Tiles = new button[10];
TileSpace empty;
TileSpace times;
TileSpace clear;
TileSpace notes;

class Tile {
  int number;
  int position;
  int x, y, h;
  color c;
  boolean pointed;
  
  boolean pointed() {
   if (mouseX >= x - (h / 2) && mouseX <= x + (h / 2) && mouseY >= y - (h / 2) && mouseY <= y + (h / 2)) {
      return true;
    } else {
      return false;
    }
  }
}
  
class button extends Tile {
  button (int tempX, int tempY, int tempN) {
    x = tempX;
    y = tempY;
    h = 96;
    c = color(192);
    number   = tempN;
    position = tempN;
  }
  
  void display(int TileColor) {
    rectMode(CENTER);
    noStroke();
    fill(TileColor);
    rect(x, y, h, h);

    fill(255);
    textFont(createFont("Century Gothic Bold", 44));
    textAlign(CENTER);
    text(number, x , y + 18);
  }
}

class TileSpace extends Tile {

  TileSpace(int tempX, int tempY, int tempN) {
    x = tempX;
    y = tempY;
    h = 96;
    c = color(42);
    number   = tempN;
    position = 0;
  }
  
  void display(int TileColor) {
    rectMode(CENTER);
    noStroke();
    fill(TileColor);
    rect(x, y, h, h);
  }
}

void setup(){
  size(400, 300);
  background(ColorOfbackground);
  frameRate(15);
  
  playing      = false;
  solvedPuzzle = false;
  score = 0;

  newSpacePosition = 0;
  newSpaceX        = 350;
  newSpaceY        = 250;
  
  Tiles[0] = new button(350, 250, 0);
  Tiles[1] = new button(50,  50,  1);
  Tiles[2] = new button(150, 50,  2);
  Tiles[3] = new button(250, 50,  3);
  Tiles[4] = new button(50,  150, 4);
  Tiles[5] = new button(150, 150, 5);
  Tiles[6] = new button(250, 150, 6);
  Tiles[7] = new button(50,  250, 7);
  Tiles[8] = new button(150, 250, 8);
  Tiles[9] = new button(250, 250, 9);
  times = new TileSpace(350, 50,  0);
  notes = new TileSpace(350, 150, 0);
  empty = new TileSpace(350, 250, 0);
  clear = new TileSpace(350, 250, 0);

  times.display(ColorOfTile2);
  notes.display(ColorOfTile3);
  empty.display(ColorOfempty);
  notesPrint();
  
  for (int i = 1; i <= 9; i++) {
    Tiles[i].display(ColorOfTile);
  }
  
  shuffleTiles();
}

void draw(){
}

void shuffleTiles(){
  int shuffleMoves = 0;
  int oldSelected  = 0;
  int pointed      = 9;
  
  while (shuffleMoves <= 100) {
    if (pointed != oldSelected) {
      playTile(pointed);
      oldSelected = pointed;
      shuffleMoves++;
    }
    pointed = int(random(8)) + 1;
  }
  playing = true;
}

void mouseReleased(){
  if (solvedPuzzle != true) {
    for (int i = 1; i <= 9; i++) {
      if (Tiles[i].pointed() == true) {
        playTile(i);
        break;
      }
    }
  }
}

void playTile(int pointed) {
  switch (Tiles[pointed].position) {
    case 1:
      if (empty.position == 2 || empty.position == 4) {
        moveTile(pointed);
      }  break;
    case 2:
      if (empty.position == 1 || empty.position == 3 || empty.position == 5) {
        moveTile(pointed);
      }  break;
    case 3:
      if (empty.position == 2 || empty.position == 6) {
        moveTile(pointed);
      }  break;
    case 4:
      if (empty.position == 1 || empty.position == 5 || empty.position == 7) {
        moveTile(pointed);
      }  break;
    case 5:
      if (empty.position == 2 || empty.position ==4  || empty.position == 6 || empty.position == 8) {
        moveTile(pointed);
      }  break;
    case 6:
      if (empty.position == 3 || empty.position ==5 || empty.position == 9) {
        moveTile(pointed);
      }  break;
    case 7:
      if (empty.position == 4 || empty.position == 8) {
        moveTile(pointed);
      }  break;
    case 8:
      if (empty.position == 5 || empty.position == 7 || empty.position == 9) {
        moveTile(pointed);
      }  break;
    case 9:
      if (empty.position == 6 || empty.position == 8 || empty.position == 0) {
        moveTile(pointed);
      }  break;
    case 0:
      if (empty.position == 9) {
        moveTile(pointed);
        checkResult();
      }  break;
    }
}

void moveTile(int pointed){
  newSpacePosition = Tiles[pointed].position;
  newSpaceX = Tiles[pointed].x;
  newSpaceY = Tiles[pointed].y;
 
  Tiles[pointed].position = empty.position;
  Tiles[pointed].x = empty.x;
  Tiles[pointed].y = empty.y;
  
  empty.position = newSpacePosition;
  empty.x = newSpaceX;
  empty.y = newSpaceY;
  
  empty.display(ColorOfempty);
  Tiles[pointed].display(ColorOfTile);
  
  if (playing == true) {
    score++;
  }
  times.display(ColorOfTile2);
  scorePrint();
}

void checkResult(){
  solvedPuzzle = true;
  int a = 1;
  
  while (solvedPuzzle == true && a <= 9) {
    if (Tiles[a].position != a) {
      solvedPuzzle = false;
    }
    a++;
  }
  if (solvedPuzzle == true) {
    empty.display(ColorOfbackground);
    times.display(ColorOfhighlight2);
    scorePrint();
    notes.display(ColorOfhighlight4);
    notesPrint();
    for (int i = 1; i <= 9; i++) {
      Tiles[i].display(ColorOfhighlight);
    }
    clear.display(ColorOfhighlight3);
    fill(51);
    textAlign(LEFT);
    textFont(createFont("Century", 28));
    text("Well",310,245);
    text("done!",325,275);
  }
}

void notesPrint(){
  noStroke();
  fill(51);
  textAlign(LEFT);
  textFont(createFont("Century", 15));
  text("Press a key:", 310, 128);
  text("[R] restart", 310, 155);
  text("[Q] quit", 310, 180);
}

void scorePrint(){
  noStroke();
  fill(255);
  textFont(createFont("Century Gothic Bold", 44));
  textAlign(CENTER);
  text(score, 350, 50 + 18); 
}

void keyPressed(){
  if (key == ESC) {
    key = 0;
  }
  if (key == 'q' || key == 'Q') {
    exit();
  }
  if (key == 'r' || key == 'R') {
    setup();
  }
}


