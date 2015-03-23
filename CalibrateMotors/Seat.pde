import processing.serial.*;

static public final class Seat {
  private static final char HEADER = 'M';
  private Serial arduinoPort;
  private Boolean connected = false;
  private Boolean changed = false;
  private ServoMotor[] motors = new ServoMotor[SERVONUM];

  private Seat() {
    super();
  }
  private static Seat INSTANCE;

  public static Seat getInstance() {
    if (INSTANCE == null) {
      INSTANCE = new Seat();
    }
    return INSTANCE;
  }

  public void connect(String portName, PApplet parent) {
    arduinoPort = new Serial(parent, portName, 57600);
    connected = true;
  }

  public Boolean isConnected() {
    return connected;
  }

  public void registerMotors(ServoMotor[] tmpmotors) {
    motors = tmpmotors;
  }

  public void registerChange() {
    changed = true;
  }

  public void process() {
    if (connected) {
      while (arduinoPort.available() > 0)
      {
        String msg = arduinoPort.readStringUntil('\n');
        if (msg != null) {
          println("Serial: " + msg);
        }
      }

      if (changed) {
        arduinoPort.write(HEADER);
        for (int i = 0; i < motors.length; ++i) {
          int value = motors[i].getServoPulse();
          arduinoPort.write((char)(value / 256));
          arduinoPort.write((char)(value & 0xff));
        }
        changed = false;
      }
    }
  }

  //send data to Arduino
  public void changeMotor(int motorId, int motorValue) {
    arduinoPort.write("kSSI," + motorId + "," + motorValue + ";");
  }
}