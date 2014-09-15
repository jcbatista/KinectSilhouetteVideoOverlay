class ConfigManager {
 
  ConfigManager() {
    Load();
  }
  
  void Load() {
    config = loadJSONObject(dataPath("") + "/config.json");
  }
  
  StringList getClips() {
    return getClipsByType("clips");
  }
  
  StringList getActionClips() {
    return getClipsByType("actionClips");
  }
  
  private StringList getClipsByType(String type) {
    StringList list = new StringList();
    JSONArray clips = config.getJSONArray(type);
    for(int i=0; i < clips.size(); i++) {
      String clipName = clips.getString(i);
      list.append(clipName);
    }
    return list;  
  }
  
  void listClips() {
    println("*** Listing defined clips ***");
    StringList clips = getClips();
    for (String clipName : clips) {
        println(clipName);
    }
    println("*** Done. ***");
  }
  
  
  private JSONObject config;
}
