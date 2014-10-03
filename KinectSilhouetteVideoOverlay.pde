//import gab.opencv.*;
import processing.video.*;
//import java.awt.*;
import processing.video.*;
import processing.opengl.*; 
import SimpleOpenNI.*;

import oscP5.*;
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

boolean tracking = false; 
int userID;
int[] userMap;
int colorMask = 0xffffff; // skip alpha channel

// declare our images 
PImage resultImage;

int KINECT_WIDTH = 640;
int KINECT_HEIGHT = 480;
int WIDTH = 640;  // WIDTH = 1280;
int HEIGHT = 480; //HEIGHT = 720;

Movie actionClip;

OscP5 oscP5;
NetAddress myRemoteLocation;

IntVector userList;

//OpenCV openCV;

String oscAdress = "127.0.0.1";
int oscServerPort = 13000;
int oscClientPort = 12000;

void oscSend(PVector position) {
  // TODO need to add another field to identify the user ...
  // and one to identify which Kinect we're using
  OscMessage msg = new OscMessage("/pos");
  msg.add(position.x);
  msg.add(position.y);
  msg.add(position.z);
  oscP5.send(msg, myRemoteLocation); 
}

Movie LoadMovie(String filename) {
  return new Movie(this, dataPath("") + "/clips/" + filename);
}

void setup() {
  size(WIDTH, HEIGHT);
  configMgr = new ConfigManager();
  configMgr.listClips();
  
  clipMgr = new ClipManager(this);
  clipMgr.add(configMgr.getClips());
  
  actionClip = LoadMovie(configMgr.getActionClips().get(0)); // grab the fist action clip: TODO add support for multiple clips
  actionClip.loop();
  
  kinect = new SimpleOpenNI(this);
  if(kinect.isInit() == false) {  
     println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
     exit();
     return;  
  }
  
  //start oscP5, listening for incoming messages at port 7000
  oscP5 = new OscP5(this, oscServerPort, OscP5.UDP);
  myRemoteLocation = new NetAddress(oscAdress, oscClientPort);

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

void processCenterOfMass(boolean show)
{
  kinect.getUsers(userList);
  long nbUsers = userList.size();

  for(int i=0; i<nbUsers; i++) {
    int userId = userList.get(i);
    PVector position = new PVector();
    kinect.getCoM(userId, position); // CoM <= Center Of Mass
    kinect.convertRealWorldToProjective(position, position);
    
    if(!Float.isNaN(position.x)) {
      convertPosTo720p(position);  
      //println("user=" + userId + " of nbUsers=" + nbUsers + " position=" + position.x + "," + position.y + "," + position.z);
      if(show) {
        fill(255, 0, 0);
        ellipse(position.x, position.y, 25, 25);
      }
      oscSend(position);
    }
  }
}

PImage getKinectSilhouette() {
   //create a buffer image to work with instead of using sketch pixels
    PImage image = new PImage(KINECT_WIDTH, KINECT_HEIGHT, RGB); 
    for (int i =0; i < userMap.length; i++) {
      // if the pixel is part of the user
      if (userMap[i] != 0) {
        // set the pixel to the color pixel
        image.pixels[i] = color(0,0,255);
      } else {
        //set it to the background
        image.pixels[i] = color(0,0,0); // backgroundImage.pixels[i];
      }
    }
    
    //update the pixel from the inner array to image
    image.updatePixels();
    
    // smooth edges
    image.filter(BLUR, 1);
    //openCV.inpaint(image);
    
    // image.resize(WIDTH, HEIGHT);  //TODO SKIP RESIZE
    return image;
}

void addActionClip(Movie clip) {
  for (int i=0; i < clip.pixels.length; i++) {
     int maskedColor = clip.pixels[i] & colorMask;
     if (maskedColor != 0) {
       float saturation = saturation(clip.pixels[i]);
       float brightness = brightness(clip.pixels[i]); 
       if(saturation>30 && brightness>100) { 
         resultImage.pixels[i] = color(0,0,255); //maskedColor;
       }
     }
  }
  resultImage.updatePixels();
}

Clip previousClip = null; // TODO remove

void overlayVideo() {
  Clip clip = clipMgr.getCurrent();
  
  if(clip!=previousClip) {

    previousClip = clip;
    if(clip==null) println("clip has ended!!!");
    
  }
  
  if(clip==null) {
    return; // no clip to overlay
  }
  
  if(resultImage.pixels.length!=clip.movie.pixels.length) {
    println("Warning: clip size mismatch: skipping...");
    return;
  }
  
  for (int i=0; i < resultImage.pixels.length; i++) {       
    int maskedColor = resultImage.pixels[i] & colorMask;
    if (maskedColor != 0) {
      resultImage.pixels[i] = clip.movie.pixels[i];
    } 
  }
  
  resultImage.updatePixels();
}

void addImage(PImage image) {
    for (int i=0; i < image.pixels.length; i++) {
     if (image.pixels[i] != 0) {
       resultImage.pixels[i] = image.pixels[i];       
     }
  }
  resultImage.updatePixels();
}

void draw() {
  //try {
    kinect.update();
    if (tracking) {
      if(!clipMgr.isStarted()) {
        clipMgr.start();
      }
      
      //ask kinect for bitmap of user pixels
      loadPixels();
      userMap = kinect.userMap();
     
      //create a buffer image to work with instead of using sketch pixels
      resultImage = new PImage(WIDTH, HEIGHT, RGB); 
          
      // TODO: action clips need to be 640x480 ...
      //addActionClip(actionClip);  
      // TODO REMOVE START
      // instead initialize the image with zeros...
      for (int i=0; i < WIDTH * HEIGHT; i++) {
         resultImage.pixels[i]=color(0,0,0);
      }
      // TODO REMOVE END
      
      resultImage.updatePixels();
             
      PImage silhouette = getKinectSilhouette();
      addImage(silhouette);

      // dumpImage(resultImage, 1000);

      overlayVideo();
      
      image(resultImage, 0, 0);
      // filter(BLUR,1);
      processCenterOfMass(false);

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

void onNewUser(SimpleOpenNI curContext, int userId)
{
 userID = userId;
  tracking = true;
  println("tracking");
  //curContext.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curContext, int userId)
{
  println("onLostUser - userId: " + userId);
}

void onVisibleUser(SimpleOpenNI curContext, int userId)
{
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
