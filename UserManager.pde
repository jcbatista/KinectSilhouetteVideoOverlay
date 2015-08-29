import java.util.Deque;
import java.util.Map;
import java.util.HashMap;

class UserManager {
  private Map<Integer, PVector> userPositionMap;
  private SimpleOpenNI kinect;
  private UserManager userManager;
  private LinkedList orderedUsers;   
  private IntVector userList; // obtained from the kinect   

  public UserManager(SimpleOpenNI kinect) {
    this.kinect = kinect;
    userPositionMap = new HashMap<Integer, PVector>();
    // list of people in the scene
    userList = new IntVector();
    orderedUsers = new LinkedList<Integer>();
  }
  
  public void add(int userId) {
    if(orderedUsers.indexOf(userId)==-1) {
      orderedUsers.addLast(userId);
    }
  }
  
  public void remove(int userId) {
     int userIndex = orderedUsers.indexOf(userId);
     if(orderedUsers.indexOf(userId)!=-1) {
      orderedUsers.remove(userIndex);      
    }
  } 
  
  private boolean isPositionValid(PVector position) {

   if(Float.isNaN(position.x) || Float.isNaN(position.y) || Float.isNaN(position.z))
     return false;
     
   if(position.x==0 && position.y==0 && position.z==0)
     return false;

   return true; 
  }
  
  /*
   * Return the last user who entered the scene who has valid coordinates
   */
  public int getFocusedUser()
  {
    if(orderedUsers.size()==0) {
      return -1;
    }
    
    int nbUsers = (Integer) orderedUsers.size();
    int lastIndex = nbUsers - 1;
    int focusedUser = -1;
    for(int i=lastIndex; i>=0; i--) {
      int userId = (Integer) orderedUsers.get(i);
      if(userPositionMap.containsKey(userId)) {
        PVector position = userPositionMap.get(userId);        
        focusedUser = userId;
        break;
      }
    }
    return focusedUser;    
  }
  
  /*
   * Retrieves the user list from the Kinect
   */
  public IntVector getUsers() {
     kinect.getUsers(userList);
     return userList;
  }
  
  String dumpOrderUserList() {
    StringBuilder sb = new StringBuilder();
    sb.append("Users:(");
    boolean isFirst = true;
    for(Object user: orderedUsers) {
      if(!isFirst) {
        sb.append(",");
      } else {      
        isFirst = false;
      }  
      sb.append(user);      
    }
    sb.append(")");
    return sb.toString();
  }
  
  String dumpUserMapKeys() {
    StringBuilder sb = new StringBuilder();
    sb.append("Map:(");
    boolean isFirst = true;
    for(int userId: userPositionMap.keySet()) {
      if(!isFirst) {
        sb.append(",");
      } else {      
        isFirst = false;
      }
      sb.append(userId);      
    }
    sb.append(")");
    return sb.toString();
  }
  
  public Map<Integer, PVector> getUserPositions()
  {
    updateUserPositionMap();
    return userPositionMap;
  }
  
  public void updateUserPositionMap() {
    userPositionMap.clear();
    IntVector userList = getUsers();
    int nbUsers = (int) userList.size();    
    for(int i=0; i<nbUsers; i++) {
      int userId = userList.get(i);
      PVector position = new PVector();
      kinect.getCoM(userId, position); // CoM <= Center Of Mass
      kinect.convertRealWorldToProjective(position, position);
      if(isPositionValid(position)) {
        userPositionMap.put(userId, position);
      }     
    }
  }
    
  public int countActiveUsers() {
    return userPositionMap.size();
  }
  
}

