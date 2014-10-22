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
  
  private void start() {
    if(currentClipIndex==-1 && clips.size() > 0) {
      currentClipIndex = 0;
    }
    currentClip = clips.get(currentClipIndex);
    if(currentClip != null) {
      
      println("*********** now playing clip " + currentClipIndex + " of " + clips.size());
      currentClip.start();
      started = true;
    } else {
      println("clip couldn't be started ...");
    }
  }
  
  SilhouetteClip getCurrent() {
    if(currentClip.hasCompleted()) {
      
      int size = clips.size();
      if(size > 0) {
        currentClip.stop(); // make sure the current clip is actually stopped
        // cycle to the next clip
        currentClipIndex = (currentClipIndex+1) % size;        
        start(); 
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
