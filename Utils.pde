static class Utils
{
  static boolean isValidFilename(String filename) {
    return filename!=null && !filename.isEmpty();
  }
  
  static private boolean isLiveFilename(String filename) {
    return isValidFilename(filename) && filename.equalsIgnoreCase("live");
  }
}
