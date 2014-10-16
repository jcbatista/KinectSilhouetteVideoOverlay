class ActionSettings
{
  // TODO actions need to send OSC information
  ActionSettings() {
    clips = new StringList();
  }
  StringList clips;
  int frequency;
}

class ActionManager {
  
  ActionManager(ActionSettings settings) {
    frequency = settings.frequency;
    runLengthPeriod = 60 * 60; // one hour (in seconds)
    period = runLengthPeriod / frequency;
    reset();
    
    if(shouldPlay()) {
      initClips(settings.clips);
      listActionClips();
    }
    
  }
 
  void reset() {
     runStartTime = System.nanoTime();
     currentTime = 0;
     previousTime = 0;
  }
  
  void initClips(StringList clipFiles) {
    clips = new LinkedList<Clip>();
    for (String clipFile : clipFiles) {
      ClipInfo clipInfo = new ClipInfo();
      clipInfo.backgroundFilename = clipFile;
      Clip clip = new Clip(clipInfo);
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
        println("action clip = "+ clip.clipInfo.backgroundFilename + " ");
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
