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

public class IntPair { 
   int first; 
   int second; 
   IntPair(int fisrt, int second) { 
   this.first = first; 
   this.second = second; 
  } 
} 

class ActionManager {
  
  ActionManager(ActionSettings settings) {
    clips = new LinkedList<Clip>();
    scheduledClips = new LinkedList<IntPair>();
    frequency = settings.frequency;
    runLengthPeriod = 10 * 60; // 10 minutes //60 * 60; // one hour (in seconds)
    period = runLengthPeriod / frequency;
    if(shouldPlay()) {
      initClips(settings);
      listActionClips();
    }
    reset();
  }
 
  void reset() {
     runStartTime = System.nanoTime();
     currentTime = 0;
     previousTime = 0;
     schedule();
  }
  
  void schedule() {
   int periodTimeStart = 0;
   int periodTimeEnd = 0;
   int clipTimeStart = 0;
   int clipIndex = 0;
   for(int i=0; i<frequency; i++) {
     clipIndex  =  int(random(0, clips.size())); // get a random action clip
     Clip clip = clips.get(clipIndex);
     periodTimeStart = i*period;
     periodTimeEnd = i*period + period;
     clipTimeStart = int(random(periodTimeStart, periodTimeEnd - clip.duration));
     println( "action clip index: " + clipIndex + ". scheduled to start in " + clipTimeStart + " seconds ...");
     scheduledClips.add(new IntPair(clipIndex, clipTimeStart));
   }
 }
  
  
  void initClips(ActionSettings settings) {

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
        println("action clip = "+ clip.clipInfo.backgroundFilename + " duration: " + clip.duration);
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
      if(currentTime > runLengthPeriod) {
        reset();
      } 
      // TODO
    }
  }
  
  Clip getCurrent() {
    // TODO...
    return clips.get(0);
  }
  
  private LinkedList<IntPair> scheduledClips; // list of <clipIndex, start time (in seconds)> for a given run length
  
  private int currentTime = 0;
  private int previousTime = 0;
  
  private double runStartTime = 0;
  private int runLengthPeriod = 0; // an hour period
  private int period = 0;
  private int frequency = 0;
  private LinkedList<Clip> clips;
}
