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

  color getSilhouettePixels(int index) {
    return hasSilhouette() ? silhouetteMovie.pixels[index] : color(0,0,0);
  }
  
  int getBackgroundFrameLength() {
    return backgroundMovie.pixels.length;
  }

  color getBackgroundPixels(int index) {
    return hasBackground() ? backgroundMovie.pixels[index] : color(0,0,0);
  }
  
  protected SilhouetteClipInfo clipInfo;
  protected Movie silhouetteMovie = null;
  protected Movie backgroundMovie = null;  
}

