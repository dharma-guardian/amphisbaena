import controlP5.*;
import processing.serial.*;
import spacebrew.*;
import de.looksgood.ani.*;

static final int SERVONUM = 16;
static final int SERVOMIN = 150;
static final int SERVOMAX = 670;
static final float ROADWIDTH = 16.5;
static final float CARWIDTH = 2;
static final float BACKWARDRANGE = ROADWIDTH * 2; //if you change this value, adjust the size of the visual representation slider2D

Spacebrew sb;
int driverHeading = 0;
float driverPositionX = 0;
float driverOffsetX = -.7;
String trigger = "";
int triggerNum;

ControlP5 cp5;
Knob motorKnob;
Textlabel neutralLabel, attackLabel, maxLabel;
Slider2D obstacle;
Slider sliderDriverPosX;
Slider sliderDriverOffsetX;
boolean renderObstacle = false;
boolean renderAnimation = false;
boolean readTriggers = false;
boolean debug = false;

float animationDuration = 7;
int aniX = 10;
int aniY = 100;
int aniToY = 0;
Ani animation;

Seat theSeat;
ServoMotor[] motors = new ServoMotor[SERVONUM];
int selectedMotor = -1;

void setup() {
  size(1000,720,P2D);

  theSeat = Seat.getInstance();

  cp5 = new ControlP5(this);

  //Load values for Motors from config file
  String filename = "motorValues.txt";
  File file = new File(sketchPath(filename));
  if (file.exists()) {
    String lines[] = loadStrings(filename);
    for (int m = 0; m < motors.length; ++m) {
      String[] intensities = split(lines[m], ',');
      motors[m] = new ServoMotor(m, int(intensities[0]), int(intensities[1]), int(intensities[2]));
    }
  }
  else {
    for (int m = 0; m < motors.length; ++m) {
    motors[m] = new ServoMotor(m);
    }
  }
  theSeat.registerMotors(motors);
  generateView();

  frameRate(240);

  // instantiate the spacebrewConnection variable
  sb = new Spacebrew( this );

  // declare your subscribers
  sb.addSubscribe( "heading", "range" );

  // declare your subscribers
  sb.addSubscribe( "positonX", "string" );

   // declare your subscribers
  sb.addSubscribe( "trigger", "string" );

  // connect to spacebrew
  String server      = "ws://spacebrew.icts.sbg.ac.at:9000";
  String name        = "Seat";
  String description = "Client that receives heading and x-position data from OpenDS";
  sb.connect(server, name, description);
  //init animation library
  Ani.init(this);
  Ani.setDefaultEasing(Ani.LINEAR);
}

void draw() {
  background(96);
  //manual Obstacle positioning
  ///driverOffsetX = sliderDriverOffsetX.getValue();
  if (renderObstacle) {
    //Obstacle Positon in rear space of the driver
    float obstacleX = (obstacle.arrayValue()[0] - 50) * 0.01 * ROADWIDTH;
    float obstacleY = obstacle.arrayValue()[1] * 0.01 * BACKWARDRANGE;

    calculateSensitivity(obstacleX, obstacleY);
  }
  //Preset obstacle animation
  if(renderAnimation){
    float obstacleX = (aniX - 50) * 0.01 * ROADWIDTH;
    float obstacleY = aniY * 0.01 * BACKWARDRANGE;
    calculateSensitivity(obstacleX, obstacleY);
    //logString("y: "+aniY);
    cp5.getController("obstacle").setArrayValue(new float[] {aniX, aniY});
  }
  cp5.getController("sliderDriverPosX").setValue(driverPositionX+driverOffsetX);
  cp5.getController("labelTrigger").setStringValue("Last Trigger: "+trigger);
  theSeat.process();

}

void calculateSensitivity(float obstacleX, float obstacleY){
    
  // calc distance in the range [0.0-1.0]
    float distance = abs(dist(obstacleX, obstacleY, driverPositionX, 0)) / BACKWARDRANGE;

    //calc angle
    float lateralDistance = obstacleX - driverPositionX;      // lateral distance obstacle to driver

    float angle;
    //avoid zero division
    if (lateralDistance != 0) {
      angle = atan(obstacleY / lateralDistance) * 57.295; // angle from obstacle to driver
    }
    else {
      angle = 90;
    }
    //move negativ angles to range between 180 and 270
    if (lateralDistance >= 0) {
      angle += 90;
    }
    else {
      angle += 270;
    }
    // print("Angle from atan: " + angle + ", heading: " + driverHeading);
    //subtract heading of the driver to the angle
    angle = (angle - driverHeading * 360 / 1024) % 360;
    //if negativ we have to add 360 to get range [90-270]
    if (angle < 0) angle += 360;

    // print("Angle + heading" + angle);

    //print("Angle: " + angle + ", Distance: " + distance + "obstacleX: " + obstacleX + "obstacleY: " + obstacleY);
    for (int i = 0; i < motors.length; ++i) {
      motors[i].setIntensityFromAngleAndDistance(angle, distance );
      // if (i == 0) {
      //   logString("Motor: " + i + ", Pulse: " + motors[i].getServoPulse());
      // }
    }
}

void onStringMessage( String name, String value) {
  String strPositionX = "positonX";
  String strTrigger = "trigger";
  //logString(name+" : "+value);
  if(name.equals(strPositionX))
  driverPositionX = parseFloat(value);
  else if(name.equals(strTrigger))
  {
    trigger = value;
    //triggerNum = Integer.parseInt(split(trigger, 'r')[1]); //Split the triggerstring (i.e. "trigger1") to get the number only for a switch case
    if(readTriggers)
    animationCondition2(trigger);
  }
  // logString("got string message " + name + " : " + value);
}


void onRangeMessage( String name, int value ) {
  driverHeading = value;
  // logString("got range message " + name + " : " + value);
}

/**
*
* Views
*
**/
void generateView() {

  // Draw View for MotorGrid
  RadioButton motorGrid = cp5.addRadioButton("motorSelected")
                 .setPosition(40,80)
                 .setSize(20,20)
                 .setItemsPerRow(4)
                 .setSpacingColumn(30)
                 .setSpacingRow(30);
  for (int j = 15; j > -1; --j) {
    motorGrid.addItem(""+j,j);
  }

  // Draw Controls for selected Motor
  motorKnob = cp5.addKnob("motorChange")
               .setRange(SERVOMIN,SERVOMAX)
               .setValue(int((SERVOMAX+SERVOMIN)/2))
               .setPosition(40,280)
               .setRadius(40)
               .setDragDirection(Knob.HORIZONTAL)
               // .setScrollSensitivity(5)
               .setNumberOfTickMarks(10)
               // .setTickMarkLength(4)
               // .snapToTickMarks(true)
               ;
  motorKnob.getCaptionLabel().setVisible(false);

  cp5.addButton("minus")
     .setPosition(50,370)
     .setSize(20,20)
     .setCaptionLabel("-")
     ;

  cp5.addButton("plus")
     .setPosition(90,370)
     .setSize(20,20)
     .setCaptionLabel("+")
     ;

  //Motor Setter Buttons
  cp5.addButton("setNeutral")
     .setPosition(140,280)
     .setSize(80,20)
     ;

  neutralLabel = cp5.addTextlabel("neutralLabel")
                    .setText("null")
                    .setPosition(240,280)
                    ;

  cp5.addButton("setAttack")
     .setPosition(140,310)
     .setSize(80,20)
     ;

  attackLabel = cp5.addTextlabel("attackLabel")
                   .setText("null")
                   .setPosition(240,310)
                   ;

  cp5.addButton("setMax")
     .setPosition(140,340)
     .setSize(80,20)
     ;

  maxLabel = cp5.addTextlabel("maxLabel")
                .setText("null")
                .setPosition(240,340)
                ;

  cp5.addButton("neutral")
     .setPosition(50,410)
     .setSize(80,20)
     ;

  cp5.addButton("attack")
     .setPosition(50,440)
     .setSize(80,20)
     ;
  cp5.addButton("maxI")
     .setPosition(50,470)
     .setSize(80,20)
     ;
  cp5.addButton("export")
     .setPosition(50,500)
     .setSize(80,20)
     ;      


  // Select Port from DropdownList
  String[] ports = Serial.list();
  DropdownList portList = cp5.addDropdownList("portList")
          .setPosition(40, 40)
          .setItemHeight(20)
          .setWidth(200)
          .setBarHeight(15)
          .setHeight(400)
          ;
  portList.captionLabel().set("Select Port");
  portList.captionLabel().style().marginTop = 3;
  portList.captionLabel().style().marginLeft = 3;
  portList.valueLabel().style().marginTop = 3;
  for (int i = 0; i < ports.length; ++i) {
      portList.addItem(ports[i], i);
  }

  cp5.addCheckBox("debugMode")
     .setPosition(280, 20)
     .setSize(20, 20)
     .addItem("debug", 0)
     ;

  cp5.addCheckBox("readObstacle")
     .setPosition(620, 180)
     .setSize(20, 20)
     .addItem("renderObstacle", 0)
     ;
  cp5.addCheckBox("readAnimation")
     .setPosition(620, 220)
     .setSize(20, 20)
     .addItem("renderAnimation", 0)
     ; 
  cp5.addCheckBox("triggerAnimation")
     .setPosition(620, 260)
     .setSize(20, 20)
     .addItem("readTriggers", 0)
     ;       

  cp5.addSlider("sliderD")
     .setPosition(280,60)
     .setSize(300,15)
     .setRange(-ROADWIDTH/2,ROADWIDTH/2)
     .setNumberOfTickMarks(6)
     .setSliderMode(Slider.FIX)
     ;      
  cp5.addSlider("sliderDriverPosX")
     .setPosition(280,60)
     .setSize(300,15)
     .setRange(-ROADWIDTH/2,ROADWIDTH/2)
     .setSliderMode(Slider.FLEXIBLE)
     ;
  cp5.addSlider("sliderDriverOffsetX")
     .setPosition(280,20)
     .setSize(300,15)
     .setRange(-CARWIDTH/2,CARWIDTH/2)
     .setSliderMode(Slider.FLEXIBLE)
     ;     

  obstacle = cp5.addSlider2D("obstacle")
         .setPosition(280,100)
         .setSize(300,600)
         .setArrayValue(new float[] {50, 50})
         ;

  // Draw View for Animations
  RadioButton animationGrid = cp5.addRadioButton("animationSelectedC1")
                 .setPosition(620,100)
                 .setSize(20,20)
                 .setItemsPerRow(5)
                 .setSpacingColumn(30)
                 .setSpacingRow(30);
  for (int j = 1; j < 6; j++) {
    animationGrid.addItem("l"+j,j);
  }

  // Draw View for Animations 2
  /*RadioButton animationGrid2 = cp5.addRadioButton("animationSelectedC2")
                 .setPosition(620,140)
                 .setSize(20,20)
                 .setItemsPerRow(5)
                 .setSpacingColumn(30)
                 .setSpacingRow(30);
  for (int j = 1; j < 6; j++) {
    animationGrid2.addItem("C2: l"+j,j);
  } */

  
  cp5.addTextlabel("labelTrigger")
                    .setText("Active Trigger: ")
                    .setPosition(620,160)
                    ;   

  addMouseWheelListener();
}

/**
*
* UI Events
*
**/

void controlEvent(ControlEvent theEvent) {

  if (theEvent.isGroup() && theEvent.getName() == "portList") {
    int portIndex = int(theEvent.getGroup().getValue());
    String portName = Serial.list()[portIndex];
    theSeat.connect(portName, this);
  }
}

//optimize by calling a standard method and which boundary via parameter

void plus(int value) {
  int intensity = int(motorKnob.getValue()) + 1;
  motorKnob.setValue(intensity);
}

void minus(int value) {
  int intensity = int(motorKnob.getValue()) - 1;
  motorKnob.setValue(intensity);
}

void setNeutral(int value) {
  int intensity = int(motorKnob.getValue());
  motors[selectedMotor].setNeutralIntensity(intensity);
  neutralLabel.setText("" + intensity);
  logString("Setting Neutral Intensity of motor " + selectedMotor + " to " + intensity);
}

void setAttack(int value) {
  int intensity = int(motorKnob.getValue());
  motors[selectedMotor].setAttackIntensity(intensity);
  attackLabel.setText("" + intensity);
  logString("Setting Attack Intensity of motor " + selectedMotor + " to " + intensity);
}

void setMax(int value) {
  int intensity = int(motorKnob.getValue());
  motors[selectedMotor].setMaxIntensity(intensity);
  maxLabel.setText("" + intensity);
  logString("Setting Max Intensity of motor " + selectedMotor + " to " + intensity);
}


void motorChange(int motorValue) {
  if (selectedMotor != -1) {
    motors[selectedMotor].setServoPulse(motorValue);
    logString("a knob event. setting motor to " + motorValue);
  }
}

void motorSelected(int m) {
  selectedMotor = m;
  motorKnob.setValue(motors[selectedMotor].getServoPulse());
  neutralLabel.setText("" + motors[selectedMotor].getNeutralIntensity());
  attackLabel.setText("" + motors[selectedMotor].getAttackIntensity());
  maxLabel.setText("" + motors[selectedMotor].getMaxIntensity());
  logString("Motor "+ m + " selected");
}

void neutral(int value) {
  for (int m = 0; m < motors.length; ++m) {
    logString("motor: "+ m + " neutral Intensity" + motors[m].getNeutralIntensity());
    motors[m].setServoPulse(motors[m].getNeutralIntensity());
    if (selectedMotor == m) motorKnob.setValue(motors[m].getNeutralIntensity());
  }
}
void attack(int value) {
  for (int m = 0; m < motors.length; ++m) {
    logString("motor: "+ m + " attack Intensity" + motors[m].getAttackIntensity());
    motors[m].setServoPulse(motors[m].getAttackIntensity());
    if (selectedMotor == m) motorKnob.setValue(motors[m].getAttackIntensity());
  }
}
void maxI(int value) {
  for (int m = 0; m < motors.length; ++m) {
    logString("motor: "+ m + " max Intensity" + motors[m].getMaxIntensity());
    motors[m].setServoPulse(motors[m].getMaxIntensity());
    if (selectedMotor == m) motorKnob.setValue(motors[m].getMaxIntensity());
  }
}

void export(int value) {
  String[] values = new String[SERVONUM];
  for (int m = 0; m < motors.length; ++m) {
    values[m] = "" + motors[m].getNeutralIntensity() + ","
                   + motors[m].getAttackIntensity() + ","
                   + motors[m].getMaxIntensity();
  }
  saveStrings("motorValues.txt", values);
}

void readObstacle(float[] o) {
  renderObstacle = boolean(int(o[0]));
  if (renderObstacle == false) neutral(0);
}

void readAnimation(float[] o) {
  renderAnimation = boolean(int(o[0]));
  if (renderAnimation == false) neutral(0);
}

void triggerAnimation(float[] o) {
  readTriggers = boolean(int(o[0]));
  if (readTriggers == false) neutral(0);
}

/*void sliderDriverOffsetX(float value) {
  //driverOffsetX = sliderDriverOffsetX.getValue();
  logString("Offset: "+ driverOffsetX);
}*/

void debugMode(float[] o) {
  debug = boolean(int(o[0]));
  if (debug == false) neutral(0);
}

void animationSelectedC1(int a)
{
  print ("Lane:" + a);
  //if(animation.isPlaying()) animation.end();
  aniToY = 5;
  aniY = 100;
  switch (a) {
    case 1 :
      aniX = 10;
    break;
    case 2 :
      aniX = 30; 
    break;
    case 3 :
      aniX = 50; 
    break;
    case 4 :
      aniX = 70; 
    break;
    case 5 :
      aniX = 90; 
    break;      
  }
  //animateObstacle = true;
  animation = new Ani(this, animationDuration, "aniY", aniToY, Ani.LINEAR, "onEnd:killAnimation"); 
  animation.start();
}

void animationSelectedC2(int a)
{
  print ("Lane:" + a);
  //if(animation.isPlaying()) animation.end();
  aniToY = 20;
  aniY = 100;
  switch (a) {
    case 1 :
      aniX = 10;
    break;
    case 2 :
      aniX = 30; 
    break;
    case 3 :
      aniX = 50; 
    break;
    case 4 :
      aniX = 70; 
    break;
    case 5 :
      aniX = 90; 
    break;      
  }
  //animateObstacle = true;
  animation = new Ani(this, animationDuration, "aniY", aniToY, Ani.LINEAR, "onEnd:killAnimation"); 
  animation.start();
}

void animationCondition2(String a)
{
  print ("Lane:" + a);
  //if(animation.isPlaying()) animation.end();
  aniToY = 20;
  aniY = 100;
  if (a.equals("trigger0"))
    aniX = 50;
  else if (a.equals("trigger1"))
    aniX = 10;
  else if (a.equals("trigger2"))
    aniX = 50;
  else if (a.equals("trigger3"))
    aniX = 90;
  else if (a.equals("trigger4"))
    aniX = 30;
  else if (a.equals("trigger5"))
    aniX = 90;
  else if (a.equals("trigger6"))
    aniX = 70;
  else if (a.equals("trigger7"))
    aniX = 50;
  else if (a.equals("trigger8"))
    aniX = 70;  
  else if (a.equals("trigger9"))
    aniX = 70;
  else if (a.equals("trigger10"))
    aniX = 50;
  else if (a.equals("trigger11"))
    aniX = 10;
  else if (a.equals("trigger12"))
    aniX = 10;
  else if (a.equals("trigger13"))
    aniX = 90;
  else if (a.equals("trigger14"))
    aniX = 90;
  else if (a.equals("trigger15"))     
    aniX = 10; 
  else  
    return;

  /*switch (a) {
    case 0 :
      aniX = 10;
    break;
    case 1 :
      aniX = 10;
    break;
    case 2 :
      aniX = 30; 
    break;
    case 3 :
      aniX = 50; 
    break;
    case 4 :
      aniX = 70; 
    break;
    case 5 :
      aniX = 90; 
    break;
    case 6 :
      aniX = 90; 
    break;
    case 7 :
      aniX = 90; 
    break;
    case 8 :
      aniX = 90; 
    break;
    case 9 :
      aniX = 90; 
    break;
    case 10 :
      aniX = 90; 
    break;
    case 11 :
      aniX = 90; 
    break;
    case 12 :
      aniX = 90; 
    break;
    case 13 :
      aniX = 90; 
    break;
    case 14 :
      aniX = 90; 
    break;
    case 15 :
      aniX = 90; 
    break;
  }*/
  //animateObstacle = true;

  animation = new Ani(this, animationDuration, "aniY", aniToY, Ani.LINEAR, "onEnd:killAnimation"); 
  animation.start();
}


void killAnimation(){
  animation = new Ani(this, 4,1, "aniY", 100, Ani.LINEAR); 
  animation.start();
}

// Add mouseWheel Support
void addMouseWheelListener() {
  frame.addMouseWheelListener(new java.awt.event.MouseWheelListener() {
    public void mouseWheelMoved(java.awt.event.MouseWheelEvent e) {
      cp5.setMouseWheelRotation(e.getWheelRotation());
    }
  }
  );
}

void logString(String msg){
  if(debug){
    println(msg);
  }
}

/*
a list of all methods available for the Button Controller
use ControlP5.printPublicMethodsFor(Button.class);
to print the following list into the console.

You can find further details about class Button in the javadoc.

Format:
ClassName : returnType methodName(parameter type)


controlP5.Button : Button activateBy(int)
controlP5.Button : Button setOff()
controlP5.Button : Button setOn()
controlP5.Button : Button setSwitch(boolean)
controlP5.Button : Button setValue(float)
controlP5.Button : Button update()
controlP5.Button : String getInfo()
controlP5.Button : String toString()
controlP5.Button : boolean getBooleanValue()
controlP5.Button : boolean isOn()
controlP5.Button : boolean isPressed()
controlP5.Controller : Button addCallback(CallbackListener)
controlP5.Controller : Button addListener(ControlListener)
controlP5.Controller : Button bringToFront()
controlP5.Controller : Button bringToFront(ControllerInterface)
controlP5.Controller : Button hide()
controlP5.Controller : Button linebreak()
controlP5.Controller : Button listen(boolean)
controlP5.Controller : Button lock()
controlP5.Controller : Button plugTo(Object)
controlP5.Controller : Button plugTo(Object, String)
controlP5.Controller : Button plugTo(Object[])
controlP5.Controller : Button plugTo(Object[], String)
controlP5.Controller : Button registerProperty(String)
controlP5.Controller : Button registerProperty(String, String)
controlP5.Controller : Button registerTooltip(String)
controlP5.Controller : Button removeBehavior()
controlP5.Controller : Button removeCallback()
controlP5.Controller : Button removeCallback(CallbackListener)
controlP5.Controller : Button removeListener(ControlListener)
controlP5.Controller : Button removeProperty(String)
controlP5.Controller : Button removeProperty(String, String)
controlP5.Controller : Button setArrayValue(float[])
controlP5.Controller : Button setArrayValue(int, float)
controlP5.Controller : Button setBehavior(ControlBehavior)
controlP5.Controller : Button setBroadcast(boolean)
controlP5.Controller : Button setCaptionLabel(String)
controlP5.Controller : Button setColor(CColor)
controlP5.Controller : Button setColorActive(int)
controlP5.Controller : Button setColorBackground(int)
controlP5.Controller : Button setColorCaptionLabel(int)
controlP5.Controller : Button setColorForeground(int)
controlP5.Controller : Button setColorValueLabel(int)
controlP5.Controller : Button setDecimalPrecision(int)
controlP5.Controller : Button setDefaultValue(float)
controlP5.Controller : Button setHeight(int)
controlP5.Controller : Button setId(int)
controlP5.Controller : Button setImages(PImage, PImage, PImage)
controlP5.Controller : Button setImages(PImage, PImage, PImage, PImage)
controlP5.Controller : Button setLabelVisible(boolean)
controlP5.Controller : Button setLock(boolean)
controlP5.Controller : Button setMax(float)
controlP5.Controller : Button setMin(float)
controlP5.Controller : Button setMouseOver(boolean)
controlP5.Controller : Button setMoveable(boolean)
controlP5.Controller : Button setPosition(PVector)
controlP5.Controller : Button setPosition(float, float)
controlP5.Controller : Button setSize(PImage)
controlP5.Controller : Button setSize(int, int)
controlP5.Controller : Button setStringValue(String)
controlP5.Controller : Button setUpdate(boolean)
controlP5.Controller : Button setValueLabel(String)
controlP5.Controller : Button setView(ControllerView)
controlP5.Controller : Button setVisible(boolean)
controlP5.Controller : Button setWidth(int)
controlP5.Controller : Button show()
controlP5.Controller : Button unlock()
controlP5.Controller : Button unplugFrom(Object)
controlP5.Controller : Button unplugFrom(Object[])
controlP5.Controller : Button unregisterTooltip()
controlP5.Controller : Button update()
controlP5.Controller : Button updateSize()
controlP5.Controller : CColor getColor()
controlP5.Controller : ControlBehavior getBehavior()
controlP5.Controller : ControlWindow getControlWindow()
controlP5.Controller : ControlWindow getWindow()
controlP5.Controller : ControllerProperty getProperty(String)
controlP5.Controller : ControllerProperty getProperty(String, String)
controlP5.Controller : Label getCaptionLabel()
controlP5.Controller : Label getValueLabel()
controlP5.Controller : List getControllerPlugList()
controlP5.Controller : PImage setImage(PImage)
controlP5.Controller : PImage setImage(PImage, int)
controlP5.Controller : PVector getAbsolutePosition()
controlP5.Controller : PVector getPosition()
controlP5.Controller : String getAddress()
controlP5.Controller : String getInfo()
controlP5.Controller : String getName()
controlP5.Controller : String getStringValue()
controlP5.Controller : String toString()
controlP5.Controller : Tab getTab()
controlP5.Controller : boolean isActive()
controlP5.Controller : boolean isBroadcast()
controlP5.Controller : boolean isInside()
controlP5.Controller : boolean isLabelVisible()
controlP5.Controller : boolean isListening()
controlP5.Controller : boolean isLock()
controlP5.Controller : boolean isMouseOver()
controlP5.Controller : boolean isMousePressed()
controlP5.Controller : boolean isMoveable()
controlP5.Controller : boolean isUpdate()
controlP5.Controller : boolean isVisible()
controlP5.Controller : float getArrayValue(int)
controlP5.Controller : float getDefaultValue()
controlP5.Controller : float getMax()
controlP5.Controller : float getMin()
controlP5.Controller : float getValue()
controlP5.Controller : float[] getArrayValue()
controlP5.Controller : int getDecimalPrecision()
controlP5.Controller : int getHeight()
controlP5.Controller : int getId()
controlP5.Controller : int getWidth()
controlP5.Controller : int listenerSize()
controlP5.Controller : void remove()
controlP5.Controller : void setView(ControllerView, int)


a list of all methods available for the RadioButton Controller
use ControlP5.printPublicMethodsFor(RadioButton.class);
to print the following list into the console.

You can find further details about class RadioButton in the javadoc.

Format:
ClassName : returnType methodName(parameter type)

controlP5.RadioButton : List getItems()
controlP5.RadioButton : RadioButton activate(String)
controlP5.RadioButton : RadioButton activate(int)
controlP5.RadioButton : RadioButton addItem(String, float)
controlP5.RadioButton : RadioButton addItem(Toggle, float)
controlP5.RadioButton : RadioButton deactivate(String)
controlP5.RadioButton : RadioButton deactivate(int)
controlP5.RadioButton : RadioButton deactivateAll()
controlP5.RadioButton : RadioButton hideLabels()
controlP5.RadioButton : RadioButton removeItem(String)
controlP5.RadioButton : RadioButton setArrayValue(float[])
controlP5.RadioButton : RadioButton setColorLabels(int)
controlP5.RadioButton : RadioButton setImage(PImage)
controlP5.RadioButton : RadioButton setImage(PImage, int)
controlP5.RadioButton : RadioButton setImages(PImage, PImage, PImage)
controlP5.RadioButton : RadioButton setItemHeight(int)
controlP5.RadioButton : RadioButton setItemWidth(int)
controlP5.RadioButton : RadioButton setItemsPerRow(int)
controlP5.RadioButton : RadioButton setNoneSelectedAllowed(boolean)
controlP5.RadioButton : RadioButton setSize(PImage)
controlP5.RadioButton : RadioButton setSize(int, int)
controlP5.RadioButton : RadioButton setSpacingColumn(int)
controlP5.RadioButton : RadioButton setSpacingRow(int)
controlP5.RadioButton : RadioButton showLabels()
controlP5.RadioButton : RadioButton toUpperCase(boolean)
controlP5.RadioButton : RadioButton toggle(int)
controlP5.RadioButton : String getInfo()
controlP5.RadioButton : Toggle getItem(int)
controlP5.RadioButton : boolean getState(String)
controlP5.RadioButton : boolean getState(int)
controlP5.RadioButton : void updateLayout()
controlP5.ControlGroup : RadioButton activateEvent(boolean)
controlP5.ControlGroup : RadioButton addListener(ControlListener)
controlP5.ControlGroup : RadioButton hideBar()
controlP5.ControlGroup : RadioButton removeListener(ControlListener)
controlP5.ControlGroup : RadioButton setBackgroundColor(int)
controlP5.ControlGroup : RadioButton setBackgroundHeight(int)
controlP5.ControlGroup : RadioButton setBarHeight(int)
controlP5.ControlGroup : RadioButton showBar()
controlP5.ControlGroup : RadioButton updateInternalEvents(PApplet)
controlP5.ControlGroup : String getInfo()
controlP5.ControlGroup : String toString()
controlP5.ControlGroup : boolean isBarVisible()
controlP5.ControlGroup : int getBackgroundHeight()
controlP5.ControlGroup : int getBarHeight()
controlP5.ControlGroup : int listenerSize()
controlP5.ControllerGroup : CColor getColor()
controlP5.ControllerGroup : ControlWindow getWindow()
controlP5.ControllerGroup : ControlWindowCanvas addCanvas(ControlWindowCanvas)
controlP5.ControllerGroup : Controller getController(String)
controlP5.ControllerGroup : ControllerProperty getProperty(String)
controlP5.ControllerGroup : ControllerProperty getProperty(String, String)
controlP5.ControllerGroup : Label getCaptionLabel()
controlP5.ControllerGroup : Label getValueLabel()
controlP5.ControllerGroup : PVector getPosition()
controlP5.ControllerGroup : RadioButton add(ControllerInterface)
controlP5.ControllerGroup : RadioButton bringToFront()
controlP5.ControllerGroup : RadioButton bringToFront(ControllerInterface)
controlP5.ControllerGroup : RadioButton close()
controlP5.ControllerGroup : RadioButton disableCollapse()
controlP5.ControllerGroup : RadioButton enableCollapse()
controlP5.ControllerGroup : RadioButton hide()
controlP5.ControllerGroup : RadioButton moveTo(ControlWindow)
controlP5.ControllerGroup : RadioButton moveTo(PApplet)
controlP5.ControllerGroup : RadioButton open()
controlP5.ControllerGroup : RadioButton registerProperty(String)
controlP5.ControllerGroup : RadioButton registerProperty(String, String)
controlP5.ControllerGroup : RadioButton remove(CDrawable)
controlP5.ControllerGroup : RadioButton remove(ControllerInterface)
controlP5.ControllerGroup : RadioButton removeCanvas(ControlWindowCanvas)
controlP5.ControllerGroup : RadioButton removeProperty(String)
controlP5.ControllerGroup : RadioButton removeProperty(String, String)
controlP5.ControllerGroup : RadioButton setAddress(String)
controlP5.ControllerGroup : RadioButton setArrayValue(float[])
controlP5.ControllerGroup : RadioButton setColor(CColor)
controlP5.ControllerGroup : RadioButton setColorActive(int)
controlP5.ControllerGroup : RadioButton setColorBackground(int)
controlP5.ControllerGroup : RadioButton setColorForeground(int)
controlP5.ControllerGroup : RadioButton setColorLabel(int)
controlP5.ControllerGroup : RadioButton setColorValue(int)
controlP5.ControllerGroup : RadioButton setHeight(int)
controlP5.ControllerGroup : RadioButton setId(int)
controlP5.ControllerGroup : RadioButton setLabel(String)
controlP5.ControllerGroup : RadioButton setMouseOver(boolean)
controlP5.ControllerGroup : RadioButton setMoveable(boolean)
controlP5.ControllerGroup : RadioButton setOpen(boolean)
controlP5.ControllerGroup : RadioButton setPosition(PVector)
controlP5.ControllerGroup : RadioButton setPosition(float, float)
controlP5.ControllerGroup : RadioButton setStringValue(String)
controlP5.ControllerGroup : RadioButton setUpdate(boolean)
controlP5.ControllerGroup : RadioButton setValue(float)
controlP5.ControllerGroup : RadioButton setVisible(boolean)
controlP5.ControllerGroup : RadioButton setWidth(int)
controlP5.ControllerGroup : RadioButton show()
controlP5.ControllerGroup : RadioButton update()
controlP5.ControllerGroup : RadioButton updateAbsolutePosition()
controlP5.ControllerGroup : String getAddress()
controlP5.ControllerGroup : String getInfo()
controlP5.ControllerGroup : String getName()
controlP5.ControllerGroup : String getStringValue()
controlP5.ControllerGroup : String toString()
controlP5.ControllerGroup : Tab getTab()
controlP5.ControllerGroup : boolean isCollapse()
controlP5.ControllerGroup : boolean isMouseOver()
controlP5.ControllerGroup : boolean isMoveable()
controlP5.ControllerGroup : boolean isOpen()
controlP5.ControllerGroup : boolean isUpdate()
controlP5.ControllerGroup : boolean isVisible()
controlP5.ControllerGroup : boolean setMousePressed(boolean)
controlP5.ControllerGroup : float getValue()
controlP5.ControllerGroup : float[] getArrayValue()
controlP5.ControllerGroup : int getHeight()
controlP5.ControllerGroup : int getId()
controlP5.ControllerGroup : int getWidth()
controlP5.ControllerGroup : void remove()

/*
a list of all methods available for the Knob Controller
use ControlP5.printPublicMethodsFor(Knob.class);
to print the following list into the console.

You can find further details about class Knob in the javadoc.

Format:
ClassName : returnType methodName(parameter type)

controlP5.Knob : Knob setConstrained(boolean)
controlP5.Knob : Knob setDragDirection(int)
controlP5.Knob : Knob setMax(float)
controlP5.Knob : Knob setMin(float)
controlP5.Knob : Knob setNumberOfTickMarks(int)
controlP5.Knob : Knob setRadius(float)
controlP5.Knob : Knob setRange(float)
controlP5.Knob : Knob setResolution(float)
controlP5.Knob : Knob setScrollSensitivity(float)
controlP5.Knob : Knob setSensitivity(float)
controlP5.Knob : Knob setShowRange(boolean)
controlP5.Knob : Knob setStartAngle(float)
controlP5.Knob : Knob setTickMarkLength(int)
controlP5.Knob : Knob setTickMarkWeight(float)
controlP5.Knob : Knob setValue(float)
controlP5.Knob : Knob setViewStyle(int)
controlP5.Knob : Knob showTickMarks(boolean)
controlP5.Knob : Knob shuffle()
controlP5.Knob : Knob snapToTickMarks(boolean)
controlP5.Knob : Knob update()
controlP5.Knob : boolean isConstrained()
controlP5.Knob : boolean isShowRange()
controlP5.Knob : boolean isShowTickMarks()
controlP5.Knob : float getAngle()
controlP5.Knob : float getRadius()
controlP5.Knob : float getRange()
controlP5.Knob : float getResolution()
controlP5.Knob : float getStartAngle()
controlP5.Knob : float getTickMarkWeight()
controlP5.Knob : float getValue()
controlP5.Knob : int getDragDirection()
controlP5.Knob : int getNumberOfTickMarks()
controlP5.Knob : int getTickMarkLength()
controlP5.Knob : int getViewStyle()
controlP5.Controller : CColor getColor()
controlP5.Controller : ControlBehavior getBehavior()
controlP5.Controller : ControlWindow getControlWindow()
controlP5.Controller : ControlWindow getWindow()
controlP5.Controller : ControllerProperty getProperty(String)
controlP5.Controller : ControllerProperty getProperty(String, String)
controlP5.Controller : Knob addCallback(CallbackListener)
controlP5.Controller : Knob addListener(ControlListener)
controlP5.Controller : Knob bringToFront()
controlP5.Controller : Knob bringToFront(ControllerInterface)
controlP5.Controller : Knob hide()
controlP5.Controller : Knob linebreak()
controlP5.Controller : Knob listen(boolean)
controlP5.Controller : Knob lock()
controlP5.Controller : Knob plugTo(Object)
controlP5.Controller : Knob plugTo(Object, String)
controlP5.Controller : Knob plugTo(Object[])
controlP5.Controller : Knob plugTo(Object[], String)
controlP5.Controller : Knob registerProperty(String)
controlP5.Controller : Knob registerProperty(String, String)
controlP5.Controller : Knob registerTooltip(String)
controlP5.Controller : Knob removeBehavior()
controlP5.Controller : Knob removeCallback()
controlP5.Controller : Knob removeCallback(CallbackListener)
controlP5.Controller : Knob removeListener(ControlListener)
controlP5.Controller : Knob removeProperty(String)
controlP5.Controller : Knob removeProperty(String, String)
controlP5.Controller : Knob setArrayValue(float[])
controlP5.Controller : Knob setArrayValue(int, float)
controlP5.Controller : Knob setBehavior(ControlBehavior)
controlP5.Controller : Knob setBroadcast(boolean)
controlP5.Controller : Knob setCaptionLabel(String)
controlP5.Controller : Knob setColor(CColor)
controlP5.Controller : Knob setColorActive(int)
controlP5.Controller : Knob setColorBackground(int)
controlP5.Controller : Knob setColorCaptionLabel(int)
controlP5.Controller : Knob setColorForeground(int)
controlP5.Controller : Knob setColorValueLabel(int)
controlP5.Controller : Knob setDecimalPrecision(int)
controlP5.Controller : Knob setDefaultValue(float)
controlP5.Controller : Knob setHeight(int)
controlP5.Controller : Knob setId(int)
controlP5.Controller : Knob setImages(PImage, PImage, PImage)
controlP5.Controller : Knob setImages(PImage, PImage, PImage, PImage)
controlP5.Controller : Knob setLabelVisible(boolean)
controlP5.Controller : Knob setLock(boolean)
controlP5.Controller : Knob setMax(float)
controlP5.Controller : Knob setMin(float)
controlP5.Controller : Knob setMouseOver(boolean)
controlP5.Controller : Knob setMoveable(boolean)
controlP5.Controller : Knob setPosition(PVector)
controlP5.Controller : Knob setPosition(float, float)
controlP5.Controller : Knob setSize(PImage)
controlP5.Controller : Knob setSize(int, int)
controlP5.Controller : Knob setStringValue(String)
controlP5.Controller : Knob setUpdate(boolean)
controlP5.Controller : Knob setValueLabel(String)
controlP5.Controller : Knob setView(ControllerView)
controlP5.Controller : Knob setVisible(boolean)
controlP5.Controller : Knob setWidth(int)
controlP5.Controller : Knob show()
controlP5.Controller : Knob unlock()
controlP5.Controller : Knob unplugFrom(Object)
controlP5.Controller : Knob unplugFrom(Object[])
controlP5.Controller : Knob unregisterTooltip()
controlP5.Controller : Knob update()
controlP5.Controller : Knob updateSize()
controlP5.Controller : Label getCaptionLabel()
controlP5.Controller : Label getValueLabel()
controlP5.Controller : List getControllerPlugList()
controlP5.Controller : PImage setImage(PImage)
controlP5.Controller : PImage setImage(PImage, int)
controlP5.Controller : PVector getAbsolutePosition()
controlP5.Controller : PVector getPosition()
controlP5.Controller : String getAddress()
controlP5.Controller : String getInfo()
controlP5.Controller : String getName()
controlP5.Controller : String getStringValue()
controlP5.Controller : String toString()
controlP5.Controller : Tab getTab()
controlP5.Controller : boolean isActive()
controlP5.Controller : boolean isBroadcast()
controlP5.Controller : boolean isInside()
controlP5.Controller : boolean isLabelVisible()
controlP5.Controller : boolean isListening()
controlP5.Controller : boolean isLock()
controlP5.Controller : boolean isMouseOver()
controlP5.Controller : boolean isMousePressed()
controlP5.Controller : boolean isMoveable()
controlP5.Controller : boolean isUpdate()
controlP5.Controller : boolean isVisible()
controlP5.Controller : float getArrayValue(int)
controlP5.Controller : float getDefaultValue()
controlP5.Controller : float getMax()
controlP5.Controller : float getMin()
controlP5.Controller : float getValue()
controlP5.Controller : float[] getArrayValue()
controlP5.Controller : int getDecimalPrecision()
controlP5.Controller : int getHeight()
controlP5.Controller : int getId()
controlP5.Controller : int getWidth()
controlP5.Controller : int listenerSize()
controlP5.Controller : void remove()
controlP5.Controller : void setView(ControllerView, int)

 a list of all methods available for the DropdownList Controller
 use ControlP5.printPublicMethodsFor(DropdownList.class);
 to print the following list into the console.

 You can find further details about DropdownList in the javadoc.

 Format: returnType methodName(parameterType)

 controlP5.DropdownList : ControllerGroup setValue(float)
 controlP5.DropdownList : float getValue()
 controlP5.ListBox : ControllerInterface setColorActive(int)
 controlP5.ListBox : ControllerInterface setColorBackground(int)
 controlP5.ListBox : ControllerInterface setColorForeground(int)
 controlP5.ListBox : ControllerInterface setColorLabel(int)
 controlP5.ListBox : ControllerInterface setColorValue(int)
 controlP5.ListBox : ListBox setHeight(int)
 controlP5.ListBox : ListBox setWidth(int)
 controlP5.ListBox : ListBox toUpperCase(boolean)
 controlP5.ListBox : ListBoxItem addItem(String, int)
 controlP5.ListBox : ListBoxItem item(Controller)
 controlP5.ListBox : ListBoxItem item(String)
 controlP5.ListBox : ListBoxItem item(int)
 controlP5.ListBox : String[][] getListBoxItems()
 controlP5.ListBox : boolean isScrollbarVisible()
 controlP5.ListBox : float getScrollPosition()
 controlP5.ListBox : void actAsPulldownMenu(boolean)
 controlP5.ListBox : void addItems(List)
 controlP5.ListBox : void addItems(List, int)
 controlP5.ListBox : void addItems(String[])
 controlP5.ListBox : void clear()
 controlP5.ListBox : void controlEvent(ControlEvent)
 controlP5.ListBox : void hideScrollbar()
 controlP5.ListBox : void keyEvent(KeyEvent)
 controlP5.ListBox : void removeItem(String)
 controlP5.ListBox : void scroll(float)
 controlP5.ListBox : void scrolled(int)
 controlP5.ListBox : void setItemHeight(int)
 controlP5.ListBox : void setListBoxItems(String[][])
 controlP5.ListBox : void showScrollbar()
 controlP5.ListBox : void updateListBoxItems()
 controlP5.ControlGroup : ControlGroup activateEvent(boolean)
 controlP5.ControlGroup : String info()
 controlP5.ControlGroup : String stringValue()
 controlP5.ControlGroup : String toString()
 controlP5.ControlGroup : boolean isBarVisible()
 controlP5.ControlGroup : int getBackgroundHeight()
 controlP5.ControlGroup : int getBarHeight()
 controlP5.ControlGroup : int listenerSize()
 controlP5.ControlGroup : void addCloseButton()
 controlP5.ControlGroup : void addListener(ControlListener)
 controlP5.ControlGroup : void controlEvent(ControlEvent)
 controlP5.ControlGroup : void hideBar()
 controlP5.ControlGroup : void mousePressed()
 controlP5.ControlGroup : void removeCloseButton()
 controlP5.ControlGroup : void removeListener(ControlListener)
 controlP5.ControlGroup : void setBackgroundColor(int)
 controlP5.ControlGroup : void setBackgroundHeight(int)
 controlP5.ControlGroup : void setBarHeight(int)
 controlP5.ControlGroup : void showBar()
 controlP5.ControllerGroup : CColor getColor()
 controlP5.ControllerGroup : ControlWindow getWindow()
 controlP5.ControllerGroup : ControlWindowCanvas addCanvas(ControlWindowCanvas)
 controlP5.ControllerGroup : Controller getController(String)
 controlP5.ControllerGroup : ControllerGroup setHeight(int)
 controlP5.ControllerGroup : ControllerGroup setValue(float)
 controlP5.ControllerGroup : ControllerGroup setWidth(int)
 controlP5.ControllerGroup : ControllerInterface add(ControllerInterface)
 controlP5.ControllerGroup : ControllerInterface hide()
 controlP5.ControllerGroup : ControllerInterface moveTo(ControlGroup, Tab, ControlWindow)
 controlP5.ControllerGroup : ControllerInterface registerProperty(String)
 controlP5.ControllerGroup : ControllerInterface registerProperty(String, String)
 controlP5.ControllerGroup : ControllerInterface remove(ControllerInterface)
 controlP5.ControllerGroup : ControllerInterface removeProperty(String)
 controlP5.ControllerGroup : ControllerInterface removeProperty(String, String)
 controlP5.ControllerGroup : ControllerInterface setColor(CColor)
 controlP5.ControllerGroup : ControllerInterface setColorActive(int)
 controlP5.ControllerGroup : ControllerInterface setColorBackground(int)
 controlP5.ControllerGroup : ControllerInterface setColorForeground(int)
 controlP5.ControllerGroup : ControllerInterface setColorLabel(int)
 controlP5.ControllerGroup : ControllerInterface setColorValue(int)
 controlP5.ControllerGroup : ControllerInterface setId(int)
 controlP5.ControllerGroup : ControllerInterface setLabel(String)
 controlP5.ControllerGroup : ControllerInterface show()
 controlP5.ControllerGroup : ControllerProperty getProperty(String)
 controlP5.ControllerGroup : ControllerProperty getProperty(String, String)
 controlP5.ControllerGroup : Label captionLabel()
 controlP5.ControllerGroup : Label valueLabel()
 controlP5.ControllerGroup : PVector getAbsolutePosition()
 controlP5.ControllerGroup : PVector getPosition()
 controlP5.ControllerGroup : String getName()
 controlP5.ControllerGroup : String getStringValue()
 controlP5.ControllerGroup : String info()
 controlP5.ControllerGroup : String toString()
 controlP5.ControllerGroup : Tab getTab()
 controlP5.ControllerGroup : boolean isCollapse()
 controlP5.ControllerGroup : boolean isMoveable()
 controlP5.ControllerGroup : boolean isOpen()
 controlP5.ControllerGroup : boolean isUpdate()
 controlP5.ControllerGroup : boolean isVisible()
 controlP5.ControllerGroup : boolean setMousePressed(boolean)
 controlP5.ControllerGroup : float getValue()
 controlP5.ControllerGroup : float[] getArrayValue()
 controlP5.ControllerGroup : int getHeight()
 controlP5.ControllerGroup : int getId()
 controlP5.ControllerGroup : int getWidth()
 controlP5.ControllerGroup : void close()
 controlP5.ControllerGroup : void disableCollapse()
 controlP5.ControllerGroup : void enableCollapse()
 controlP5.ControllerGroup : void moveTo(ControlGroup)
 controlP5.ControllerGroup : void moveTo(ControlWindow)
 controlP5.ControllerGroup : void moveTo(ControlWindow, String)
 controlP5.ControllerGroup : void moveTo(String)
 controlP5.ControllerGroup : void moveTo(String, ControlWindow)
 controlP5.ControllerGroup : void moveTo(Tab)
 controlP5.ControllerGroup : void moveTo(Tab, ControlWindow)
 controlP5.ControllerGroup : void open()
 controlP5.ControllerGroup : void remove()
 controlP5.ControllerGroup : void remove(CDrawable)
 controlP5.ControllerGroup : void removeCanvas(ControlWindowCanvas)
 controlP5.ControllerGroup : void setAbsolutePosition(PVector)
 controlP5.ControllerGroup : void setArrayValue(float[])
 controlP5.ControllerGroup : void setGroup(ControllerGroup)
 controlP5.ControllerGroup : void setGroup(String)
 controlP5.ControllerGroup : void setMoveable(boolean)
 controlP5.ControllerGroup : void setOpen(boolean)
 controlP5.ControllerGroup : void setPosition(PVector)
 controlP5.ControllerGroup : void setPosition(float, float)
 controlP5.ControllerGroup : void setTab(ControlWindow, String)
 controlP5.ControllerGroup : void setTab(String)
 controlP5.ControllerGroup : void setTab(Tab)
 controlP5.ControllerGroup : void setUpdate(boolean)
 controlP5.ControllerGroup : void setVisible(boolean)
 controlP5.ControllerGroup : void update()
 controlP5.ControllerGroup : void updateAbsolutePosition()
 java.lang.Object : String toString()
 java.lang.Object : boolean equals(Object)
 */
