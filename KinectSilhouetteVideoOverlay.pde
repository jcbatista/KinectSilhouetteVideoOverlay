import java.util.LinkedList;
//import gab.opencv.*;
//import java.awt.*;
import processing.video.*;
import processing.opengl.*; 
import SimpleOpenNI.*;

import netP5.*;

/*
 * Description:
 *   use the kinect to obtain a silhoutte and overlay video on top
 * 
 *   @Authors: Jean-Claude Batista, 
 *             Comperas (http://itp.nyu.edu/~dbo3/comperas/) (See Authors)
 *             Greg Borenstein
 *
 *   Based on Greg's Book Making things see. Also based on the Comperas source tree
 *      https://github.com/ITPNYU/Comperas/tree/master/KinectBackgroundRemoval
 *
 *   Instructions:
 *     install this on your machine and also the library in processing
 *     http://code.google.com/p/simple-openni/wiki/Installation
 *
 */

SimpleOpenNI kinect;
ClipManager clipMgr; 
ConfigManager configMgr;
ActionManager actionMgr;
OscManager oscManager;
SilhouetteFrameCache silhouetteCache;
boolean shouldResizeSilhouette = false;
boolean shouldOverlayVideo = false;
boolean shouldMirrorSilouette = false;
SilhouettePadding silhouettePadding;

boolean tracking = false; 
int userID;
int[] userMap;
int colorMask = 0xffffff; // skip alpha channel
int smooth = 0;

// declare our images 
PImage resultImage;

int KINECT_WIDTH  = 640;
int KINECT_HEIGHT = 480;
int WIDTH  = 640;  // WIDTH = 1280;
int HEIGHT = 480;  // HEIGHT = 720;

NetAddress myRemoteLocation;

IntVector userList;

//OpenCV openCV;

// Movie requires a Processing applet reference, therefore it needs to remain in the root class
Movie globalLoadMovie(String filename) {
  return new Movie(this, dataPath("") + "/clips/" + filename);
}

void setup() {
  size(WIDTH, HEIGHT);
  configMgr = new ConfigManager();
  configMgr.listClips();
  
  silhouetteCache = new SilhouetteFrameCache(configMgr.getSilhouetteCacheSettings());
  actionMgr = new ActionManager(configMgr.getActionSettings());
  shouldOverlayVideo = configMgr.overlayVideo();
  shouldResizeSilhouette = configMgr.resizeSilhouette();
  shouldMirrorSilouette = configMgr.mirrorSilhouette();
  silhouettePadding = configMgr.getSilhouettePadding();
  
  clipMgr = new ClipManager(this);
  LinkedList<ClipInfo> clipInfoList = configMgr.getClips();
  clipMgr.add(clipInfoList);
  
  kinect = new SimpleOpenNI(this, SimpleOpenNI.RUN_MODE_MULTI_THREADED);
  if(kinect.isInit() == false) {  
     println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
     exit();
     return;  
  }
  
  smooth = configMgr.getSmoothSilhouette(); // silhouette smoothing ration 
  
  oscManager = new OscManager(configMgr.getOscSettings());

  // enable depthMap generation 
  kinect.enableDepth();
   
  // enable skeleton generation for all joints
  kinect.enableUser();

  // enable color image from the Kinect
  kinect.enableRGB();
  //enable the finding of users but dont' worry about skeletons

  // turn on depth/color alignment
  kinect.alternativeViewPointDepthToImage();

  userList = new IntVector();
  //openCV = new OpenCV(this, KINECT_WIDTH, KINECT_HEIGHT);
}

// TODO refactor this
int maxDumpCount = 1000;
int totalDumpCount = 0;
void dumpImage(PImage image, int nbPixels) {
  if(maxDumpCount <= totalDumpCount) {
    return;
  }
  println("dumping " + nbPixels + "pixels");
  for (int i=0; i < nbPixels /*resultImage.pixels.length*/; i++) {
    if(totalDumpCount < maxDumpCount) {
      println(hex(resultImage.pixels[i]));
      totalDumpCount++;
    }
  }
}

void convertPosTo720p(PVector position) {
  position.x = position.x * WIDTH / KINECT_WIDTH;
  position.y = position.y * HEIGHT/ KINECT_HEIGHT;
}

void processCenterOfMass()
{
  kinect.getUsers(userList);
  long nbUsers = userList.size();

  for(int i=0; i<nbUsers; i++) {
    int userId = userList.get(i);
    PVector position = new PVector();
    kinect.getCoM(userId, position); // CoM <= Center Of Mass
    kinect.convertRealWorldToProjective(position, position);
    
    if(!Float.isNaN(position.x)) {
      // convertPosTo720p(position);  
      //println("user=" + userId + " of nbUsers=" + nbUsers + " position=" + position.x + "," + position.y + "," + position.z);
      if(configMgr.showCenterOfMass()) {
        fill(255, 0, 0);
        ellipse(position.x, position.y, 25, 25);
      }
      
      oscManager.send(clipMgr.getCurrentIndex(), i, position);
    }
  }
}

boolean hasUserMap = false;
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
      println("Starting using Kinect user map frames ...");
      usingFrameCache = false;
    } 
    
    frame = new SilhouetteFrame();
    for (int i = 0; i < userMap.length; i++) {
      // if the pixel is part of the user
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
      frame = silhouetteCache.getCurrent();
    }
  }
  return frame;
}

void addActionClip(Clip clip) {
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

Clip previousClip = null; // TODO remove

boolean overlayVideo() {
  Clip clip = clipMgr.getCurrent();
  boolean hasBackground = clip.hasBackground();
  boolean hasSilhouette = clip.hasSilhouette();
  
  // TODO get rid of overlay mode (DEPRECATED)
  OverlayMode overlayMode =  clipMgr.getCurrentOverlayMode();
  
  if(clip!=previousClip) {
    previousClip = clip;
    if(clip==null) {
      println("clip has ended!!!");
    }
  }
  
  if(clip==null) {
    return false; // no clip to overlay
  }
  
  if(hasSilhouette && resultImage.pixels.length!=clip.silhouetteMovie.pixels.length) {
    println("warning: silhouette clip size mismatch: skipping...");
    return false;
  }
  
  if(hasBackground && resultImage.pixels.length!=clip.backgroundMovie.pixels.length) {
    println("warning: background clip size mismatch: skipping...");
    return false;
  }
  
  for (int i=0; i < resultImage.pixels.length; i++) {       
    int maskedColor = resultImage.pixels[i] & colorMask;
    if (maskedColor != 0) {
      resultImage.pixels[i] = hasSilhouette ? clip.silhouetteMovie.pixels[i] : color(0,0,0);
    } else {
      resultImage.pixels[i] = hasBackground ? clip.backgroundMovie.pixels[i] : color(0,0,0);
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

void smoothEdges(PImage image) {
  if(smooth > 0) {
    image.filter(BLUR, smooth);
  }
}

/*
 * convert the silhouette to an image
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

void draw() {
  //try {
    kinect.update();
    if (tracking) {
      if(shouldOverlayVideo && !clipMgr.isStarted()) {
        clipMgr.start();
      }
      
      //ask kinect for bitmap of user pixels
      loadPixels();
     
      //create a buffer image to work with instead of using sketch pixels
      resultImage = new PImage(WIDTH, HEIGHT, RGB); 
       
      if(actionMgr.shouldPlay()) {
        addActionClip(actionMgr.getCurrent());  
      } else {
        // initialize the result image
        for (int i=0; i < WIDTH * HEIGHT; i++) {
           resultImage.pixels[i] = color(0,0,0);
        }
      }
                   
      SilhouetteFrame silhouetteFrame = getSilhouette(); // should return a frame
      PImage silhouette = convertSilhouette(silhouetteFrame);
      if(silhouette!=null) {
        if(shouldResizeSilhouette) {
          silhouette = resizeSilhouette(silhouette); 
        }

        silhouette.updatePixels();
        addSilhouette(silhouette);
      }
      
      smoothEdges(resultImage); 
              
      // dumpImage(resultImage, 1000);

      //  don't display an image if video overlay failed
      if(shouldOverlayVideo && !overlayVideo()) {
         return; 
      }
      
      resultImage.updatePixels();
      image(resultImage, 0, 0);

      processCenterOfMass();
      
    } else {
      // get the Kinect color image
      PImage rgbImage = kinect.rgbImage();
      image(rgbImage, 0, 0);
    }
  /*
  } catch (Exception e) {
    println("Houston, we have a problem !!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    e.printStackTrace();
    exit();
  }
  */
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

private SilhouetteFrame previousFrame = null;
private boolean usingFrameCache = true;
