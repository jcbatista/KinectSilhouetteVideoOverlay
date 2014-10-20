import oscP5.*;

class OscConfigData {
  boolean enabled = false;
  String name = "";
  int serverPort = 13000;
  String clientAddress = "127.0.0.1";
  int clientPort = 12000;
}

class OscManager {

  OscManager(OscConfigData data) {
    enabled = data.enabled;
    if(!enabled) 
      return;
      
    name = data.name;
    //start oscP5, listening for incoming messages at port 7000
    oscP5 = new OscP5(this, data.serverPort, OscP5.UDP);
    myRemoteLocation = new NetAddress(data.clientAddress, data.clientPort);
  }
  
  // action: start => 1, stop => 0
  void sendActionClip(int clipIndex, int action) {
    // TODO implement
  }
  
  void send(int clipIndex, int totalUsers, int userIndex, PVector position) {
    if(!enabled)
      return;
    
    OscMessage msg = new OscMessage("/" + name);
    msg.add(clipIndex);
    msg.add(totalUsers);
    msg.add(userIndex);
    msg.add(position.x);
    msg.add(position.y);
    msg.add(position.z);
    oscP5.send(msg, myRemoteLocation); 
  }
  
  private OscP5 oscP5;
  private boolean enabled = false;
  private String name; // installation identifier
}

