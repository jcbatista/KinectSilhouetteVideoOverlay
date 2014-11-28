import java.util.BitSet;

class SilhouettePadding {
  int top = 0;
  int right = 0;
  int bottom = 0;
  int left = 0;
}

class SilhouetteCacheData {
  boolean enabled = false;
  int minFrames = 240;
  int maxFrames = 8000;
}

class MetaData {
    
  MetaData(int totalUsers, int userIndex, PVector position) {
    this.totalUsers = totalUsers;
    this.userIndex = userIndex;
    this.position = position;
  }
    
  int totalUsers = 0;
  int userIndex = 0;
  PVector position = null;
}

class SilhouetteFrame {
  SilhouetteFrame() {
    bitSet = new BitSet(KINECT_WIDTH * KINECT_HEIGHT);    
    metaDataList = new LinkedList<MetaData>();
  }
  
  boolean get(int n) { return bitSet.get(n); }
  void set(int n, boolean value) { bitSet.set(n, value); }
  int size() { return bitSet.size(); }
  
  void addMetaData(int totalUsers, int userIndex, PVector position) {
    // println("adding metadata for user " + userIndex);
    metaDataList.add(new MetaData(totalUsers, userIndex, position));
  }
  
  LinkedList<MetaData> getMetaDataList() { return metaDataList; }
  
  private LinkedList<MetaData> metaDataList;
  private BitSet bitSet;
}

class SilhouetteFrameCache {

  SilhouetteFrameCache(SilhouetteCacheData data) {
    this.clock = new Clock();
    cache = new LinkedList<SilhouetteFrame>();
    enabled = data.enabled;
    minFrames = data.minFrames;
    maxFrames = data.maxFrames;
  }
  
  void add(SilhouetteFrame frame) {
    if(!enabled || frame==null) {
      return;
    }
    
    if(cache.size() > maxFrames) {
      cache.remove();
    }
    cache.add(frame);
    
    if(!playbackReady && canPlayback()) {      
      playbackReady = true;

      // TODO: figure out why we need the frameRate / 2 slowdown threshold
      int frameRateGranularity =  1000 / ceil(frameRate / 2);
      this.clock.setGranularity(frameRateGranularity);
      println("************* SilhouetteFrameCache ready for playback, framerate: "+ int(frameRate) +" fps, clock ganularity: " + frameRateGranularity +"ms *************");
    }
  }
  
  boolean canPlayback() {
    boolean success = false;
    if(enabled){
      success = cache.size() >= minFrames; 
    }
    return success;
  }
  
  void next() {
    int size = cache.size();
    this.clock.tick();
    /*
    if(clock.hasTimeChanged()) {
      println("framecache time changed at " + clock.getCurrentTimeInSec());
    }
    */
    
    boolean timeChanged = clock.hasTimeChanged();
    
    if(!timeChanged && currentFrameIndex==-1) {
      println("error: SilhouetteFrame.next(). clock.hasTimeChanged() should be true");
    }
    
    if(enabled && size > 0 && timeChanged) {
      currentFrameIndex++;
      currentFrameIndex = (currentFrameIndex + 1) % size;
    }
  }
  
  SilhouetteFrame getLast() {
    SilhouetteFrame frame = null;    
    if(enabled && cache.size() > 0) {
      frame = cache.getLast();
    }
    return frame;
  }
  
  SilhouetteFrame getCurrent() {
    SilhouetteFrame frame = null;    
    if(enabled && cache.size() > 0) {
      if(currentFrameIndex != -1) {        
        frame = cache.get(currentFrameIndex);
      }
      if(frame==null) {
        println("error: invalid frame in cache. currentFrameIndex=" + currentFrameIndex + " of " + cache.size());
      }      
    }
    
    return frame;
  }
  
  void start() {      
    println("starting using Silhouette cached frames ...");
    isStarted = true;
    if(currentFrameIndex==-1 && canPlayback()) {
      currentFrameIndex = 0;
    }
    this.clock.reset();
  }
  
  void stop() {
    isStarted = false;
    println("stopped using Silhouette cached frames ...");
  }
  
  boolean isStarted() {
    return isStarted;
  }
  
  private Clock clock;
  private boolean enabled = false;
  private boolean isStarted = false;
  private boolean playbackReady = false;
  private LinkedList<SilhouetteFrame> cache;
  private int currentFrameIndex = -1;
  private int minFrames = 0; 
  private int maxFrames = 0;
}

