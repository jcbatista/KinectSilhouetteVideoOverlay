import oscP5.*;

class OscConfigData {
  boolean enabled = false;
  int serverPort = 1300
  String clientAddress = "127.0.0.1";
  int clientPort = 12000;
}

class OscManager {

  OscManager(OscConfigData data) {
    enabled = data.enabled;
    if(!enabled) 
      return;
    //start oscP5, listening for incoming messages at port 7000
    oscP5 = new OscP5(this, data.serverPort, OscP5.UDP);
    myRemoteLocation = new NetAddress(data.clientAddress, data.clientPort);
  }
  
  // TODO also send the index of the clip that's currently playing...
  void send(PVector position) {
    if(!enabled)
      return;
    
    // TODO need to add another field to identify the user ...
    // and one to identify which Kinect we're using
    OscMessage msg = new OscMessage("/pos");
    msg.add(position.x);
    msg.add(position.y);
    msg.add(position.z);
    oscP5.send(msg, myRemoteLocation); 
  }
  
  private OscP5 oscP5;
  private boolean enabled = false;
}

