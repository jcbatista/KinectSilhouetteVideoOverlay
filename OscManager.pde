import oscP5.*;

class OscConfigData {
  boolean enabled = false;
  String name = "";
  int serverPort = 13000;
  String clientAddress = "127.0.0.1";
  int clientPort = 12000;
  boolean sendCached = false; // if true, allow sending cached clip data using OSC
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
    
    sendCached = data.sendCached;
  }
  
  /**  
   * send: broadcast scene information over OSC
   *
   * @param clipIndex: index of the clip that's currently playing
   * @param totalUsers: total users currently tracked in the scene
   * @param userIndex: the user we're sending coordinates for
   * @param position: x,y,z coordinates of the user identified by userIndex 
   * @param actionClipIndex: index of the Action Clip currently playing
   * @param displayMode: { 0 <= Live Kinect, 1 <= Cached Silhouette }
   */
  void send(int clipIndex, int totalUsers, int userIndex, PVector position, int actionClipIndex, int displayMode) {
    if(!enabled)
      return;
      
    if(!sendCached && displayMode==1)
      return;
    
    OscMessage msg = new OscMessage("/" + name);
    msg.add(clipIndex);
    msg.add(totalUsers);
    msg.add(userIndex);
    msg.add(position.x);
    msg.add(position.y);
    msg.add(position.z);
    msg.add(actionClipIndex);
    msg.add(displayMode);
    oscP5.send(msg, myRemoteLocation); 
  }
  
  private OscP5 oscP5;
  private boolean enabled = false;
  private String name; // installation identifier
  private boolean sendCached = false;
}

