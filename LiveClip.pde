import processing.video.*; 

class LiveClip extends SilhouetteClip {
  LiveClip(SilhouetteClipInfo clipInfo)
  {
    super();
    this.clipInfo = clipInfo;
    this.crossfade = clipInfo.crossfade;
    
    boolean liveSilhouette = Utils.isLiveFilename(clipInfo.silhouetteFilename);
    if(Utils.isValidFilename(clipInfo.silhouetteFilename) && !liveSilhouette) {
       silhouetteMovie = loadMovie(clipInfo.silhouetteFilename);
    } else if(liveSilhouette) {
      silhouetteCapture = getCaptureDevice();
    }
    
    boolean liveBackground = Utils.isLiveFilename(clipInfo.backgroundFilename);
    if(Utils.isValidFilename(clipInfo.backgroundFilename) && !liveBackground) {
      backgroundMovie = loadMovie(clipInfo.backgroundFilename);
    } else if(liveBackground) {
      backgroundCapture = getCaptureDevice();
    }
    
    filename = "Live Stream";
    
    setDuration(clipInfo.duration); 
  }
     
   boolean isLiveSilhouette() {
     return silhouetteCapture != null; 
   }
   
   boolean isLiveBackground() {
     return backgroundCapture != null; 
   }
   
  int getSilhouetteFrameLength() {
    if(isLiveSilhouette()) {
      return silhouetteCapture.pixels.length;
    } 
    return super.getSilhouetteFrameLength();
  }

  color getSilhouettePixels(int index) {
    if(isLiveSilhouette()) {
      return silhouetteCapture.pixels[index];
    } 
    return super.getSilhouettePixels(index);
  }
  
  int getBackgroundFrameLength() {
    if(isLiveBackground()) {
      return silhouetteCapture.pixels.length;
    } 
    return super.getBackgroundFrameLength();
  }

  color getBackgroundPixels(int index) {
    if(isLiveBackground()) {
        return backgroundCapture.pixels[index];
    } 
    return super.getBackgroundPixels(index);
  }
  
  void start() {
    if(isLiveSilhouette()) {
      silhouetteCapture.start();
    } else {
      backgroundCapture.start();
    }
    super.start();
  }
  
  void stop() {
    if(isLiveSilhouette()) {
      silhouetteCapture.stop();
    } else {
      backgroundCapture.stop();
    }

    super.stop();
  }

    
  protected Capture silhouetteCapture = null;
  protected Capture backgroundCapture = null;  
}
