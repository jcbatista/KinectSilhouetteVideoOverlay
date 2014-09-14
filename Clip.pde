class Clip {
  
  Clip(Movie movie)
  {
    this.movie = movie;
    duration = -1;
  }
  
  int duration; // in seconds or -1 if not set
  Movie movie;
}

