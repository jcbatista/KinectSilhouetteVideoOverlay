
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
    setDuration();
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

  int getFrameLength() {
    return movie.pixels.length;
  }

  int getPixels(int index) {
    return movie.pixels[index];
  }
  
  int getDuration() {
    if(clock.getDuration()==-1) {
      println("warning: duration not set for clip name=" + filename);
      return 0;
    }
    return clock.getDuration();
  }
  
  void setDuration() {
    setDuration(-1);
  }
  
  void setDuration(int duration) {
    if(duration==-1) {
      if(movie!=null) {
        duration = (int) (movie.duration() * 1000); // in ms
      } else {
        println("warning: undefined movie for clip filename=" + filename + ". using 1 second default duration."); 
        duration = 1000;
      }
    }  
    clock.setDuration(duration);
  } 
  
  protected Movie loadMovie(String filename) {
    if(!Utils.isValidFilename(filename)) {
      return null;
    }  
    Movie movie = new Movie(application, dataPath("") + "/clips/" + filename);
    movie.pause();
    // TODO: we might no longer need duration in the json.config file for action clips 
    // println(filename + " duration=" + (int) movie.duration() + "!!!!!!!!");    
    return movie; 
  }  
 
  protected Clock clock;
  protected Movie movie;
  protected int crossfade;
  protected boolean started;
  protected String filename;
}

