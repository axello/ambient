/**
  OSCTest
  
  Simpel app that listens to OSC channel and draws circles at spots according to the input
  on the channel
  
  Axel Roest, May 2011
  
**/

import oscP5.*;
import netP5.*;

// values for one ball
int x,y,xOld, yOld;
float xSpeed, ySpeed;
int xMax, yMax, radius;
int hue;
boolean gotOSCMessage=false;
boolean brownian = true;

OscP5 oscP5;
NetAddress myRemoteLocation;

void setup() 
{
  if (false) {
    xMax = screen.width;
    yMax = screen.height;
  } else {
    xMax = 400;
    yMax = 400;
  }
  size(xMax,yMax);
  frameRate(25);
  background(100);
  colorMode(HSB,255);
  hue = 100;
  strokeWeight(2);
  x=xMax / 2;
  y=yMax / 2;
  radius = 100;
  drawBall(x,y,radius);
  oscP5 = new OscP5(this,5000);

}

void draw() {//------------------------------------------------------------   D R A W
  if (gotOSCMessage) {
    if (brownian) {
      line(xOld,yOld,x,y);
      xOld=x;
      yOld=y;
//      drawBall(x,y,2);
    } else {
      background(100);
//    println ("[x,y]=" + str(x) + "," + str(y));
      drawBall(x,y,radius);
    }  
    gotOSCMessage=false;
  }
}

void drawBall(int xplot, int yplot, int radius)
{
  fill(hue, 202, 255);
  ellipse(xplot,yplot,radius,radius);
}

void oscEvent(OscMessage theOscMessage) {
// print ("OSC: " + theOscMessage.addrPattern() + " ");
/* for (int i = 0 ; i <    theOscMessage.arguments().length; i++ ) {
   print (" ["+ i + "]=" + theOscMessage.get(i).stringValue());
 } */
//  println("OSC data: "+theOscMessage.data);
  if(theOscMessage.checkAddrPattern("/xbee/x")==true) {
    gotOSCMessage = true;
    int selector = theOscMessage.get(0).intValue();
    int value = theOscMessage.get(1).intValue();
    switch (selector) {
      case 0 :
        x=value * xMax / 1023;
        break;
      case 1 :
        y=value * yMax / 1023;
        break;
      case 2 :
        hue = value / 4;
        break;
      default:
        break;
    }
  //  println ("gotOSCMessage");
  }

  if(theOscMessage.checkAddrPattern("/xbee/reset")==true) {
    x=xMax / 2;
    y=yMax / 2;
    xOld=x;
    yOld=y;
    hue=int(random(255));
    stroke(hue, 202, 255);
  }
    
}


