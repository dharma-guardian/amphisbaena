import processing.serial.*;

Serial myPort;  // Create object from Serial class
int xpos, ypos;
int tolerance = 5;
float distance;
float angle = 0;

void setup() {
    size(200,200); //make our canvas 200 x 200 pixels big
    String portName = Serial.list()[2]; //change the 0 to a 1 or 2 etc. to match your port
    myPort = new Serial(this, portName, 9600);
    fill(255, 0, 0, 255);
}

void draw() {
    background(255);

    int x = mouseX;
    int y = mouseY;
    noStroke();
    ellipse(x, y, 10, 10);
    stroke(50);
    strokeWeight(1);
    line(100, 0, x, y);

    int devX = x-xpos;
    int devY = y-ypos;
    distance = dist(x, y, 100, 0);
    text("Distance: " + distance, 10, 30);
    float disX = (100-x);
    float disY = (0-y);
    angle = atan(Math.abs(disY)/disX) * 57.295;
    if (angle < 0) angle += 180;
    text("Angle: " + angle, 10, 50);

    if(Math.abs(devX) > tolerance || Math.abs(devY) > tolerance) {
        myPort.write(Math.round(distance));         //send Mouse Position X
        myPort.write(Math.round(angle));         //send Mouse Position Y
    }   
}