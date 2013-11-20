class ImageLoader implements Runnable{
  
  String searchTag;
  PImage theImage;
  PImage BigImage;
  Boolean ready = false;
  Thread thread;
  
  ImageLoader(String initTag){
    this.searchTag = initTag;
    this.ready = false;
    this.thread = new Thread(this);
    this.thread.start( );
  }

  public void run( ) {
     FlickrHelper f = new FlickrHelper();
    // Get 1 photo url as string
    String[] photos = f.findPhotos(this.searchTag);
    if (photos != null){
      if (photos.length >0){
      this.theImage = new PImage();
      logit("Loading: " + photos[0]);
      try {
       
      this.theImage = loadImage(photos[0]);
      } catch (Exception e) {
			e.printStackTrace();
      }
      }
    }
    this.ready = true;
    }
}  
  

