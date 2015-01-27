int npoints = 100, n = 0, a = 1, b = 1;
int x[] = new int[npoints], y[] = new int[npoints]; 

void setup(){
  size(600, 400);
  background(255);
  smooth();
}

void draw(){ }

void mouseClicked(){
  update(mouseX, mouseY);
}

void update(int p, int q){
  if(mouseButton == LEFT){
    if(n == npoints){
      n = 0;
      background(255);
    }
      x[n] = p;
      y[n] = q;
    if (n == 3 * a + 1) {
      x[n] = 2 * x[n - 1] - x[n - 2]; 
      y[n] = 2 * y[n - 1] - y[n - 2];
      a++;
    } 
    
    noStroke();
    fill(255, 0, 0);
    ellipse(x[n], y[n], 5, 5);

    if(n != 0){
      stroke(200);
      line(x[n - 1], y[n - 1], x[n], y[n]);

      if(n == 3 * b){
         stroke(0, 0, 255);
         noFill();
         bezier(x[n - 3], y[n - 3], x[n - 2], y[n - 2], x[n - 1], y[n - 1], x[n], y[n]);
         b++;
      }
    }
    n++;
  }
  else if(mouseButton == RIGHT){
    n = 0;
    a = b = 1; 
    background(255);
  }
}

