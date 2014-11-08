class Timeline {  
  Timeline() {
    // TODO: needs to be set to the length of the sequence
    duration = 10 * 60; // 10 minutes // 60 * 60; // one hour (in seconds)
    reset();
  }
     
  int getEllapsedTime() {
    double elapseTime = System.nanoTime() - runStartTime;
    double seconds = (double)elapseTime / 1000000000d; 
    return (int)seconds;
  }
  
  void tick() {
    timeChanged = false;
    currentTime = getEllapsedTime();    
    if(currentTime != previousTime) {
      timeChanged = true;
      previousTime = currentTime;
    }    
    if(currentTime > duration) {
      reset();
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
  
  private void reset() {
    runStartTime = System.nanoTime();
    currentTime = 0;
    previousTime = 0;
    timeChanged = true;
  }
  
  private boolean timeChanged = false;
  private int duration = 0;
  private int currentTime = 0;
  private int previousTime = 0;
  private double runStartTime = 0;     
}
