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
    this.clipInfo = clipInfo;
    silhouetteMovie = loadMovie(clipInfo.silhouetteFilename);
    backgroundMovie = loadMovie(clipInfo.backgroundFilename);
    
    // set a default movie / filename
    if(silhouetteMovie != null) {
      movie = silhouetteMovie;
      filename =  clipInfo.silhouetteFilename;
    } else {
      movie = backgroundMovie;
      filename =  clipInfo.backgroundFilename;      
    }
    
    duration = -1;
    startTime = 0;
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
    
    duration = (int) movie.duration();
    startTime = System.nanoTime();
  }
  
  void stop() {
    if(silhouetteMovie != null) {
      silhouetteMovie.stop();
    }
    if(backgroundMovie != null) {
      backgroundMovie.stop();
    }
    startTime = 0;
  }
  
  int duration; // in seconds or -1 if not set
  long startTime; // start time in nanoseconds
  SilhouetteClipInfo clipInfo;
  Movie silhouetteMovie; // can be null
  Movie backgroundMovie;
}

