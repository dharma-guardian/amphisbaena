import controlP5.*;
import processing.serial.*;

PShape s;
int xpos, ypos;
int tolerance = 5;
float distance;
float angle = 0;
int streetPos = 0;
int stripe = 40;
int gap = 30;

Serial myPort;  // Create object from Serial class
String[] ports;
ControlP5 cp5;
boolean bSetup = false;

void setup() {
    size(400,600);
    //size(displayWidth, displayHeight); //fullscreen
    ports = Serial.list(); //change the 0 to a 1 or 2 etc. to match your port
    s = loadShape("car.svg");

    cp5 = new ControlP5(this);

    int bx = 4;
    int bw = 160;
    int bh = 15;
    int byg = 4;
    int by;
    for (int i = 0; i < ports.length; ++i) {
        by = (bh+byg)*i+byg;
        // create a new button with name 'buttonA'
        cp5.addButton(ports[i])
           .setValue(i)
           .setPosition(bx,by)
           .setSize(bw,bh)
           ;
    }

    bSetup = true;
}

void draw() {
    background(50);

    if (myPort != null) {
        drawStreet(width/3-3);
        drawStreet(2*width/3-3);
        streetPos+=2;
        if (streetPos > stripe+gap) streetPos = 0;

        shape(s, width/2-s.width/2, 0);

        int x = mouseX;
        int y = mouseY;

        shape(s, x-s.width/2, y-s.height/2);

      /*  noStroke();
        fill(255);
        ellipse(x, y, 10, 10);
        stroke(50);
        strokeWeight(1);
        line(width/2, 0, x, y);*/

        int devX = x-xpos;
        int devY = y-ypos;
        distance = dist(x, y, width/2, 0)/height*200;
        text("Distance: " + distance, 170, 10);
        float disX = (width/2-x);
        float disY = (0-y);
        angle = atan(Math.abs(disY)/disX) * 57.295;
        if (angle < 0) angle += 180;
        text("Angle: " + angle, 170, 30);

        if(Math.abs(devX) > tolerance || Math.abs(devY) > tolerance) {
            myPort.write(Math.round(distance));         //send Mouse Position X
            myPort.write(Math.round(angle));         //send Mouse Position Y
            println("S:" + distance + ":" + angle);
        }
    }
}

void controlEvent(ControlEvent theEvent) {
    if (bSetup) {
        int portIndex = int(theEvent.getController().getValue());
        String portname = Serial.list()[portIndex];
        myPort = new Serial(this, portname, 9600);
    }
}

void drawStreet(int lane) {
    int toppos = streetPos-stripe-gap;
    while (toppos < height) {
        fill(255);
        rect(lane, toppos, 6, stripe);
        toppos += stripe + gap;
    }
}
