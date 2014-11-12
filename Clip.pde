
class Clip {
  
  // Note: it's asssumed that the silhouette vidoe length needs to be longer or identical to the length of the background video 
  
  Clip()
  {
    timeline = new Timeline();
  }
  
  Clip(String filename)
  {
    timeline = new Timeline();
    this.filename = filename;
    movie = loadMovie(filename);
    int duration = (int) movie.duration();
    timeline.setDuration(duration);
    started = false;
  }   
  
 boolean hasCompleted() {
   return timeline.hasCompleted();
 }
 
  boolean almostCompleted() {
   if(timeline.getDuration()==-1) {
     return false;
   }

   int currentTime = timeline.getCurrentTime();
   int duration = timeline.getDuration();
   // TODO: the clip "pre-start time should'nt be hardcoded
   return currentTime >= (duration - 4) && currentTime <= duration;
 }
 
  void start() {
    movie.play();
    movie.volume(0);
    timeline.start();
    started = true;
  }
  
  void tick() {
    timeline.tick();
  }
  
  void stop() {
     if(started) {       
       movie.stop();
       timeline.reset();
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
    if(timeline.getDuration()==-1) {
      println("warning: duration not set for clip name=" + filename);
      return 0;
    }
    return timeline.getDuration();
  }
  
  void setDuration(int duration) {    
    timeline.setDuration(duration);
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
 
  protected Timeline timeline; 
  protected boolean started;
  protected String filename;
  protected Movie movie;
}

