
class Clip {
  
  // Note: it's asssumed that the silhouette vidoe length needs to be longer or identical to the length of the background video 
  
  Clip()
  {
    duration = -1;
    startTime = 0;
  }
  
  Clip(String filename)
  {
    this.filename = filename;
    movie = loadMovie(filename);
    duration = -1;
    startTime = 0;
    started = false;
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
  
 boolean hasCompleted() {
   if(duration==-1) {
     return false;
   }

   return getEllapsedTime() > duration;
 }
 
  boolean almostCompleted() {
   if(duration==-1) {
     return false;
   }

   int x = getEllapsedTime();
   return x>= (duration - 3) && x<=duration;
 }
 
  void start() {
    movie.jump(0);
    movie.play();
    movie.volume(0);
    
    duration = (int) movie.duration();
    startTime = System.nanoTime();
    started = true;
  }
  
  void stop() {
     movie.stop();
     startTime = 0;
     started = false;
     
  }
  
  boolean isStarted() { return started; }
  
  String getFilename() {
    return filename;
  }
 
  Movie getMovie() {
    return movie;
  }
  
  protected Movie loadMovie(String filename) {
    if(filename==null || filename=="") {
      return null;
    }  
    Movie movie = globalLoadMovie(filename);
    movie.pause();
    // TODO: we might no longer need duration in the json.config file for action clips 
    // println(filename + " duration=" + (int) movie.duration() + "!!");    
    return movie; 
  }
 
  protected boolean started;
  protected String filename;
  protected int duration;   // in seconds or -1 if not set
  protected long startTime; // start time in nanoseconds
  protected Movie movie;
}

