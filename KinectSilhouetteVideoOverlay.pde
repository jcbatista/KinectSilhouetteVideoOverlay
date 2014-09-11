import processing.video.*;
import processing.opengl.*; 
import SimpleOpenNI.*;

import oscP5.*;
import netP5.*;

/*
 * Description:
 *   use the kinect to obtain a silhoutte and overlay video on top
 *   display the result in 720p (1280x720)
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

boolean tracking = false; 
int userID; int[] userMap; 

// declare our images 
PImage resultImage;
Movie myMovie;

int KINECT_WIDTH = 640;
int KINECT_HEIGHT = 480;
int WIDTH = 1280;
int HEIGHT = 720;

int maxLenght = WIDTH * HEIGHT;
//String videofile = "clips/test.mov";
String videofile = "clips/sept 2 national.mov";

OscP5 oscP5;
NetAddress myRemoteLocation;

IntVector userList;

String oscAdress = "127.0.0.1";
int oscServerPort = 13000;
int oscClientPort = 12000;

void oscSend(PVector position) {
  OscMessage msg = new OscMessage("/pos");
  msg.add(position.x);
  msg.add(position.y);
  msg.add(position.z);
  oscP5.send(msg, myRemoteLocation); 
}

void setup() {
  size(WIDTH, HEIGHT);
  String dataDir = dataPath("");
  myMovie = new Movie(this, dataDir + "/" + videofile);
  myMovie.loop();
  myMovie.volume(0);
  
  kinect = new SimpleOpenNI(this);
  if(kinect.isInit() == false)
  {
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
}

void overlayVideo() {
  for (int i =0; i < resultImage.pixels.length; i++) {
     if (resultImage.pixels[i] != 0) {
       resultImage.pixels[i] = i < maxLenght ? myMovie.pixels[i] : color(0,0,255);
     }
  }
  resultImage.updatePixels();
}

void convertPosTo720p(PVector position) {
  position.x = position.x * WIDTH / KINECT_WIDTH;
  position.y = position.y * HEIGHT/ KINECT_HEIGHT;
}

void showCenterOfMass()
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
      fill(255, 0, 0);
      ellipse(position.x, position.y, 25, 25);
      oscSend(position);
    }
  }
}

void draw() {
  kinect.update();
  if (tracking) {
    //ask kinect for bitmap of user pixels
    loadPixels();
    userMap = kinect.userMap();
   
    //create a buffer image to work with instead of using sketch pixels
    resultImage = new PImage(KINECT_WIDTH, KINECT_HEIGHT, RGB); 
    
    for (int i =0; i < userMap.length; i++) {
      // if the pixel is part of the user
      if (userMap[i] != 0) {
        // set the pixel to the color pixel
        resultImage.pixels[i] = color(0,0,255);
      } else {
        //set it to the background
        resultImage.pixels[i] = color(0,0,0); //backgroundImage.pixels[i];
      }
    } 
    
    //update the pixel from the inner array to image
    resultImage.updatePixels();
    resultImage.resize(WIDTH, HEIGHT);  
    overlayVideo();
    image(resultImage, 0, 0);
    showCenterOfMass();
    
  } else {
    // get the Kinect color image
    PImage rgbImage = kinect.rgbImage();
    image(rgbImage, 0, 0);
  }
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
  print("### received an osc message.");
  print(" addrpattern: "+theOscMessage.addrPattern());
  println(" typetag: "+theOscMessage.typetag());
}
