public class GpuRenderer extends Renderer {
  private GpuRenderer() {}
  
  public GpuRenderer(int w, int h) {
    application.size(w, h, P2D);
    
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
  private Renderer() {}
  public Renderer(int w, int h) {
    application.size(w, h);
    println("Using *DEFAULT* renderer!!!");
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
}


