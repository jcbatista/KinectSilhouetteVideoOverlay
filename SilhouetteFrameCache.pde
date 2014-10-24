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
  int totalUsers;
  int userIndex;
  PVector position;
}

class SilhouetteFrame {
  private BitSet bitSet;
  SilhouetteFrame() {
    bitSet = new BitSet(KINECT_WIDTH * KINECT_HEIGHT);    
  }
  
  boolean get(int n) { return bitSet.get(n); }
  void set(int n, boolean value) { bitSet.set(n, value); }
  int size() { return bitSet.size(); }
}

class SilhouetteFrameCache {

  SilhouetteFrameCache(SilhouetteCacheData data) {
    cache = new LinkedList<SilhouetteFrame>();
    metaDataCache = new LinkedList<MetaData>();
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
      println("SilhouetteFrameCache ready for playback ...");
      playbackReady = true;
    }
  }
  
  boolean canPlayback() {
    boolean success = false;
    if(enabled){
      success = cache.size() >= minFrames; 
    }
    return success;
  }
  
  SilhouetteFrame getCurrent() {
    SilhouetteFrame frame = null;
    int size = cache.size();
    if(enabled && size > 0) {
      currentFrameIndex++;
      if(currentFrameIndex != -1) {
        currentFrameIndex = (currentFrameIndex + 1) % size;
        frame = cache.get(currentFrameIndex);
      }          
    }
    // println("currentFrameIndex=" + currentFrameIndex + " of " + size);
    return frame;
  }
  
  int getCurrentFrameIndex() {
    return currentFrameIndex;
  }
  
  void addMetaData(int totalUsers, int userIndex, PVector position) {
    metaDataCache.add(new MetaData(totalUsers, userIndex, position));
  }
  
  MetaData getMetaData(int index) {
    if(!enabled || index==-1 || index >= metaDataCache.size()) {
      return null;
    }
    return metaDataCache.get(index);
  }
  
  private boolean enabled = false;
  private boolean playbackReady = false;
  private LinkedList<MetaData> metaDataCache;
  private LinkedList<SilhouetteFrame> cache;
  private int currentFrameIndex = -1;
  private int minFrames = 0; 
  private int maxFrames = 0;
}

