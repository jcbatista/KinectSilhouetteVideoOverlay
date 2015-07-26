import java.util.LinkedList;

class SilhouetteClipFactory
{
  private boolean isLive(SilhouetteClipInfo clipInfo) {
    boolean liveSilhouette = Utils.isLiveFilename(clipInfo.silhouetteFilename);
    boolean liveBackground = Utils.isLiveFilename(clipInfo.backgroundFilename);   
    return  liveSilhouette || liveBackground;     
  }
  
  public SilhouetteClip create(SilhouetteClipInfo clipInfo) {
    SilhouetteClip clip = null;
    if(isLive(clipInfo)) {
      clip = new LiveClip(clipInfo);
    } else {
      clip = new SilhouetteClip(clipInfo);
    }
    return clip;
  }  
}

class SilhouetteClipManager
{
 
  SilhouetteClipManager()
  {    
    dataPath = dataPath("") + "/clips/";
    clips = new LinkedList<SilhouetteClip>();
    clipFactory = new SilhouetteClipFactory();    
  }
  
  void add(SilhouetteClipInfo clipInfo) {    
    SilhouetteClip clip = clipFactory.create(clipInfo);
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
    crossfadePosition = currentClip.almostCompleted() ? ++crossfadePosition: 0;
    if(crossfadePosition==1) {
      nextClip = start(nextClipIndex());
    } else if(currentClip.hasCompleted()) {     
      if(clips.size() > 0) {
        crossfadePosition = 0;
        currentClip.stop(); // make sure the current clip is actually stopped
        // cycle to the next clip
        currentClipIndex = nextClipIndex();  
        currentClip = clips.get(currentClipIndex);
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
    /* 
    if(crossfadePosition>0){
      println("crossfade postion = " + crossfadePosition);
    }
    */
    return currentClip;
  }
  
  SilhouetteClip getNext() {
    if(crossfadePosition==0) {      
      return null;
    } 
    return nextClip;
  }
  
  int getCurrentIndex() {
    int index = currentClipIndex;
    if(currentClip.almostCompleted() || currentClip.hasCompleted()) {
      index = nextClipIndex();
    }
    return index;
  }
  
  int getTotalDuration() {
    int total = 0;
    for (SilhouetteClip clip : clips) {    
      total += clip.getDuration();  
    }
    return total;
  }
  
  int getCrossfadePosition() {
    return crossfadePosition;
  }
  
  /*
   * return the current crossfade ratio for a given clip
   */
  float getCrossfadeRatio(Clip clip) {
    return getCrossfadePosition() / (frameRate * clip.getCrossfade()/1000);
  }
  
  boolean isStarted() { return started; }
  private boolean startCrossfade;
  private int crossfadePosition = 0;
  private boolean started = false;
  private String dataPath;
  private LinkedList<SilhouetteClip> clips;
  private int currentClipIndex = -1;
  private SilhouetteClip currentClip = null;
  private SilhouetteClip nextClip = null;
  private SilhouetteClipFactory clipFactory;  
};
