Class ClipInfo
{
  String silhouetteFilename = "";
  String backgroundFilename = "";
}

class Clip {
  
  // Note: it's asssumed that the silhouette vidoe needs to be longer or identical in length of the background video. 
  
  Clip(Movie silhouetteMovie, Movie backgroundMovie)
  {
    this.silhouetteMovie = silhouetteMovie;
    this.backgroundMovie = backgroundMovie;
    duration = -1;
    startTime = 0;
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
    // movie.loop();
    if(silhouetteMovie != null) {
      silhouetteMovie.play();
      silhouetteMovie.volume(0);
    }
    
    if(backgroundMovie != null) {
      backgroundMovie.play();
      backgroundMovie.volume(0);
    }
    
    Move movie = silhouetteMovie != null ? silhouetteMovie: backgroundMovie;
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
  Movie silhouetteMovie; // can be null
  Movie backgroundMovie;
}

