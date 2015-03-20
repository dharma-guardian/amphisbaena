import processing.serial.*;

static public final class Seat {
  private Serial arduinoPort;
  private Boolean connected = false;

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

  //send data to Arduino
  public void changeMotor(int motorId, int motorValue) {
    arduinoPort.write("kSetMotorIntensity," + motorId + "," + motorValue + ";");
  }
}