import processing.serial.*;

static public final class Seat {
  private static final char HEADER = 'M';
  private static final int SENDDELAY = 50;
  private PApplet parent;
  private Serial arduinoPort;
  private Boolean connected = false;
  private Boolean changed = false;
  private ServoMotor[] motors = new ServoMotor[SERVONUM];
  private int lastSend;

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

  public void connect(String portName, PApplet tmpparent) {
    parent = tmpparent;
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
      // while (arduinoPort.available() > 0)
      // {
      //   String msg = arduinoPort.readStringUntil('\n');
      //   if (msg != null) {
      //     print("Serial: " + msg);
      //   }
      // }

      int t = parent.millis();
      if (changed && (t - lastSend) > SENDDELAY) {
        arduinoPort.write(HEADER);
        for (int i = 0; i < motors.length; ++i) {
          int value = motors[i].getServoPulse();
          arduinoPort.write((char)(value / 256));
          arduinoPort.write((char)(value & 0xff));
        }
        changed = false;
        lastSend = t;
      }
    }
  }
}