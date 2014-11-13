import java.util.LinkedList;

class ConfigManager {

  ConfigManager() {
    load();
  }
  
  void load() {
    String configFilePath = dataPath("") + "/config.json";
    configJSON = loadJSONObject(configFilePath);
  }
  
  LinkedList<SilhouetteClipInfo> getClips() {  
    LinkedList<SilhouetteClipInfo> list = new LinkedList<SilhouetteClipInfo>();
    
    JSONArray clips = configJSON.getJSONArray("clips");
    for(int i=0; i < clips.size(); i++) {
      SilhouetteClipInfo clipInfo = new SilhouetteClipInfo();
      JSONObject clipData = clips.getJSONObject(i);
      
      if(clipData.hasKey("silhouette")) {
        String silhouette = clipData.getString("silhouette");
        if(silhouette!=null) {
          clipInfo.silhouetteFilename = silhouette;
        }
      }
      
      if(clipData.hasKey("background")) {
        String background = clipData.getString("background");
        if(background!=null) {
          clipInfo.backgroundFilename = background;
        }
      }

      // for now, each clip has the same crossfade value
      clipInfo.crossfade = getCrossfade();
      list.add(clipInfo);
    }
    return list; 
  }
  
  // return an identifier for the installation (since there could be multiple Kinects/Projectors) 
  String getName() {
    return configJSON.getString("name");
  }
  
  boolean resizeSilhouette() {
    return configJSON.getBoolean("resizeSilouhette");
  }
  
  boolean mirrorSilhouette() {
    return configJSON.getBoolean("mirrorSilhouette");
  }
  
  boolean overlayVideo() {
    return configJSON.getBoolean("overlayVideo");
  }
  
  boolean useActionClips() {
    return configJSON.getBoolean("useActionClips");
  }
  
  SilhouettePadding getSilhouettePadding() {
    SilhouettePadding padding = new SilhouettePadding();
    JSONObject paddingJSON = configJSON.getJSONObject("silhouettePadding");
    padding.top = paddingJSON.getInt("top");
    padding.right = paddingJSON.getInt("right");
    padding.bottom = paddingJSON.getInt("bottom");
    padding.left = paddingJSON.getInt("left");
    return padding;
  }
  
  boolean showCenterOfMass() {
    return configJSON.getBoolean("centerOfMass");
  }
  
  boolean showTime() {
    return configJSON.getBoolean("showTime");
  }
  
  int getSmoothSilhouette() {
    return configJSON.getInt("smoothSilhouette");
  }
  
  int getCrossfade() {
    return configJSON.getInt("crossfade");
  }

  SilhouetteCacheData getSilhouetteCacheSettings() {
    SilhouetteCacheData data = new SilhouetteCacheData();
    JSONObject dataJSON = configJSON.getJSONObject("silhouetteCache");
    data.enabled = dataJSON.getBoolean("enabled");
    data.minFrames = dataJSON.getInt("minFrames");
    data.maxFrames = dataJSON.getInt("maxFrames");
    return data;
  }
  
  OscConfigData getOscSettings() {
    OscConfigData data = new OscConfigData();
    data.name = getName();
    JSONObject dataJSON = configJSON.getJSONObject("osc");
    data.enabled = dataJSON.getBoolean("enabled");
    data.serverPort = dataJSON.getInt("serverPort");
    data.clientAddress = dataJSON.getString("clientAddress");
    data.clientPort = dataJSON.getInt("clientPort");
    return data;
  }
  
  ActionClipSettings getActionClipSettings() {
    ActionClipSettings settings = new ActionClipSettings();
    JSONObject actionData = configJSON.getJSONObject("actions");

    settings.frequency = actionData.getInt("frequency");
    JSONArray clips = actionData.getJSONArray("clips");
    for(int i=0; i < clips.size(); i++) {
      String clipName = clips.getString(i);
      settings.clips.append(clipName);
    }
    return settings;
  }
 
  void listClips() {
    println("*** Listing defined clips ***");
    LinkedList<SilhouetteClipInfo> clips = getClips();
    int count = 1;
    for (SilhouetteClipInfo clip : clips) {
      print(count + ".");
      if(clip.silhouetteFilename!=null && clip.silhouetteFilename!="") {
        print ("silhouette clip = "+ clip.silhouetteFilename + " ");
      }
      if(clip.backgroundFilename!=null && clip.backgroundFilename!="") {
        print ("backgroundFilename clip = "+ clip.backgroundFilename);
      }
      count++;
      println();
    }
    println("*** Done. ***");
  }
     
  private JSONObject configJSON;  
}
