import java.util.concurrent.*;
import java.util.List;

public class RendererFactory {  
  public RendererFactory(int width, int height) {
    this.width = width;
    this.height = height;
  }
  
  public Renderer create(boolean useGpu) {
    Renderer renderer = null;
    if(useGpu) {
      renderer = new GpuRenderer(this.width, this.height);
    } else {
      renderer = new Renderer(this.width, this.height);
    }
    return renderer;
  }
  
  private int width;
  private int height;
}

public class GpuRenderer extends Renderer {
  private GpuRenderer() {}
  
  public GpuRenderer(int width, int height) {
    application.size(width, height, OPENGL);
    
    // init hardware accelerated blur 
    blur = loadShader("shaders/blur.glsl");
    blur.set("blurSize", 60);
    blur.set("sigma", 2f); 
    
    blurPass1 = createGraphics(KINECT_WIDTH, KINECT_HEIGHT, P2D);
    blurPass1.noSmooth();  
    
    blurPass2 = createGraphics(KINECT_WIDTH, KINECT_HEIGHT, P2D);
    blurPass2.noSmooth();
    
    println("Using *GPU* renderer!!!");
  }
  
  /*
   * apply a  hardware accelerated blur filter on the given image
   */
  public PImage smoothEdges(PImage image, int smooth) {
    if(smooth > 0) {
      // Applying the blur shader along the vertical direction   
      blur.set("horizontalPass", 0);
      blurPass1.beginDraw();            
      blurPass1.shader(blur);  
      blurPass1.image(image, 0, 0);
      blurPass1.endDraw();
      
      // Applying the blur shader along the horizontal direction      
      blur.set("horizontalPass", 1);
      blurPass2.beginDraw();            
      blurPass2.shader(blur);  
      blurPass2.image(blurPass1, 0, 0);
      blurPass2.endDraw();    
      image = blurPass2.get();  
    }
    return image;
  }
  
  private PShader blur;
  private PGraphics blurPass1;
  private PGraphics blurPass2;
}

public class Renderer {
  
  private ExecutorService exec;
  private List<Range> ranges;
  
  private Renderer() {}
  public Renderer(int width, int height) {
    application.size(width, height);
    threadCount = Runtime.getRuntime().availableProcessors();
    if(!useThreads()) {
      threadCount = 1;
      // TODO: requires smarter logic
      println("available number of processors isn't a valid display size multiplier");
    }
    exec = Executors.newFixedThreadPool(threadCount);
    initRanges();
    println("Using *DEFAULT* renderer!!! with " + threadCount + " threads");
  }
  
  boolean useThreads() {
    return (size()%threadCount)==0;
  }
  
  int size() { 
    return KINECT_WIDTH * KINECT_HEIGHT;
  }
  
  void initRanges() {
    ranges = new LinkedList<Range>();
    int length = size() / threadCount;
    for( int i=0; i<threadCount; i++ ) {
      int start = i * length;
  println("initRange() start=" + start + " length=" + length + " !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
      ranges.add(new Range(start, length));
    }
  }
  
  public void initImage(PImage image) {
    image.loadPixels();
    Arrays.fill(image.pixels,  color(0,0,0));
    image.updatePixels();
  }
  
  /*
   * apply the action clip on the result image
   */
  public void addActionClip(Clip clip, PImage image) {
    if(clip==null || !clip.isStarted()) {
      return;
    }
    image.loadPixels(); 
    for (int i=0; i < clip.getFrameLength(); i++) {
       int maskedColor = clip.getPixels(i) & colorMask;
       if (maskedColor != 0) {
         float saturation = saturation(clip.getPixels(i));
         float brightness = brightness(clip.getPixels(i)); 
         if(saturation>30 && brightness>100) { 
           image.pixels[i] = color(0,0,255); //maskedColor;
         }
       }
    }
    image.updatePixels();
  }
  
  /*
   * convert the silhouette to an actual image
   */
  PImage convertSilhouette(SilhouetteFrame frame) {
    PImage image = new PImage(WIDTH, HEIGHT, RGB);
    image.loadPixels();
    for (int i=0; i < frame.size(); i++) {
      if (frame.get(i)) {
        image.pixels[i] = color(0,0,255);       
      } else {
        image.pixels[i] = color(0,0,0); 
      }
    }
    image.updatePixels();
    return image;  
  }
  
  /*
   * apply a blur filter on the given image
   */
  public PImage smoothEdges(PImage image, int smooth) {
    if(smooth > 0) {
        image.filter(BLUR, smooth);
    }
    return image;
  } 
  
  /*
   * remove weird padding from silhouette
   */
  public PImage resizeSilhouette(PImage image) {
    int imageWidth = WIDTH - (silhouettePadding.left + silhouettePadding.right);
    int imageHeigth = HEIGHT - (silhouettePadding.top + silhouettePadding.bottom);
    image = image.get(silhouettePadding.left, silhouettePadding.top, imageWidth, imageHeigth);
    image.resize(WIDTH, HEIGHT);
    return image;
  }
  
  public void addSilhouette(PImage silhouette, PImage image) { 
    int maskedColor = 0;
    image.loadPixels();
    if(shouldMirrorSilouette) {
      // perform an horizontal flip of the silhouette
      int pivot = WIDTH / 2;
      int i=0, j=0;
      for(int y=0; y<HEIGHT; y++) {
        for(int x=0; x<pivot; x++) {
          i = y*WIDTH + x;
          j = y*WIDTH + (WIDTH - 1 - x);
          // handle leftmost pixel
          maskedColor = silhouette.pixels[i] & 0xffffff;
          if (maskedColor > 0) {
            image.pixels[j] = silhouette.pixels[i];       
          }
          // handle rigthmost pixel
          maskedColor = silhouette.pixels[j] & 0xffffff;
          if (maskedColor > 0) {
            image.pixels[i] = silhouette.pixels[j];       
          }
        }
      }
    } else {
      for (int i=0; i < silhouette.pixels.length; i++) {
        maskedColor = silhouette.pixels[i] & 0xffffff;
        if (maskedColor > 0) {
          image.pixels[i] = silhouette.pixels[i];       
        }
      }
    }
    image.updatePixels();
  }
  
  class VideoOverlay implements Callable<Void> {
    SilhouetteClip currentClip;
    SilhouetteClip nextClip;
    PImage image;
    Range range;
    boolean shouldFade;
    float ratio;
    
    VideoOverlay(SilhouetteClip currentClip, SilhouetteClip nextClip, PImage image, Range range, boolean shouldFade, float ratio) {
      this.currentClip = currentClip;
      this.nextClip = nextClip;
      this.image = image;
      this.range = range;
      this.shouldFade = shouldFade;
      this.ratio = ratio;
    }
    
    Void call() {
     //println("VideoOverlay.call() running start=" + range.getStart() + " length=" + range.getLength());
     int start = range.getStart();
     int stop = range.getStop();
     for (int i=start; i <= stop; i++) {      
          int maskedColor = image.pixels[i] & colorMask;
          if (maskedColor != 0) {
            // handle silhouette
            if(!shouldFade) {
              image.pixels[i] = currentClip.getSilhouettePixels(i);
            } else {
              // handle silhouette fade
              color source = currentClip.getSilhouettePixels(i);
              color target = nextClip.getSilhouettePixels(i);        
              image.pixels[i] = lerpColor(source, target, ratio);
            }
          } else {
            // handle background
            if(!shouldFade) {
              image.pixels[i] = currentClip.getBackgroundPixels(i);
            } else {
              // handle background fade
              color source = currentClip.getBackgroundPixels(i);
              color target = nextClip.getBackgroundPixels(i);
              image.pixels[i] = lerpColor(source, target, ratio);
            }
          }
        }
    return null;  
    } 
  }
  
  /*
   * process both silhouette and background video content on the result image
   */
  public boolean overlayVideo(SilhouetteClipManager clipMgr, PImage image) {
    SilhouetteClip currentClip = clipMgr.getCurrent();
    SilhouetteClip nextClip = clipMgr.getNext();
      
    if(!isClipValid(currentClip)) {
      return false; 
    }
    
    int corssfadePos = clipMgr.getCrossfadePosition();
    boolean shouldFade = nextClip!=null && corssfadePos > 0; 
    float ratio = clipMgr.getCrossfadeRatio(currentClip);
  /*
    if(corssfadePos > 0){
      println("crossfade pos:" + clipMgr.getCrossfadePosition()+ " ratio = " + ratio);
    }
  */  
    if(shouldFade && !isClipValid(nextClip)) {
      println("warning: skipping nextClip ...");
      shouldFade = false;
    }
    
    List<VideoOverlay> todo = new ArrayList<VideoOverlay>(ranges.size());
    for(Range range: ranges) {
      VideoOverlay videoOverlay = new VideoOverlay(currentClip, nextClip, image, range, shouldFade, ratio);
        todo.add(videoOverlay);
    }
    image.loadPixels();
    try {
      exec.invokeAll(todo);
    } catch(Exception ex) {
      println("Houston!!!");
    } finally {
      image.updatePixels();
    }
    return true;
  }

  protected boolean isClipValid(SilhouetteClip clip) {
    if(clip==null) {
      return false;
    }
    
    if(clip.hasSilhouette() && resultImage.pixels.length!=clip.getSilhouetteFrameLength()) {
      println("warning: silhouette clip size mismatch: skipping...");
      return false;
    }
    
    if(clip.hasBackground() && resultImage.pixels.length!=clip.getBackgroundFrameLength()) {
      println("warning: background clip size mismatch: skipping...");
      return false;
    }
    
    return true;
  }

  private int threadCount = 1;
}


