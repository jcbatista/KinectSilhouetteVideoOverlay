import java.util.BitSet;

class SilhouetteFrame {
  private BitSet bitSet;
  SilhouetteFrame() {
    bitSet = new BitSet(KINECT_WIDTH * KINECT_HEIGHT);    
  }
  
  boolean get(int n) { return bitSet.get(n); }
  void set(int n, boolean value) { bitSet.set(n, value); }
}

class SilhouetteFrameCache {

  SilhouetteFrameCache() {
    cache = new LinkedList<SilhouetteFrame>();
  }
  
  void add(SilhouetteFrame frame) {
    if(cache.size() > maxFrames) {
      cache.remove();
    }
    cache.add(frame);
  }
  
  boolean canPlayback() {
    return cache.size() >= 240; // need at least 10 seconds to allow playback of cached silouette
  }
  
  SilhouetteFrame getCurrent() {
    SilhouetteFrame frame = null;
    int size = cache.size();
    if(size > 0) {
      currentFrameIndex++;
      if(currentFrameIndex == -1) {
        currentFrameIndex = (currentFrameIndex + 1) % size;
        frame = cache.get(currentFrameIndex);
      }          
    }
    return frame;
  }
    
  private LinkedList<SilhouetteFrame> cache;
  private int currentFrameIndex = -1;
  private int maxFrames = 53280; // ~ 1 min  
}

