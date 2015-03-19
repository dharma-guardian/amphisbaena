import processing.serial.*;

static class Seat {
  private Serial arduinoPort;
  private Boolean connected = false;

  private Seat() {
    super();
  }

  private static class SingletonHolder {
     private static final Seat INSTANCE = new Seat();
  }

  public static Seat getInstance() {
    return SingletonHolder.INSTANCE;
  }

  public void connect(String portName) {
    // arduinoPort = new Serial(this, portName, 115200);
    connected = true;
  }

  public void changeMotor(int motorId, int motorValue) {
    arduinoPort.write(motorId);
    arduinoPort.write(motorValue);
  }
}