import processing.video.*;

class SilhouetteClipInfo
{
  String silhouetteFilename = "";
  String backgroundFilename = "";
  int crossfade = 0;
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
    this.crossfade = clipInfo.crossfade; // adjust crossfade propertie in the baseclass
    
    liveSilhouette = isLive(clipInfo.silhouetteFilename);
    if(isValidFilename(clipInfo.silhouetteFilename) && !liveSilhouette) {
       silhouetteMovie = loadMovie(clipInfo.silhouetteFilename);
    }
    
    liveBackground = isLive(clipInfo.backgroundFilename);
    if(isValidFilename(clipInfo.backgroundFilename) && !liveBackground) {
      backgroundMovie = loadMovie(clipInfo.backgroundFilename);
    }
    
    // set a default movie / filename
    if(silhouetteMovie != null) {
      movie = silhouetteMovie;
      filename = clipInfo.silhouetteFilename;
    } else if (backgroundMovie != null) {
      movie = backgroundMovie;
      filename = clipInfo.backgroundFilename;      
    } else {
      filename = "Live Stream";
    }
    
    int duration = 0;
    if(!isLive()) { 
      duration = int (movie.duration() * 1000);
    } else {
      duration = 10000; // TODO: hardcoded to 10 seconds for now ...
    }
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
  
  boolean isLive(String filename) {
    return isValidFilename(filename) && filename.equalsIgnoreCase("live");
  } 
    
   boolean isLiveSilhouette() {
     return liveSilhouette; 
   }
   
   boolean isLiveBackground() {
     return liveBackground; 
   }
   
   boolean isLive() {
     return liveSilhouette || liveBackground; 
   };
  
  protected SilhouetteClipInfo clipInfo;
  protected Movie silhouetteMovie = null;
  protected Movie backgroundMovie = null;
  protected boolean liveSilhouette = false;
  protected boolean liveBackground = false;
}

