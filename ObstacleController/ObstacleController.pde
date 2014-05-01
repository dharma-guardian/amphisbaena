import processing.serial.*;

Serial myPort;  // Create object from Serial class
int xpos, ypos;
int tolerance = 5;
float distance;
float angle = 0;
int streetPos = 0;
int stripe = 40;
int gap = 30;
PShape s;

void setup() {
    size(400,600); //make our canvas 200 x 200 pixels big
    String portName = Serial.list()[2]; //change the 0 to a 1 or 2 etc. to match your port
    myPort = new Serial(this, portName, 9600);
    s = loadShape("car.svg");
  
}

void draw() {
    background(50);
    
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
    text("Distance: " + distance, 10, 10);
    float disX = (width/2-x);
    float disY = (0-y);
    angle = atan(Math.abs(disY)/disX) * 57.295;
    if (angle < 0) angle += 180;
    text("Angle: " + angle, 10, 30);

    if(Math.abs(devX) > tolerance || Math.abs(devY) > tolerance) {
        myPort.write(Math.round(distance));         //send Mouse Position X
        myPort.write(Math.round(angle));         //send Mouse Position Y
        println("S:" + distance + ":" + angle);
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