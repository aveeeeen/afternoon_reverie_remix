/*
  I've cited most of the processes and ideas from Daniel Shiffmans "Learning Processing" tutorials.
  Thanks, Prof.Shiffman!
  
  Learning Processing
  Daniel Shiffman
  http://www.learningprocessing.com
  Example 15-7: Displaying the pixels of an image
*/

import processing.video.*;
Movie movie; 

PImage img;
float pixSize;
float ratio;
float imgRatio;
float mosaicRatio;
int col,row;
int xOffset;
int yOffset;
float imgXOffset;
float imgYOffset;
color imgData[];

int ellapsed = 0;
int interval = 50*1;

void setup() {
  fullScreen();
  //size(1920,1080);
  //size(1280, 720);
  frameRate(23.976);
  
  movie = new Movie(this, "noCode.mp4"); 
  movie.loop();
  
  img = loadImage("2.png");
  ratio = (float)width/(float)height;
  imgRatio = (float)movie.width/ (float)movie.height;
  
  //mosaicRatio = (float)col/(float)row;
  if(width*height < movie.width*movie.height){
    imgXOffset = ((float) width/ (float) movie.width);
    imgYOffset = ((float) height/ (float) movie.height);
  }else{
    imgXOffset = ((float) movie.width/ (float) width);
    imgYOffset = ((float) movie.height/ (float) height);
  }
  
  xOffset = ceil((float)movie.width / (float)col);
  yOffset = ceil((float)movie.height / (float)row);
  
  
  println(movie.width  + " * " + movie.height );
  println(ratio + "ratio");
  println(imgRatio + "image ratio");
  println(imgXOffset + "imgOffset");
  
}

void movieEvent(Movie movie) {
  movie.read();
}

float modNum(float targetMod, float input){
  float mod = input % targetMod;
  return input - mod;
}

float invertC(float input){
  return 255 - input;
}

float pixVar = 1.0; 
float ratioVar = 1.0;
int index;
int initC = 100;
int c = 1;
boolean pause;
boolean cState = true;
boolean invertColor = false;

int keyFrame = 0;
int maxState;
color[][] tempC;

void control(){
  if(c > initC) cState = true;
  if(c < -initC) cState = false;
  if(cState) c--;
  if(!cState) c++;
  //c = c/4;
  if(c == 0 && cState) c = -1;
  if(c == 0 && !cState) c = 1;
}

void draw() {
  
  if(movie.time() == movie.duration()) movie.jump(0.0);
  
  //change array value each 50 millisec
  //100 - 0 > 100 true, 101 - 100 > 100 false
  
  pixSize = 1.0*pixVar;
  
  col = ceil((float)width / pixSize);
  row = ceil((float)height / pixSize);
  
  xOffset = ceil(((float)movie.width / (float)col)*ratioVar);
  yOffset = ceil(((float)movie.height / (float)row)*ratioVar);
  
  
  
  if(millis()-ellapsed>interval){
    control();
    ellapsed = millis();
    println(c);
  }
  
  movie.loadPixels();
  //if(!pause) control(); 
  
  int a = 0;
  int yAxisSplit = round((float)row / (float)4);
  
  tempC = new color[col][row];
  
  //img data extraction/transformation
  for (int i = 0; i < col; i ++ ) {
    for (int j = 0; j < row; j ++ ) {
      int x = i*xOffset;
      int y = j*yOffset;
      int w = img.width;
      int h = img.height;
      
      switch(keyFrame){
        case 0:
          index = x + y * (w);
          break;
        case 1:
          initC = 1000;
          index = x + y * (w);
          index -= c*2;
          //if(i == 0) println(x * cos(PI/j) + (y  * w));
          break;
        case 2:
          initC = 10;
          index = (int)(x * sin(PI/j) + (y * w/2));
          //index = (int)((x)*cos(PI/j)*2+((y)*sin(PI/j)*2)*w);
          index -= x*c*sin(PI/j);
          break;
        case 3:
          interval = 200;
          initC = 20;
          index = (int)((y) + (x) * (w/(c*2)));
          index -= int(c*1.0/2.0)*cos(PI/j)*2*2;
          break;
        case 4:
          c = 1;
          index = x + y * (w);
          if(millis()-ellapsed > 2000) keyFrame = 5;
          break;
        case 5:
          interval = 200;
          initC = 5;
          index = (int)((x) + (y*2) * (w/c));
          index += int(c/10.0)*sin(PI/j);
          break;
      }
      
      maxState = 5;
      //keyFrame = 5;
      
      if(millis()-ellapsed>interval){
        control();
        ellapsed = millis();
      }
      
      if(index < 0) index *= -1;
      while(index > img.pixels.length - 1) index = index - (img.pixels.length - 1);
      tempC[i][j] = movie.pixels[index];//imgData[index]; //<>//
    }
  }
  movie.updatePixels();
  // rendering
  
  loadPixels();
  for (int i = 0; i< width; i++){
    for (int j = 0; j < height; j++){
      int ci = int(i/pixSize);
      int cj = int(j/pixSize);
      
      float rNorm = red(tempC[ci][cj]);
      float gNorm = green(tempC[ci][cj]);
      float bNorm = blue(tempC[ci][cj]);
      
      if(invertColor){
        rNorm = invertC(rNorm);
        gNorm = invertC(gNorm);
        bNorm = invertC(bNorm);
      }
      
      pixels[i+j*width] = color(rNorm,gNorm,bNorm);
    }
  }
  updatePixels();
  
  println(keyFrame + ": keyFrame State");
  println(pixVar + ": pixVar");
}

void keyPressed() {
  switch(key){
    case 'w':
      keyFrame++;
      if(keyFrame > maxState) keyFrame = 0;
      break;
    case 's':
      keyFrame--;
      if(keyFrame < 0) keyFrame = maxState;
      break;
    case ' ':
      pause = !pause;
      break;
    case 'd':
      pixVar *= 2.0;
      if(pixVar > 64.0) pixVar = 1.0;
      break;
    case 'a':
      pixVar /= 2.0;
      if(pixVar < 1.0){
        pixVar = 1.0;
      }
      
      break;
    case 'i':
      invertColor = !invertColor;
      break;
    case 'j':
      keyFrame = 0;
      break;
    case 'k':
      pixVar = 1.0;
      break;
    case 'l':
      ratioVar *= 2.0;
      if(ratioVar == 4.0) ratioVar = 1.0;
      break;
  }
}
