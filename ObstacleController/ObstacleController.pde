import controlP5.*;
import processing.serial.*;

PShape s;
float scaleF = 1;
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
    //size(400,600);
    size(displayWidth, displayHeight); //fullscreen
    ports = Serial.list();
    s = loadShape("car.svg");
    scaleF = width/400;
    s.scale(scaleF);

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
           .setSize(bw,bh);
    }

    bSetup = true;
}

void draw() {
    background(50);

    //Only draw if connected to Arduino
    if (myPort != null) {
        // Draw street an Car of Seat
        drawStreet(width/3-3);
        drawStreet(2*width/3-3);
        streetPos+=2;
        if (streetPos > stripe+gap) streetPos = 0;
        shape(s, width/2-s.width*scaleF/2, -s.height*scaleF/2);

        //Draw obstacle
        int x = mouseX;
        int y = mouseY;
        shape(s, x-s.width*scaleF/2, y-s.height*scaleF/2);

        int devX = x-xpos;
        int devY = y-ypos;

        if(Math.abs(devX) > tolerance || Math.abs(devY) > tolerance) {

            distance = dist(x, y, width/2, 0)/height*200;

            float disX = (width/2-x);
            float disY = (0-y);
            angle = atan(Math.abs(disY)/disX) * 57.295;
            if (angle < 0) angle += 180;

            drawValuesNHelpers(x,y);

            // myPort.write(Math.round(distance));         //send Mouse Position X
            myPort.write(Math.round(angle));         //send Mouse Position Y
            // println("S:" + distance + ":" + angle);
        }
    }
}

void drawValuesNHelpers(int x, int y) {
    noStroke();
    fill(255);
    ellipse(x, y, 10, 10);
    stroke(50);
    strokeWeight(1);
    line(width/2, 0, x, y);
    text("Distance: " + distance, 170, 10);
    text("Angle: " + angle, 170, 30);
}

void controlEvent(ControlEvent theEvent) {
    if (bSetup) {
        int portIndex = int(theEvent.getController().getValue());
        String portname = Serial.list()[portIndex];
        myPort = new Serial(this, portname, 115200);
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
