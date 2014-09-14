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
    Movie movie = LoadMovie(filename);
    movie.volume(0);
    Clip clip = new Clip(movie);
    clips.add(clip);
  }
  
  void start() {
    currentClip = clips.getFirst();
    
    if(currentClip!=null) {
      currentClip.movie.loop();
      currentClipIndex = 0;
    } else {
      println("clip sequence couldn't be started...");
    }
  }
  
  Clip getCurrent() { 
    return currentClip;
  }
  
  void next() {
    // todo
  }
  
  private String dataPath;
  private LinkedList<Clip> clips;
  private int currentClipIndex = -1;
  private Clip currentClip = null;
  private PApplet applet = null;
};
