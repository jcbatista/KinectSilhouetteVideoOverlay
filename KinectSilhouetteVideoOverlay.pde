import javax.swing.JFrame;
import java.util.Map;
import java.util.Map.Entry;
import java.util.LinkedList;
import java.util.Arrays;
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
final int LIVE = 1;
final int CACHED = 0;
void setup() {  
  application = this;
  println("Java version = " + System.getProperty("java.version"));
    
  // set black background for full screen mode
  ((JFrame) frame).getContentPane().setBackground(java.awt.Color.BLACK);  
  
  configMgr = new ConfigManager();  
  scaledWidth = configMgr.getScaleWidth();
  scaledHeight = configMgr.getScaleHeight();  
  
  // Note: init order is important!
  initConfigSettings();
  initComponents();
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
}

void initKinect() {
  if(!useKinect) {
    return;
  }
  
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
    
  userManager = new UserManager(kinect);
}

void initComponents() {  
  clock = new CyclicalClock();
  oscManager = new OscManager(configMgr.getOscSettings());  
  silhouetteCache = new SilhouetteFrameCache(configMgr.getSilhouetteCacheSettings());   
  clipMgr = new SilhouetteClipManager();
  actionMgr = new ActionClipManager(clock, configMgr.getActionClipSettings());  
  renderer = new RendererFactory(scaledWidth, scaledHeight).create(useGpu);
}

void initConfigSettings() {
  useKinect = configMgr.useKinect();
  useGpu = configMgr.useGpu();
  shouldOverlayVideo = configMgr.overlayVideo();
  shouldResizeSilhouette = configMgr.resizeSilhouette();
  shouldMirrorSilouette = configMgr.mirrorSilhouette();
  silhouettePadding = configMgr.getSilhouettePadding();
  smooth = configMgr.getSmoothSilhouette(); // silhouette smoothing ratio
}

void draw() {    
  if(useKinect) {
    kinect.update();
  }
  if (useKinect? tracking: true) {
    if(shouldOverlayVideo && !clipMgr.isStarted()) {
      clipMgr.start();
      actionMgr.start();
      clock.start();
    }
                   
    // create a buffer image that will contain the rendered content
    resultImage = new PImage(WIDTH, HEIGHT, RGB); 
            
    if(actionMgr.shouldPlay()) {
      actionMgr.next();
      Clip actionClip = actionMgr.getCurrent();
      renderer.addActionClip(actionClip, resultImage);
    } else {
      renderer.initImage(resultImage);
    }
                                    
    processSilhouette();
    
    // blur silhouette (including silhouettes in action clips)
    resultImage = renderer.smoothEdges(resultImage, smooth);
                  
    if(shouldOverlayVideo) {
      //  don't display an image if video overlay failed
      boolean success = renderer.overlayVideo(clipMgr, resultImage);
      if(!success) {
        return; 
      }
    }
     
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
  if(!useKinect) {
    return;
  }

  SilhouetteFrame silhouetteFrame = getSilhouetteFrame();
  PImage silhouette = renderer.convertSilhouette(silhouetteFrame);
  if(silhouette!=null) {
    if(shouldResizeSilhouette) {
      silhouette = renderer.resizeSilhouette(silhouette);
    }
    renderer.addSilhouette(silhouette, resultImage);
  }
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

void processLiveUserPositionData() {  
    IntVector userList = userManager.getUsers();
    Map<Integer, PVector> userPositions = userManager.getUserPositions();
    int userCount = userPositions.size();
    oscManager.send(clipMgr.getCurrentIndex(), userCount, actionMgr.getCurrentIndex(), LIVE);
    for(Entry<Integer, PVector> userPosition :userPositions.entrySet()) {
      int userId = userPosition.getKey();
      PVector position = userPosition.getValue();        
      displayCenterOfMass(position);
      oscManager.sendUserIndex(userId, position);
      SilhouetteFrame frame = silhouetteCache.getLast();
      if(frame!=null) {
        frame.addMetaData(userCount, userId, position);
      }
    }
}

void handleFocusedUser() {
  int userId = userManager.getFocusedUser();
  if(userId!=-1 && userId!=focusedUser) {
    focusedUser = userId;
    oscManager.sendFocusedUserIndex(focusedUser);
    println("***** focused user=" + focusedUser);
  }    
}

void processCenterOfMass()
{  
  if(!useKinect || clipMgr.getCurrent()==null) {
    return;
  }
  
  if(silhouetteCache.isStarted()) {
    // were using cached frames, send the cached meta data using OSC
    SilhouetteFrame frame = silhouetteCache.getCurrent();
    if(frame!=null && frame.getMetaDataList().size()>0) {    
      oscManager.send(clipMgr.getCurrentIndex(), 0, actionMgr.getCurrentIndex(), CACHED);
      for(MetaData metaData: frame.getMetaDataList()) {
        oscManager.sendUserIndex(metaData.userIndex, metaData.position);
        displayCenterOfMass(metaData.position);
      }
    } else {
      if(frame==null) {
        println("warning: invalid cached SilhouetteFrame received ...");
      }
      // cached frame has not metadata
      oscManager.send(clipMgr.getCurrentIndex(), 0, actionMgr.getCurrentIndex(), CACHED);
    }
  } else {
    processLiveUserPositionData();
    handleFocusedUser();
  }
}

/*
 * retrieves a silhouette frame ( a bitset where all the pixel that represent the silhouette are set to true )
 */
SilhouetteFrame getSilhouetteFrame() { 
  SilhouetteFrame frame =  null;
  userMap = kinect.userMap();
  IntVector userList = userManager.getUsers();
  long userCount = userList.size();
  if(!hasUserMap && userCount > 0) {
    println("actually tracking users !!!!!!!!!!!!!!!!!!!!");
    hasUserMap = true;
  } else if(hasUserMap && userCount == 0) {
    println("no longer tracking users ###################");
    hasUserMap = false;
  }

  if(userMap.length > 0 && userCount > 0) {       
    if(silhouetteCache.isStarted()) {      
      silhouetteCache.stop();
      println("starting using Kinect user map frames ...");
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
      if(!silhouetteCache.isStarted()) {        
        silhouetteCache.start();
      } 
      silhouetteCache.next();
      frame = silhouetteCache.getCurrent();
    }
  }
  return frame;
}

/*
 * apply the silhouette on the resultImage
 */

void drawElapsedTime() {
  if(!configMgr.showTime()) {
    return;
  }
  textFont(font, 36);                
  fill(color(255,0,0));
  String fps = String.format("%.01f", frameRate);
  String focusedUser = "";
  if(useKinect)
  {
    int user = userManager.getFocusedUser();
    if(user!=-1)
      focusedUser = String.format(" user:%d", user);
  } 
  String output = "Elapsed: " + str(clock.getCurrentTimeInSec()) + focusedUser + " fps: " + fps;
  
  output += " " + userManager.dumpOrderUserList() + " " + userManager.dumpUserMapKeys();
  
  text(output , 10, 35);  
}

// Called every time a new frame is available to read
void movieEvent(Movie movie) {
  movie.read();
  movie.loadPixels();
}

void captureEvent(Capture captureDevice) {
  captureDevice.read();
  captureDevice.loadPixels();
}

void onNewUser(SimpleOpenNI curContext, int userId) {
  userID = userId;
  tracking = true;

  //curContext.startTrackingSkeleton(userId);
  
  oscManager.sendNewUserIndex(userId);    
  userManager.add(userId);
  int focusedUser = userManager.getFocusedUser();
  if(focusedUser!=-1) {
    oscManager.sendFocusedUserIndex(focusedUser);
  }
  println("**************** tracking:" + userId);
}

void onLostUser(SimpleOpenNI curContext, int userId) {
  oscManager.sendLostUserIndex(userId);
  userManager.remove(userId);
  println("**************** onLostUser - userId: " + userId);
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

PApplet getApp() {
  return application;
}

Capture getCaptureDevice() {
  if(capture!=null) {
    return capture;
  }
  try { 
    capture = new Capture(application, KINECT_WIDTH, KINECT_HEIGHT);
  } catch(Exception ex) {
    println("warning: coundn't initialize capture device");
  }
  return capture;
}

/*
 * Members
 */
private PApplet application;
private Renderer renderer = null;
private Capture capture = null;
private int scaledHeight = KINECT_HEIGHT;
private int scaledWidth = KINECT_WIDTH;
private Clock clock;
private SimpleOpenNI kinect; // Kinect API
private boolean useKinect = false;
private boolean useGpu = false;
private boolean hasUserMap = false;
private SilhouetteClipManager clipMgr; 
private ConfigManager configMgr;
private ActionClipManager actionMgr;
private OscManager oscManager;
private SilhouetteFrameCache silhouetteCache;
private UserManager userManager;
private boolean shouldResizeSilhouette = false;
private boolean shouldOverlayVideo = false;
private boolean shouldMirrorSilouette = false;
private SilhouettePadding silhouettePadding;

private boolean tracking = false; 
private int userID;
private int[] userMap;

private int smooth = 0;
private PImage resultImage;

private PFont font;
private SilhouetteFrame previousFrame = null;
private int focusedUser = -1;

