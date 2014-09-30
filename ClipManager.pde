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
    println("Loading clip: " + dataPath + filename);
    return new Movie(applet,  dataPath + filename);
  }
  
  void add(String filename)
  {
    this.add(filename, -1);
  }
  
  void add(StringList list)
  {
    for (String filename : list) {
      this.add(filename, -1);
    }
  }
  
  void add(String filename, int duration)
  {
    Movie movie = LoadMovie(filename);
    Clip clip = new Clip(movie);
    clip.setDuration(duration);
    clips.add(clip);
  }
  
  private void start() {
    if(currentClipIndex==-1 && clips.size() > 0) {
      currentClipIndex = 0;
    }
    currentClip = clips.get(currentClipIndex);
    if(currentClip != null) {
      
      println("*********** Now playing clip index:" + currentClipIndex + " of " + clips.size());
      currentClip.start();
      started = true;
    } else {
      println("clip couldn't be started ...");
    }
  }
  
  Clip getCurrent() {
    if(currentClip.hasCompleted()) {
      int size = clips.size();
      if(size > 0) {
        currentClip.stop(); // make sure the current clip is actually stopped
        // cycle to the next clip
        currentClipIndex = (currentClipIndex+1) % size;
        start();
      }
    } 
    return currentClip;
  }
  
  boolean isStarted() { return started; }
  
  private boolean started = false;
  private String dataPath;
  private LinkedList<Clip> clips;
  private int currentClipIndex = -1;
  private Clip currentClip = null;
  private PApplet applet = null;
};
