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
    this.add(clipInfo, -1);
  }
  
  void add(LinkedList<SilhouetteClipInfo> clipInfolist) {
    for (SilhouetteClipInfo clipInfo : clipInfolist) {  
      this.add(clipInfo, -1);
    }
  }
  
  void add(SilhouetteClipInfo clipInfo, int duration) {
    SilhouetteClip clip = new SilhouetteClip(clipInfo);
    clip.setDuration(duration);
    clips.add(clip);
  }
  
  void start() {        
    if(currentClipIndex==-1 && clips.size() > 0) {
      currentClipIndex = 0;
    }
    start(currentClipIndex);
    currentClip = clips.get(currentClipIndex);
  }
  
  private void start(int clipIndex) {
    SilhouetteClip clip = clips.get(clipIndex);
    if(clip != null && !clip.isStarted()) {      
      println("*********** now playing clip " + clipIndex + " of " + clips.size());
      clip.start();
      started = true;
    } else if(clip == null) {
      // ignore the case where the clip's already started
      println("clip couldn't be started ...");
    }
  }
  
  private int nextClipIndex() {
    return (currentClipIndex+1) % clips.size();
  }
  
  SilhouetteClip getCurrent() {
  
    // TODO: add the prestart clip logic here!!!!  
    if(currentClip.almostCompleted()) {
      start(nextClipIndex()); 
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
    return currentClip;
  }
  
  int getCurrentIndex() {
    return currentClipIndex;
  }
  
  boolean isStarted() { return started; }
  
  private boolean started = false;
  private String dataPath;
  private LinkedList<SilhouetteClip> clips;
  private int currentClipIndex = -1;
  private SilhouetteClip currentClip = null;
  private PApplet applet = null;
};
