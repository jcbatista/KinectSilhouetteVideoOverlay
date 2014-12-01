public class Range {
  Range() {
    this.start = 0;
    this.length = 0;
  }
  Range(int start, int length) {
    this.start = start;
    this.length = length;
  }
  
  int getStart() {
    if(length==0)
      return -1;
    return start; 
  }
  
  int getStop() {
    if(length==0)
      return -1;
    return start+length-1; 
  }
  
  int getLength() {
    return length;
  }
  
  private int start;
  private int length;
}

static class Utils
{

  static boolean isValidFilename(String filename) {
    return filename!=null && !filename.isEmpty();
  }
  
  static private boolean isLiveFilename(String filename) {
    return isValidFilename(filename) && filename.equalsIgnoreCase("live");
  }
}
