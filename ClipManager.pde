import java.util.LinkedList;

class ClipManager
{
  ClipManager(PApplet applet)
  {
    this.applet  = applet;
    dataPath = dataPath("") + "/clips/";
    clips = new LinkedList<Clip>();
    currentOverlayMode = OverlayMode.Silhouette;
  }
  
  OverlayMode currentOverlayMode;
  
  // alternate between background and silhouette video overlay
  OverlayMode getCurrentOverlayMode() {
    return currentOverlayMode;
  }
  
  void toggleOverlayMode() {
    if(currentOverlayMode==OverlayMode.Background) {
      currentOverlayMode = OverlayMode.Silhouette;
    } else {
      currentOverlayMode = OverlayMode.Background;
    }
  }
  
  Movie LoadMovie(String filename) {
    println("Loading clip: " + dataPath + filename);
    return new Movie(applet,  dataPath + filename);
  }
  
  void add(ClipInfo clipInfo) {
    this.add(clipInfo);
  }
  
  void add(LinkedList<ClipInfo> clipInfolist) {
    for (ClipInfo clipInfo : clipInfolist) {  
      this.add(clipInfo, -1);
    }
  }
  
  void add(ClipInfo clipInfo, int duration) {
    Clip clip = new Clip(clipInfo);
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
  
  Clip getCurrent() {
    if(currentClip.hasCompleted()) {
      int size = clips.size();
      if(size > 0) {
        currentClip.stop(); // make sure the current clip is actually stopped
        // cycle to the next clip
        currentClipIndex = (currentClipIndex+1) % size;
        
        toggleOverlayMode(); // flip the overlay mode
        
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
  private LinkedList<Clip> clips;
  private int currentClipIndex = -1;
  private Clip currentClip = null;
  private PApplet applet = null;
};
