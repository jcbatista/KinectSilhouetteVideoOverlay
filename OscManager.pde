import oscP5.*;

class OscConfigData {
  boolean enabled = false;
  String name = "";
  int serverPort = 13000;
  String clientAddress = "127.0.0.1";
  int clientPort = 12000;
  int availableChannels = 4;
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
    
    messagePrefix = "/" + name + "/";
    availableChannels = data.availableChannels;
  }
  
  /**  
   * send: broadcast scene information over OSC
   *
   * @param clipIndex: index of the clip that's currently playing
   * @param totalUsers: total users currently tracked in the scene

   * @param actionClipIndex: index of the Action Clip currently playing
   * @param displayMode: { 1 <= Live Kinect, 0 <= Cached Silhouette }
   */
  void send(int clipIndex, int totalUsers, int actionClipIndex, int displayMode) {
    if(!enabled)
      return;

    // clip index
    OscMessage clipIndexMsg = new OscMessage(messagePrefix + "clip_index");
    clipIndexMsg.add(clipIndex);
    oscP5.send(clipIndexMsg, myRemoteLocation); 
    
    // total users
    OscMessage totalUserMsg = new OscMessage(messagePrefix + "total_users");
    totalUserMsg.add(totalUsers);
    oscP5.send(totalUserMsg, myRemoteLocation); 
    
    // action clip
    OscMessage actionClipMsg = new OscMessage(messagePrefix + "action_clip");
    actionClipMsg.add(actionClipIndex);
    oscP5.send(actionClipMsg, myRemoteLocation); 
    
    // display mode
    OscMessage displayModeMsg = new OscMessage(messagePrefix + "display_mode");
    displayModeMsg.add(displayMode);
    oscP5.send(displayModeMsg, myRemoteLocation); 
  }
  
  /*
   * @param userIndex: the user we're sending coordinates for
   * @param position: x,y,z coordinates of the user identified by userIndex 
   */
  void sendUserIndex(int userIndex, PVector position) {
     if(!enabled)
      return; 
      
    // user index
    OscMessage userIndexMsg = new OscMessage(messagePrefix + "user_index/" + adjustIndexForAvailableChannels(userIndex));
    userIndexMsg.add(position.x);
    userIndexMsg.add(position.y);
    userIndexMsg.add(position.z);
    oscP5.send(userIndexMsg, myRemoteLocation); 
  }
  
  void sendNewUserIndex(int userIndex)
  {
    if(!enabled)
      return; 
      
    OscMessage newUserIndexMsg = new OscMessage(messagePrefix + "newuser_index");
    newUserIndexMsg.add(adjustIndexForAvailableChannels(userIndex));  
    oscP5.send(newUserIndexMsg, myRemoteLocation); 
  }
  
  void sendLostUserIndex(int userIndex)
  {
    if(!enabled)
      return; 
      
    OscMessage lostUserIndexMsg = new OscMessage(messagePrefix + "lostuser_index");
    lostUserIndexMsg.add(adjustIndexForAvailableChannels(userIndex)); 
    oscP5.send(lostUserIndexMsg, myRemoteLocation);
  }
  
  void sendFocusedUserIndex(int userIndex)
  {
    if(!enabled)
      return;    
    
    // prevent identical sequencial "focuseduser_index" message from being sent for the same user.
    if(userIndex == previousFocusedUserIndex)
    {
      println("***** sendFocusedUserIndex() called with the same user index as before. Index=" + userIndex);
      return;
    } else {
      println("++++ sendFocusedUserIndex(). Sending adjusted user index=" + adjustIndexForAvailableChannels(userIndex));
    }
    
    previousFocusedUserIndex = userIndex;  
    OscMessage focusedUserIndexMsg = new OscMessage(messagePrefix + "focuseduser_index");
    focusedUserIndexMsg.add(adjustIndexForAvailableChannels(userIndex)); 
    oscP5.send(focusedUserIndexMsg, myRemoteLocation);
  }
  
  /**  
   * ajustIndexForAvailableChanels
   *
   * The OSC client has a limit number of sound channels, 
   * the user index needs to be within that range.
   *
   * @param userIndex: index to ajust
   */
  private int adjustIndexForAvailableChannels(int userIndex) {
    return ((userIndex-1) % availableChannels) + 1;
  }
  
  private int previousFocusedUserIndex = -1;
  private OscP5 oscP5;
  private boolean enabled = false;
  private String name; // installation identifier
  private String messagePrefix;
  private int availableChannels;
  private NetAddress myRemoteLocation;  
}

