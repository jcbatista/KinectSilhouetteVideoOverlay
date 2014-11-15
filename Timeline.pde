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
  
  /*
   * set the duration is milliseconds
   */
  void setDuration(int duration) {
    this.duration = duration;
  }
          
  void tick() {
    timeChanged = false;
    currentTime = getEllapsedTime(); 
    currentTimeSlice = (int)((double)currentTime / granularity);

    if(currentTimeSlice != previousTimeSlice) {
      previousTimeSlice = currentTimeSlice;
      timeChanged = true;      
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
  
  int getCurrentTimeInSec() {
    return int(currentTime/1000);
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
    currentTimeSlice = 0;
    previousTimeSlice = 0;
    timeChanged = true;
  }
  
  void setGranularity(int value) {
    this.granularity = value;
  }
  
  private int getEllapsedTime() {
    double elapseTime = System.nanoTime() - runStartTime;
    double ms = (double)elapseTime / 1000000d; //1000000000d;     
    return (int)ms;
  }
   
  protected double granularity = 1;
  protected boolean timeChanged = false;
  protected int duration = -1;
  protected int currentTimeSlice = 0;
  protected int previousTimeSlice = -1; 
  protected int currentTime = 0;
  protected double runStartTime = 0;     
}
