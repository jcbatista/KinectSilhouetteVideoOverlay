import processing.video.*;
import processing.opengl.*; 
import SimpleOpenNI.*;

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
PImage tmpImage;
Movie myMovie;
int WIDTH = 1280;
int HEIGHT = 720;

int maxLenght = WIDTH * HEIGHT;
String videofile = "test.mov";

void setup() {
  size(WIDTH*2, HEIGHT);
  String dataDir = dataPath("");
  myMovie = new Movie(this, dataDir + "/" + videofile);
  myMovie.loop();
  
  kinect = new SimpleOpenNI(this);
  if(kinect.isInit() == false)
  {
     println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
     exit();
     return;  
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
}

void overlayVideo() {
  for (int i =0; i < resultImage.pixels.length; i++) {
     if (resultImage.pixels[i] != 0) {
       resultImage.pixels[i] = i < maxLenght ? myMovie.pixels[i] : color(0,0,255);
     }
  }
  resultImage.updatePixels();
}

void draw() {
  kinect.update();
  // get the Kinect color image
  PImage rgbImage = kinect.rgbImage();
  image(rgbImage, 640, 0);
  if (tracking) {
    //ask kinect for bitmap of user pixels
    loadPixels();
    userMap = kinect.userMap();
   
    //create a buffer image to work with instead of using sketch pixels
    resultImage = new PImage(640, 480, RGB); 
    
    for (int i =0; i < userMap.length; i++) {
      // if the pixel is part of the user
      if (userMap[i] != 0) {
        // set the pixel to the color pixel
        resultImage.pixels[i] = color(0,0,255);
      }
      else {
        //set it to the background
        resultImage.pixels[i] = color(0,0,0); //backgroundImage.pixels[i];
      }
    }
    
    //update the pixel from the inner array to image
     resultImage.updatePixels();
     resultImage.resize(WIDTH, HEIGHT);  
    overlayVideo();
    image(resultImage, 0, 0);
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
