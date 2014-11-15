import javax.swing.JFrame;
import java.util.LinkedList;
import processing.video.*;
import processing.opengl.*; 
import SimpleOpenNI.*;
import netP5.*;

/*
 * Description:
 *
 *   Concept for an interactive art installation project where people in the scene are used as a canvas 
 *   on which video imagery gets overlayed in realtime.
 * 
 *   @Authors: Jean-Claude Batista
 *
 *   Based on Greg's Book Making things see. Also based on the Comperas source tree
 *      https://github.com/ITPNYU/Comperas/tree/master/KinectBackgroundRemoval
 *
 *   Instructions:
 *     install this on your machine and also the library in processing
 *     http://code.google.com/p/simple-openni/wiki/Installation
 *
 */

/*
 * constants
 */
final int KINECT_WIDTH  = 640;
final int KINECT_HEIGHT = 480;
final int WIDTH  = 640;  // WIDTH = 1280;
final int HEIGHT = 480;  // HEIGHT = 720;
final int colorMask = 0xffffff; // skip alpha channel

void setup() {  
  
  // set black background for full screen mode
  ((JFrame) frame).getContentPane().setBackground(java.awt.Color.BLACK);  
  
  initComponents();
  initConfigSettings();
  initKinect();
    
  // init silhouette related videos  
  LinkedList<SilhouetteClipInfo> clipList = configMgr.getClips();
  clipMgr.add(clipList); 
  
  clock.setDuration(clipMgr.getTotalDuration());
  clock.setGranularity(1000); // 1 second
  actionMgr.definePeriod(clock.getDuration());
  
  // display all the clips available for playback
  configMgr.listClips();
  
  // misc stuff
  font = createFont("Arial", 16, true); // Arial, 16 point, anti-aliasing on 
  
  println("crossfade setting = " + configMgr.getCrossfade());
  scaledWidth = configMgr.getScaleWidth();
  scaledHeight = configMgr.getScaleHeight();
  size(scaledWidth, configMgr.getScaleHeight());
}

void initKinect() {
  kinect = new SimpleOpenNI(this, SimpleOpenNI.RUN_MODE_MULTI_THREADED);
  if(kinect.isInit() == false) {  
     println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
     exit(); 
  } 

  // enable depthMap generation 
  kinect.enableDepth();
   
  // enable skeleton generation for all joints
  kinect.enableUser();

  // enable color image from the Kinect
  kinect.enableRGB();
  //enable the finding of users but dont' worry about skeletons

  // turn on depth/color alignment
  kinect.alternativeViewPointDepthToImage();
  
  // list of people in the scene
  userList = new IntVector();
}

void initComponents() {  
  clock = new CyclicalClock();
  configMgr = new ConfigManager();  
  oscManager = new OscManager(configMgr.getOscSettings());  
  silhouetteCache = new SilhouetteFrameCache(configMgr.getSilhouetteCacheSettings());   
  clipMgr = new SilhouetteClipManager(this);
  actionMgr = new ActionClipManager(clock, configMgr.getActionClipSettings());  
}

void initConfigSettings() {
  shouldOverlayVideo = configMgr.overlayVideo();
  shouldResizeSilhouette = configMgr.resizeSilhouette();
  shouldMirrorSilouette = configMgr.mirrorSilhouette();
  silhouettePadding = configMgr.getSilhouettePadding();
  smooth = configMgr.getSmoothSilhouette(); // silhouette smoothing ratio
}

void draw() {    
    kinect.update();
    if (tracking) {
      if(shouldOverlayVideo && !clipMgr.isStarted()) {
        clipMgr.start();
        actionMgr.start();
        clock.start();
      }
                
      loadPixels();
     
      // create a buffer image that will contain the rendered content
      resultImage = new PImage(WIDTH, HEIGHT, RGB); 
              
      if(actionMgr.shouldPlay()) {
        actionMgr.next();
        Clip actionClip = actionMgr.getCurrent();
        addActionClip(actionClip);  
      } else {
        initResultImage();
      }
                                      
      processSilhouette();
              
      //  don't display an image if video overlay failed
      if(shouldOverlayVideo && !overlayVideo()) {
         return; 
      }
      
      // display rendered image
      resultImage.updatePixels();
      image(resultImage, 0, 0, scaledWidth, scaledHeight);

      processCenterOfMass();      
      drawElapsedTime();
      clock.tick();      
    } else {
      // get the Kinect color image
      PImage rgbImage = kinect.rgbImage();
      image(rgbImage, 0, 0, scaledWidth, scaledHeight);
    }
}

void processSilhouette() {
  SilhouetteFrame silhouetteFrame = getSilhouette();
  PImage silhouette = convertSilhouette(silhouetteFrame);
  if(silhouette!=null) {
    if(shouldResizeSilhouette) {
      silhouette = resizeSilhouette(silhouette); 
    }
    silhouette.updatePixels();
    addSilhouette(silhouette);
  }
  smoothEdges(resultImage); 
}

void displayCenterOfMass(PVector position) {
  if(configMgr.showCenterOfMass()) {
    fill(255, 0, 0);
    // adjust position in re-scaled image
    float posx = position.x * scaledWidth / KINECT_WIDTH;
    float posy = position.y * scaledHeight/ KINECT_HEIGHT;
    ellipse(position.x, position.y, 25, 25);
  }
}

void processCenterOfMass()
{  
  if(usingFrameCache) {
    // were using cached frames, send the cached meta data using OSC
    SilhouetteFrame frame = silhouetteCache.getCurrent();
    for(MetaData metaData: frame.getMetaDataList()) {
      oscManager.send(clipMgr.getCurrentIndex(), metaData.totalUsers,  metaData.userIndex, metaData.position, actionMgr.getCurrentIndex());
      displayCenterOfMass(metaData.position);
    }
  } else {
    kinect.getUsers(userList);
    int nbUsers = int(userList.size());
  
    for(int i=0; i<nbUsers; i++) {
      int userId = userList.get(i);
      PVector position = new PVector();
      kinect.getCoM(userId, position); // CoM <= Center Of Mass
      kinect.convertRealWorldToProjective(position, position);
      
      if(!Float.isNaN(position.x)) {
        // println("user=" + userId + " of nbUsers=" + nbUsers + " position=" + position.x + "," + position.y + "," + position.z);
        displayCenterOfMass(position);
        
        oscManager.send(clipMgr.getCurrentIndex(), nbUsers, i, position, actionMgr.getCurrentIndex());
        SilhouetteFrame frame = silhouetteCache.getLast();
        if(frame!=null) {
          frame.addMetaData(nbUsers, i, position);
        }
      }
    }
  }
}

/*
 * retrieves a silhouette frame ( a bitset where all the pixel that represent the silhouette are set to true )
 */
SilhouetteFrame getSilhouette() { 
  SilhouetteFrame frame =  null;
  userMap = kinect.userMap();
  kinect.getUsers(userList);
  long userCount = userList.size();
  if(!hasUserMap && userCount > 0) {
    println("actually tracking users !!!!!!!!!!!!!!!!!!!!");
    hasUserMap = true;
  } else if(hasUserMap && userCount == 0) {
    println("no longer tracking users ###################");
    hasUserMap = false;
  }

  if(userMap.length > 0 && userCount > 0) {
       
    if(usingFrameCache) {
      println("starting using Kinect user map frames ...");
      usingFrameCache = false;
    } 
    
    // store silhouette frame in cache
    frame = new SilhouetteFrame();
    for (int i = 0; i < userMap.length; i++) {
      if (userMap[i] != 0) {
        frame.set(i, true);
      } else {
        frame.set(i, false);
      }
    }
    silhouetteCache.add(frame);    
  } else {
    // if the cache has enough frames from playback get the current one
    if(silhouetteCache.canPlayback()) {
      if(!usingFrameCache) {
        println("starting using Silhouette cached frames ...");
        usingFrameCache = true;
      } 
      silhouetteCache.next();
      frame = silhouetteCache.getCurrent();
    }
  }
  return frame;
}

void initResultImage() {
  for (int i=0; i < WIDTH * HEIGHT; i++) {
   resultImage.pixels[i] = color(0,0,0);
  }
}

/*
 * apply the action clip on the result image
 */
void addActionClip(Clip clip) {
  if(clip==null || !clip.isStarted()) {
    return;
  }
  for (int i=0; i < clip.movie.pixels.length; i++) {
     int maskedColor = clip.movie.pixels[i] & colorMask;
     if (maskedColor != 0) {
       float saturation = saturation(clip.movie.pixels[i]);
       float brightness = brightness(clip.movie.pixels[i]); 
       if(saturation>30 && brightness>100) { 
         resultImage.pixels[i] = color(0,0,255); //maskedColor;
       }
     }
  }
  resultImage.updatePixels();
}

float getCrossfadeRatio(Clip clip) {
  return clipMgr.getCrossfadePosition() / (frameRate * clip.getCrossfade()/1000);
}

boolean isClipValid(SilhouetteClip clip) {
  if(clip==null) {
    return false;
  }
  
  if(clip.hasSilhouette() && resultImage.pixels.length!=clip.silhouetteMovie.pixels.length) {
    println("warning: silhouette clip size mismatch: skipping...");
    return false;
  }
  
  if(clip.hasBackground() && resultImage.pixels.length!=clip.backgroundMovie.pixels.length) {
    println("warning: background clip size mismatch: skipping...");
    return false;
  }
  
  return true;
}

/*
 * process both silhouette and background video content on the result image
 */
boolean overlayVideo() {
  SilhouetteClip currentClip = clipMgr.getCurrent();
  SilhouetteClip nextClip = clipMgr.getNext();
    
  if(!isClipValid(currentClip)) {
    return false; 
  }
  
  int corssfadePos = clipMgr.getCrossfadePosition();
  boolean shouldFade = nextClip!=null && corssfadePos > 0 ; 
  float ratio = getCrossfadeRatio(currentClip);
/*
  if(corssfadePos > 0){
    println("crossfade pos:" + clipMgr.getCrossfadePosition()+ " ratio = " + ratio);
  }
*/  
  if(shouldFade && !isClipValid(nextClip)) {
    println("warning: skipping nextClip ...");
    shouldFade = false;
  }
  
  for (int i=0; i < resultImage.pixels.length; i++) {       
    int maskedColor = resultImage.pixels[i] & colorMask;
    if (maskedColor != 0) {
      // handle silhouette
      if(!shouldFade) {
        resultImage.pixels[i] = currentClip.hasSilhouette() ? currentClip.silhouetteMovie.pixels[i] : color(0,0,0);
      } else {
        // handle fade
        color source = currentClip.hasSilhouette() ? currentClip.silhouetteMovie.pixels[i] : color(0,0,0);
        color target = nextClip.hasSilhouette() ? nextClip.silhouetteMovie.pixels[i] : color(0,0,0);        
        resultImage.pixels[i] = lerpColor(source, target, ratio);
      }
    } else {
      // handle background
      if(!shouldFade) {
        resultImage.pixels[i] = currentClip.hasBackground() ? currentClip.backgroundMovie.pixels[i] : color(0,0,0);
      } else {
        // handle fade
        color source = currentClip.hasBackground() ? currentClip.backgroundMovie.pixels[i] : color(0,0,0);
        color target = nextClip.hasBackground() ? nextClip.backgroundMovie.pixels[i] : color(0,0,0);
        resultImage.pixels[i] = lerpColor(source, target, ratio);
      }
    }
  }
  
  resultImage.updatePixels();
  
  return true;
}

/*
 * remove weird padding from silhouette
 */
PImage resizeSilhouette(PImage image) {
  int imageWidth = WIDTH - (silhouettePadding.left + silhouettePadding.right);
  int imageHeigth = HEIGHT - (silhouettePadding.top + silhouettePadding.bottom);
  image = image.get(silhouettePadding.left, silhouettePadding.top, imageWidth, imageHeigth);
  image.resize(WIDTH, HEIGHT);
  return image;
}

/*
 * apply a blur filter on the given image
 */
void smoothEdges(PImage image) {
  if(smooth > 0) {
    image.filter(BLUR, smooth);
  }
}

/*
 * convert the silhouette to an actual image
 */
PImage convertSilhouette(SilhouetteFrame frame) {
  if(frame==null) {
    // minimize this log message
    if(previousFrame!=null) {
       //println("warning. convertSilhouette(): got a null frame, ignoring ...");
    }
    return null;
  }
  previousFrame = frame;
  PImage image = new PImage(WIDTH, HEIGHT, RGB); 
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
 * apply the silhouette on the resultImage
 */
void addSilhouette(PImage silhouette) {
  int maskedColor = 0;
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
          resultImage.pixels[j] = silhouette.pixels[i];       
        }
        // handle rigthmost pixel
        maskedColor = silhouette.pixels[j] & 0xffffff;
        if (maskedColor > 0) {
          resultImage.pixels[i] = silhouette.pixels[j];       
        }
      }
    }
  } else {
    for (int i=0; i < silhouette.pixels.length; i++) {
      maskedColor = silhouette.pixels[i] & 0xffffff;
      if (maskedColor > 0) {
        resultImage.pixels[i] = silhouette.pixels[i];       
      }
    }
  }
}

void drawElapsedTime() {
  if(!configMgr.showTime()) {
    return;
  }
  textFont(font, 36);                
  fill(color(255,0,0));
  String fps = String.format("%.01f", frameRate);
  String output = "Elapsed: " + str(clock.getCurrentTimeInSec()) + "  fps: " + fps;
  text(output , 10, 35);  
}

// Called every time a new frame is available to read
void movieEvent(Movie m) {
  m.read();
}

void onNewUser(SimpleOpenNI curContext, int userId) {
 userID = userId;
  tracking = true;
  println("tracking");
  //curContext.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curContext, int userId) {
  println("onLostUser - userId: " + userId);
}

void onVisibleUser(SimpleOpenNI curContext, int userId) {
  //println("onVisibleUser - userId: " + userId);
}

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  /* print the address pattern and the typetag of the received OscMessage */
  /*
  print("### received an osc message.");
  print(" addrpattern: "+theOscMessage.addrPattern());
  println(" typetag: "+theOscMessage.typetag());
  */
}

// The Movie object requires a Processing applet reference, therefore it needs to remain in the main class
Movie globalLoadMovie(String filename) {
  return new Movie(this, dataPath("") + "/clips/" + filename);
}

/*
 * Members
 */
private int scaledHeight = KINECT_HEIGHT;
private int scaledWidth = KINECT_WIDTH;
private Clock clock;
private SimpleOpenNI kinect; // Kinect API
private boolean hasUserMap = false;
private SilhouetteClipManager clipMgr; 
private ConfigManager configMgr;
private ActionClipManager actionMgr;
private OscManager oscManager;
private SilhouetteFrameCache silhouetteCache;

private boolean shouldResizeSilhouette = false;
private boolean shouldOverlayVideo = false;
private boolean shouldMirrorSilouette = false;
private SilhouettePadding silhouettePadding;

private boolean tracking = false; 
private int userID;
private int[] userMap;

private int smooth = 0;
private PImage resultImage;
private NetAddress myRemoteLocation;
private IntVector userList;
private PFont font;
private SilhouetteFrame previousFrame = null;
private boolean usingFrameCache = true;

