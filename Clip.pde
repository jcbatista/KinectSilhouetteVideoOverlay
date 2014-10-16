import processing.video.*;

class Clip {
  
  // Note: it's asssumed that the silhouette vidoe needs to be longer or identical in length of the background video. 
  
  Clip(ClipInfo clipInfo)
  {
    this.clipInfo = clipInfo;
    this.silhouetteMovie = loadMovie(clipInfo.silhouetteFilename);
    this.backgroundMovie = loadMovie(clipInfo.backgroundFilename);
    this.movie = silhouetteMovie != null ? silhouetteMovie: backgroundMovie;
    duration = -1;
    startTime = 0;
  }
  
  boolean hasSilhouette() {
    return silhouetteMovie != null;
  }
  
  boolean hasBackground() {
    return backgroundMovie != null;
  }
  
  Movie loadMovie(String filename) {
    if(filename==null || filename=="") {
      return null;
    }  
    return globalLoadMovie(filename);
  }

  void setDuration(int duration) {
    this.duration = duration;
  }
  
  int getEllapsedTime() {
    // TODO: doesn't work
    long elapseTime = System.nanoTime() - startTime;
    double seconds = (double)elapseTime / 1000000000d; 
    return (int)seconds;
  }
  
 int count = 0;
 boolean hasCompleted() {
   //return !movie.available();

   if(duration==-1) {
     return false;
   }
   /*
   // TODO REMOVE
   if(count<100)
   {
    // println("ellapsed time="+seconds);
     System.out.format("getEllapsedTime() : %d Seconds ", getEllapsedTime());
     System.out.format("duration: %d \n", duration);
     count++;
   }
   */
   return getEllapsedTime() > duration;
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
  ClipInfo clipInfo;
  Movie silhouetteMovie; // can be null
  Movie backgroundMovie;
  Movie movie;
}

