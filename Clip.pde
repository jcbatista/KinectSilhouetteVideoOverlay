
class Clip {
  
  // Note: it's asssumed that the silhouette vidoe length needs to be longer or identical to the length of the background video 
  
  Clip()
  {
    clock = new Clock();
    crossfade = 0;
  }
  
  Clip(String filename)
  {    
    clock = new Clock();
    this.filename = filename;
    movie = loadMovie(filename);
    int duration = (int) (movie.duration() * 1000); // in ms
    clock.setDuration(duration);
    started = false;
    crossfade = 0;
  }   
  
  int getCrossfade() {
    return crossfade;
  }  
  
  void setCrossfade(int value) {
    crossfade = value;
  }  

 boolean hasCompleted() {
   return clock.hasCompleted();
 }
 
  boolean almostCompleted() {
    // TODO refactor crossfade
   if(clock.getDuration()==-1 || crossfade==0) {
     return false;
   }

   int currentTime = clock.getCurrentTime();
   int duration = clock.getDuration();
   return currentTime >= (duration - crossfade) && currentTime <= duration;
 }
 
  void start() {
    if(!started) {
      movie.play();
      movie.volume(0);
      clock.start();
      started = true;
    }
  }
  
  void tick() {
    clock.tick();
  }
  
  void stop() {
     if(started) {       
       movie.stop();
       clock.reset();
       started = false;
       println("clip filename=" + filename + " stopped!!");
     }     
  }
  
  boolean isStarted() { 
    return started; 
  }
  
  String getFilename() {
    return filename;
  }
 
  Movie getMovie() {
    return movie;
  }
  
  int getDuration() {
    if(clock.getDuration()==-1) {
      println("warning: duration not set for clip name=" + filename);
      return 0;
    }
    return clock.getDuration();
  }
  
  void setDuration(int duration) {    
    clock.setDuration(duration);
  }
  
  protected Movie loadMovie(String filename) {
    if(filename==null || filename=="") {
      return null;
    }  
    Movie movie = globalLoadMovie(filename);
    movie.pause();
    // TODO: we might no longer need duration in the json.config file for action clips 
    // println(filename + " duration=" + (int) movie.duration() + "!!!!!!!!");    
    return movie; 
  }  
 
  protected int crossfade;
  protected Clock clock; 
  protected boolean started;
  protected String filename;
  protected Movie movie;
}

