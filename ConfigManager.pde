import java.util.LinkedList;

class ConfigManager {
 
  // TODO support the new config.json layout...
  private JSONObject configJSON;
    
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
        print ("backgroundFilename clip ="+ clip.backgroundFilename);
      }
      count++;
      println();
    }
    println("*** Done. ***");
  }

}
