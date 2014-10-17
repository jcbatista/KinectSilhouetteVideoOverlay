class ActionSettings {
  // TODO actions need to send OSC information
  ActionSettings() {
    clips = new StringList();
    durations = new IntList(); // note: clips and durations index must match
  }
  StringList clips;
  IntList durations;
  int frequency;
}

class ActionManager {
  
  ActionManager(ActionSettings settings) {
    frequency = settings.frequency;
    runLengthPeriod = 60 * 60; // one hour (in seconds)
    period = runLengthPeriod / frequency;
    reset();
    
    if(shouldPlay()) {
      initClips(settings);
      listActionClips();
    }
    
  }
 
  void reset() {
     runStartTime = System.nanoTime();
     currentTime = 0;
     previousTime = 0;
  }
  
  void initClips(ActionSettings settings) {
    clips = new LinkedList<Clip>();
    for (int i=0; i < settings.clips.size(); i++) { 
      ClipInfo clipInfo = new ClipInfo();
      clipInfo.backgroundFilename = settings.clips.get(i);
      Clip clip = new Clip(clipInfo);
      clip.duration = settings.durations.get(i); 
      clips.add(clip);
    }
    
    // TODO REMOVE THIS
    clips.get(0).movie.loop();
  }
  
  void listActionClips() {
    println("*** Listing defined action clips ***");
    int count = 1;
    for (Clip clip : clips) {
      print(count + ".");
      if(clip.clipInfo.backgroundFilename!=null) {
        println("action clip = "+ clip.clipInfo.backgroundFilename + " duration:" + clip.duration);
      }
      count++;
    }
    println("*** Done. ***");
  }
  
  boolean shouldPlay() {
    return frequency!=0;
  }
  
  int getEllapsedTime() {
    double elapseTime = System.nanoTime() - runStartTime;
    double seconds = (double)elapseTime / 1000000000d; 
    return (int)seconds;
  }
  
  void tick()
  {
    // if shouldPlay() ...
    currentTime = getEllapsedTime();
    if(currentTime != previousTime) {
      previousTime = currentTime;
      // time changed!
      // TODO IMPLEMENT SCHEDULING HERE ...
    }
  }
  
  Clip getCurrent() {
    return clips.get(0);
  }
  
  
  private int currentTime = 0;
  private int previousTime = 0;
  
  private double runStartTime = 0;
  private int runLengthPeriod = 0; // an hour period
  private int period = 0;
  private int frequency = 0;
  private LinkedList<Clip> clips;
}
