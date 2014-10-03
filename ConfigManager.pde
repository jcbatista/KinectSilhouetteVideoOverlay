class ConfigManager {
 
  // TODO support the new config.json layout...
  
  ConfigManager() {
    Load();
  }
  
  void Load() {
    config = loadJSONObject(dataPath("") + "/config.json");
  }
  
  List<ClipInfo> getClips() {
    
    List<ClipInfo> list = new List<ClipInfo>;
    
    JSONArray clips = config.getJSONArray("clips);
    for(int i=0; i < clips.size(); i++) {
      ClipInfo clipInfo = new ClipInfo();
      JSONObject clipData = clips.getJSONObject(i);
      
      String silhouette = clipData.getString("silhouette");
      if(silhouette!=null) {
        clipInfo.silhouetteFilename = silhouette;
      }
      
      String background = clipData.getString("background");
      if(background!=null) {
        clipInfo.backgroundFilename = background;
      }

      list.append(clipName);
    }
    return list; 
  }
  
  StringList getActionClips() {
    StringList list = new StringList();
    JSONArray clips = config.getJSONArray("actionClips");
    for(int i=0; i < clips.size(); i++) {
      String clipName = clips.getString(i);
      list.append(clipName);
    }
    return list;
  }
 
  
  void listClips() {
    println("*** Listing defined clips ***");
    List<ClipInfo> clips = getClips();
    int count = 1;
    for (ClipInfo clip : clips) {
      print(count + ".");
      if(clip.silhouetteFilename!=null) {
        print ("silhouette clip ="+ clip.silhouetteFilename + " ");
      }
      if(clip.backgroundFilename!=null) {
        print ("backgroundFilename clip ="+ clip.backgroundFilename);
      }
      println();
    }
    println("*** Done. ***");
  }
  
  private JSONObject config;
}
