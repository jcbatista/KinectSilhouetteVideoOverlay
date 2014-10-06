import java.util.BitSet;

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

  SilhouetteFrameCache() {
    cache = new LinkedList<SilhouetteFrame>();
  }
  
  void add(SilhouetteFrame frame) {
    if(!playbackReady && canPlayback()) {
      println("SilhouetteFrameCache ready for playback ...");
      playbackReady = true;
    }
    
    if(cache.size() > maxFrames) {
      cache.remove();
    }
    cache.add(frame);
  }
  
  boolean canPlayback() {
    return cache.size() >= minFrames; 
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
  private boolean playbackReady = false;
  private LinkedList<SilhouetteFrame> cache;
  private int currentFrameIndex = -1;
  private int minFrames = 240; // need at least 10 seconds to allow playback of cached silouette
  private int maxFrames = 720; // ~30 sec ...
}

