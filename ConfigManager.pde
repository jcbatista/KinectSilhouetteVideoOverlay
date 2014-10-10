import java.util.LinkedList;

class ConfigManager {

  ConfigManager() {
    load();
  }
  
  void load() {
    String configFilePath = dataPath("") + "/config.json";
    configJSON = loadJSONObject(configFilePath);
  }
  
  LinkedList<ClipInfo> getClips() {  
    LinkedList<ClipInfo> list = new LinkedList<ClipInfo>();
    
    JSONArray clips = configJSON.getJSONArray("clips");
    for(int i=0; i < clips.size(); i++) {
      ClipInfo clipInfo = new ClipInfo();
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

      list.add(clipInfo);
    }
    return list; 
  }
  
  // return an identifier for the installation (since there could be multiple Kinects/Projectors) 
  String getName() {
    return configJSON.getString("name");
  }
  
  boolean showCenterOfMass() {
    return configJSON.getBoolean("centerOfMass");
  }
  
  int getSmoothSilhouette() {
    return configJSON.getInt("smoothSilhouette");
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
  
  StringList getActionClips() {
    StringList list = new StringList();
    JSONArray clips = configJSON.getJSONArray("actionClips");
    for(int i=0; i < clips.size(); i++) {
      String clipName = clips.getString(i);
      list.append(clipName);
    }
    return list;
  }
 
  
  void listClips() {
    println("*** Listing defined clips ***");
    LinkedList<ClipInfo> clips = getClips();
    int count = 1;
    for (ClipInfo clip : clips) {
      print(count + ".");
      if(clip.silhouetteFilename!=null) {
        print ("silhouette clip ="+ clip.silhouetteFilename + " ");
      }
      if(clip.backgroundFilename!=null) {
        print ("backgroundFilename clip = "+ clip.backgroundFilename);
      }
      count++;
      println();
    }
    println("*** Done. ***");
  }
     
  private JSONObject configJSON;  
}
