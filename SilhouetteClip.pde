import processing.video.*;

class SilhouetteClipInfo
{
  String silhouetteFilename = "";
  String backgroundFilename = "";
}

class SilhouetteClip extends Clip {
  
  // Note: it's asssumed that the silhouette vidoe length needs to be longer or identical to the length of the background video 
  
  SilhouetteClip(SilhouetteClipInfo clipInfo)
  {
    timeline = new Timeline();
    this.clipInfo = clipInfo;
    
    silhouetteMovie = loadMovie(clipInfo.silhouetteFilename);
    backgroundMovie = loadMovie(clipInfo.backgroundFilename);
    
    // set a default movie / filename
    if(silhouetteMovie != null) {
      movie = silhouetteMovie;
      filename =clipInfo.silhouetteFilename;
    } else {
      movie = backgroundMovie;
      filename = clipInfo.backgroundFilename;      
    }
    
    timeline.setDuration( (int) movie.duration() );     
  }
    
  boolean hasSilhouette() {
    return silhouetteMovie != null;
  }
  
  boolean hasBackground() {
    return backgroundMovie != null;
  }
  
  void start() {
    if(hasSilhouette()) {
      silhouetteMovie.play();
      silhouetteMovie.volume(0);
    }
    
    if(hasBackground()) {
      backgroundMovie.play();
      backgroundMovie.volume(0);    
    }
    
    timeline.start();
    started = true;
  }
  
  void stop() {
    if(silhouetteMovie != null) {
      silhouetteMovie.stop();
    }
    if(backgroundMovie != null) {
      backgroundMovie.stop();
    }
    started = false;
  }
  
  private SilhouetteClipInfo clipInfo;
  private Movie silhouetteMovie; // can be null
  private Movie backgroundMovie;
}

