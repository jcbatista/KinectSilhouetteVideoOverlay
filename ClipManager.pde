import java.util.LinkedList;

class ClipManager
{
  ClipManager(PApplet applet)
  {
    this.applet  = applet;
    dataPath = dataPath("") + "/clips/";
    clips = new LinkedList<Clip>();
  }
  
  Movie LoadMovie(String filename) {
    return new Movie(applet,  dataPath + filename);
  }
  
  void add(String filename)
  {
    this.add(filename, -1);
  }
  
  void add(String filename, int duration)
  {
    Movie movie = LoadMovie(filename);
    Clip clip = new Clip(movie);
    clip.setDuration(duration);
    clips.add(clip);
  }
  
  void start() {
    currentClip = clips.getFirst();
    if(currentClip != null) {
      currentClip.start();
      currentClipIndex = 0;
      started = true;
    } else {
      println("clip sequence couldn't be started...");
    }
  }
  
  Clip getCurrent() { 
    if(!currentClip.hasCompleted()) {
      return currentClip;
    } else {
      //currentClip.stop();
      // get the next one
      // TODO
      return null;
    } 
  }
  
  void next() {
    // todo
  }
  
  boolean isStarted() { return started; }
  
  private boolean started = false;
  private String dataPath;
  private LinkedList<Clip> clips;
  private int currentClipIndex = -1;
  private Clip currentClip = null;
  private PApplet applet = null;
};
