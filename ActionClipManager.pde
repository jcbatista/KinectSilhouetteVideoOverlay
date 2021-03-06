
class ActionClipSettings { 
  ActionClipSettings() {
    clips = new StringList();
  }
  StringList clips;
  int frequency;
}

class IntPair { 
   IntPair(int first, int second) { 
     this.first = first; 
     this.second = second; 
  }   
  int first; 
  int second; 
} 

class ActionClipManager {
  
  ActionClipManager(Clock clock, ActionClipSettings settings) {
    this.clock = clock;
    clips = new LinkedList<Clip>();
    scheduledClips = new LinkedList<IntPair>();
    frequency = settings.frequency;   
    
    if(shouldPlay()) {
      initClips(settings);
      listActionClips();
    } 
  }
  
  void definePeriod(int duration) {
    if(frequency > 0 ){
      period = duration / frequency;
    } else {
      period = 0;
    }  
  }
  
  void start() {
      reset();
  }
  
  private void reset() {       
     currentClip = null;
     currentClipIndex = -1;
     if(shouldPlay()) {
       schedule();
     }
  }
    
  void initClips(ActionClipSettings settings) {
    for (int i=0; i < settings.clips.size(); i++) {
      String filename = settings.clips.get(i);
      Clip clip = new Clip(filename);
      clips.add(clip);
    }
  }
  
  void listActionClips() {
    println("*** Listing defined action clips ***");
    int count = 1;
    for (Clip clip : clips) {
      println(count + ". action clip = "+ clip.getFilename() + " duration: " + int(clip.getDuration()/1000));
      count++;
    }
    println("*** Done. ***");
  }
  
  boolean shouldPlay() {
    return frequency!=0;
  }
  
  int getClipToStart() {
    int clipIndex = -1; // index of the clip to start
    // clips are stored as a {clip index, time to start} value pair
    for(IntPair clipPair: scheduledClips) {
      if(clipPair.second == clock.getCurrentTimeInSec()) {
        clipIndex = clipPair.first;
        break;
      }
    }
    return clipIndex;
  }
  
  private void handleTimeChanges() {
    int clipIndexToStart = getClipToStart();
    if(clipIndexToStart != -1) {
      currentClipIndex = clipIndexToStart;
      currentClip = clips.get(currentClipIndex);
      if(!currentClip.isStarted()) {
        println("starting action clip index: " + currentClipIndex);        
        currentClip.start();
      }
    }
  }
    
  void next() {       
    if(currentClip!=null && currentClip.isStarted()) {
      currentClip.tick();            
      if(currentClip.hasCompleted()) {
        currentClip.stop();
      }           
    }    
    if(clock.hasTimeChanged()) {
      handleTimeChanges();     
    }
  }
  
  Clip getCurrent() {    
    return currentClip!=null && !currentClip.hasCompleted() ? currentClip: null;
  }
  
  int getCurrentIndex() {    
    // println("current action clip index = " + currentClipIndex);
    return currentClip!=null && !currentClip.hasCompleted() ? currentClipIndex: -1;
  }
  
  private void schedule() {
   int periodTimeStart = 0;
   int periodTimeEnd = 0;
   int clipTimeStart = 0;
   int clipIndex = 0;
   for(int i=0; i<frequency; i++) {
     clipIndex = int(random(0, clips.size())); // get a random action clip
     Clip clip = clips.get(clipIndex);
     periodTimeStart = i*period;
     periodTimeEnd = i*period + period;
     clipTimeStart = int(random(periodTimeStart, periodTimeEnd - clip.getDuration()) / 1000);
     println( "action clip index: " + clipIndex + " scheduled to start in " + clipTimeStart + " seconds ...");
     scheduledClips.add(new IntPair(clipIndex, clipTimeStart));
   }
 }
  
  
  private Clock clock = null;
  private LinkedList<IntPair> scheduledClips; // list of <clipIndex, start time (in seconds)> for a given run length
 
  private int currentClipIndex = -1;
  private Clip currentClip = null;
  private int period = 0;
  private int frequency = 0;
  private LinkedList<Clip> clips;
}
