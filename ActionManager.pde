class ActionSettings
{
  
  // TODO actions need to send OSC information
  ActionSettings() {
    clips = new StringList();
  }
  StringList clips;
  int frequency;
}

class ActionManager {
  ActionManager(ActionSettings settings) {
    this.frequency = settings.frequency;
    this.clips = settings.clips;
  }
  
  boolean shouldPlay() { 
    return frequency!=0;
  }
  
  private int frequency = 0;
  private StringList clips = null;
}
