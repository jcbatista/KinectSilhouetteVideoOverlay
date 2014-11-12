class CyclicalTimeline extends Timeline {
  void tick(){
    super.tick();
    if(currentTime > duration) {
      reset();
    }  
  }
  
  void setDuration(int duration) {        
    super.setDuration(duration);
    println("main timeline duration set to " + duration);
  }
  
}  

class Timeline {  
  Timeline() {
    duration = -1; 
  }
  
  void start() {
    reset();    
  }
  
  void setDuration(int duration) {
    this.duration = duration;
  }
     
  void tick() {
    timeChanged = false;
    currentTime = getEllapsedTime();    
    if(currentTime != previousTime) {
      timeChanged = true;
      previousTime = currentTime;
    }           
  }
  
  boolean hasTimeChanged() {
    return timeChanged;
  }
  
  int getDuration() {
    return duration;
  }
  
  int getCurrentTime() {
    return currentTime;
  }
  
  boolean hasCompleted() {  
    if(duration==-1) {
      return false;
    }  
    return currentTime > duration;    
  }
  
  void reset() {
    runStartTime = System.nanoTime();
    currentTime = 0;
    previousTime = 0;
    timeChanged = true;
  }
  
  private int getEllapsedTime() {
    
    if(duration==-1) {
      return 0;
    }
    
    double elapseTime = System.nanoTime() - runStartTime;
    double seconds = (double)elapseTime / 1000000000d; 
    return (int)seconds;
  }
    
  protected boolean timeChanged = false;
  protected int duration = 0;
  protected int currentTime = 0;
  protected int previousTime = 0;
  protected double runStartTime = 0;     
}
