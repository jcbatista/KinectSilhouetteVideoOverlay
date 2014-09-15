class Clip {
  
  Clip(Movie movie)
  {
    this.movie = movie;
    
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

   if(duration==-1)
     return false;
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
    movie.play();
    movie.volume(0);
    duration = (int) movie.duration();
    startTime = System.nanoTime();
  }
  
  void stop() {
    movie.stop();
    startTime = 0;
  }
  
  int duration; // in seconds or -1 if not set
  long startTime; // start time in nanoseconds
  Movie movie;
}

