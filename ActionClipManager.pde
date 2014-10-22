class ActionClipSettings { 
  // TODO actions need to send OSC information
  ActionClipSettings() {
    clips = new StringList();
    durations = new IntList(); // Note: clips and durations index must match
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

class ActionClipManager {
  
  ActionClipManager(ActionClipSettings settings) {
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
     currentClip = null;
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
     println( "action clip index: " + clipIndex + " scheduled to start in " + clipTimeStart + " seconds ...");
     scheduledClips.add(new IntPair(clipIndex, clipTimeStart));
   }
 }
  
  void initClips(ActionClipSettings settings) {
    for (int i=0; i < settings.clips.size(); i++) {
      String filename = settings.clips.get(i);
      Clip clip = new Clip(filename);
      clip.duration = settings.durations.get(i); 
      clips.add(clip);
    }
  }
  
  void listActionClips() {
    println("*** Listing defined action clips ***");
    int count = 1;
    for (Clip clip : clips) {
      println(count + ". action clip = "+ clip.getFilename() + " duration: " + clip.duration);
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
  
  int getClipToStart() {
    int clipIndex = -1; // index of the clip to start
    // clips are store in a {clip index, time to start} pair
    for(IntPair clipPair: scheduledClips) {
      if(clipPair.second == currentTime) {
        clipIndex = clipPair.first;
        break;
      }
    }
    return clipIndex;
  }
  
  private void handleTimeChanges()
  {
    currentTime = getEllapsedTime();
    if(currentTime != previousTime) {
      previousTime = currentTime;

      if(currentTime > runLengthPeriod) {
        reset();
      } 
      
      int clipIndexToStart = getClipToStart();
      if(clipIndexToStart != -1) {
        currentClip = clips.get(clipIndexToStart);
        println("starting action clip index: " + clipIndexToStart);
        currentClip.start();
      }
    }
  }
  
  int getElapseTime() {
    return currentTime;
  }
  
  Clip getCurrent() {
    handleTimeChanges();
    return currentClip!=null && !currentClip.hasCompleted() ? currentClip: null;
  }
  
  private LinkedList<IntPair> scheduledClips; // list of <clipIndex, start time (in seconds)> for a given run length
 
  private Clip currentClip = null;
  private int currentTime = 0;
  private int previousTime = 0;
  
  private double runStartTime = 0;
  private int runLengthPeriod = 0; // an hour period
  private int period = 0;
  private int frequency = 0;
  private LinkedList<Clip> clips;
}
