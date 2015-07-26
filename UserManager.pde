import java.util.LinkedList;

class UserManager {
  private LinkedList users;

  public UserManager() {
    users = new LinkedList<Integer>();
  }
  
  public void add(int userId) {
    if(users.indexOf(userId)==-1) {
      users.addLast(userId);
    }
  }
  
  public void remove(int userId) {
     int index = users.indexOf(userId);
     if(users.indexOf(userId)!=-1) {
      users.remove(userId);      
    }
  } 
  
  public int getFocusedUser()
  {
    if(users.size()==0) {
      return -1;
    }
    return (Integer) users.peekLast();
  }
}

