import processing.video.*;

class SilhouetteClipInfo
{
  String silhouetteFilename = "";
  String backgroundFilename = "";
  int crossfade = 0;
}

class LiveClip extends SilhouetteClip {
  LiveClip(SilhouetteClipInfo clipInfo)
  {
    super();
    this.clipInfo = clipInfo;
    this.crossfade = clipInfo.crossfade;
    
    liveSilhouette = Utils.isLiveFilename(clipInfo.silhouetteFilename);
    if(Utils.isValidFilename(clipInfo.silhouetteFilename) && !liveSilhouette) {
       silhouetteMovie = loadMovie(clipInfo.silhouetteFilename);
    }
    
    liveBackground = Utils.isLiveFilename(clipInfo.backgroundFilename);
    if(Utils.isValidFilename(clipInfo.backgroundFilename) && !liveBackground) {
      backgroundMovie = loadMovie(clipInfo.backgroundFilename);
    }
    
    filename = "Live Stream";
    
    int duration = 10000; // TODO: hardcoded to 10 seconds for now ...
    clock.setDuration( duration );     
  }

     
   boolean isLiveSilhouette() {
     return liveSilhouette; 
   }
   
   boolean isLiveBackground() {
     return liveBackground; 
   }
   
  protected boolean liveSilhouette = false;
  protected boolean liveBackground = false;
}

class SilhouetteClip extends Clip {
  
  SilhouetteClip() {
    super();
  }
  
  // Note: it's asssumed that the silhouette vidoe length needs to be longer or identical to the length of the background video   
  SilhouetteClip(SilhouetteClipInfo clipInfo)
  {
    super();
    this.clipInfo = clipInfo;
    this.crossfade = clipInfo.crossfade;
    silhouetteMovie = loadMovie(clipInfo.silhouetteFilename);    
    backgroundMovie = loadMovie(clipInfo.backgroundFilename);   
    
    // set a default movie / filename
    if(silhouetteMovie != null) {
      movie = silhouetteMovie;
      filename = clipInfo.silhouetteFilename;
    } else {
      movie = backgroundMovie;
      filename = clipInfo.backgroundFilename;      
    }
    
    int  duration = int (movie.duration() * 1000);
    clock.setDuration( duration );     
  }
    
  boolean hasSilhouette() {
    return silhouetteMovie != null;
  }
  
  boolean hasBackground() {
    return backgroundMovie != null;
  }
  
  void start() {
    if(!started) {
      if(hasSilhouette()) {
        silhouetteMovie.play();
        silhouetteMovie.volume(0);
      }
      
      if(hasBackground()) {
        backgroundMovie.play();
        backgroundMovie.volume(0);    
      }
 
      clock.start();
      started = true;
    }
  }
  
  void stop() {
    if(started) {
      if(silhouetteMovie != null) {
        silhouetteMovie.stop();
      }
      if(backgroundMovie != null) {
        backgroundMovie.stop();
      }
      started = false;
    }
  }
  
  int getSilhouetteFrameLength() {
    return silhouetteMovie.pixels.length;
  }

  int getSilhouettePixels(int index) {
    return hasSilhouette() ? silhouetteMovie.pixels[index] : color(0,0,0);
  }
  
  int getBackgroundFrameLength() {
    return backgroundMovie.pixels.length;
  }

  int getBackgroundPixels(int index) {
    return hasBackground() ? backgroundMovie.pixels[index] : color(0,0,0);
  }
  
  protected SilhouetteClipInfo clipInfo;
  protected Movie silhouetteMovie = null;
  protected Movie backgroundMovie = null;
}

