import java.util.LinkedList;

class SilhouetteClipManager
{
  SilhouetteClipManager(PApplet applet)
  {    
    this.applet  = applet;
    dataPath = dataPath("") + "/clips/";
    clips = new LinkedList<SilhouetteClip>();
  }
  
  Movie LoadMovie(String filename) {
    println("Loading clip: " + dataPath + filename);
    return new Movie(applet,  dataPath + filename);
  }

  void add(SilhouetteClipInfo clipInfo) {
    SilhouetteClip clip = new SilhouetteClip(clipInfo);
    clips.add(clip);
  }  

  void add(LinkedList<SilhouetteClipInfo> clipInfolist) {
    for (SilhouetteClipInfo clipInfo : clipInfolist) {
      this.add(clipInfo);
    }
  }
  
  void start() {        
    if(currentClipIndex==-1 && clips.size() > 0) {
      currentClipIndex = 0;
    }
    start(currentClipIndex);
    currentClip = clips.get(currentClipIndex);
  }
  
  private SilhouetteClip start(int clipIndex) {
    SilhouetteClip clip = clips.get(clipIndex);
    if(clip != null && !clip.isStarted()) {      
      println("*********** now playing clip " + clipIndex + " of " + clips.size());
      clip.start();
      started = true;
    } else if(clip == null) {
      // ignore the case where the clip's already started
      println("clip couldn't be started ...");
    }
    return clip;
  }
  
  private int nextClipIndex() {
    return (currentClipIndex+1) % clips.size();
  }
  
  SilhouetteClip getCurrent() {
  
    // TODO: add the prestart clip logic here!!!!  
    if(currentClip.almostCompleted()) {
      nextClip = start(nextClipIndex()); 
    } else if(currentClip.hasCompleted()) {     
      if(clips.size() > 0) {
        currentClip.stop(); // make sure the current clip is actually stopped
        // cycle to the next clip
        currentClipIndex = nextClipIndex();  
        currentClip =  clips.get(currentClipIndex);
        if(!currentClip.isStarted()) {
          start(currentClipIndex); 
        }
      }
    } 
    
    if(currentClip!=null) {
      currentClip.tick();
    }
    
    if(nextClip!=null) {
      nextClip.tick();
    }
      
    return currentClip;
  }
  
  int getCurrentIndex() {
    return currentClipIndex;
  }
  
  int getTotalDuration() {
    int total = 0;
    for (SilhouetteClip clip : clips) {    
      total += clip.getDuration();  
    }
    return total;
  }
  
  boolean isStarted() { return started; }
  
  private boolean started = false;
  private String dataPath;
  private LinkedList<SilhouetteClip> clips;
  private int currentClipIndex = -1;
  private SilhouetteClip currentClip = null;
  private SilhouetteClip nextClip = null;
  private PApplet applet = null;
};
