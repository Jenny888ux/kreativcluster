class Tag{
  ParticleSystem physics;
  Particle particle;
  String tag;
  int weight;
  boolean highlighted = false;
  ImageLoader imgLoader;  
  boolean deletionCandidate = false;

  
  Tag(String startTag, ParticleSystem startPhysics) {
    this.tag = startTag;
    this.physics = startPhysics;
    this.particle = this.physics.makeParticle(1, random(0,width), random(height),0);
    this.weight = 1;
  } 

  void loadImage(){
      this.imgLoader = new ImageLoader(this.tag);  

  }

  int increaseWeight(){
     this.weight++;
     //this.particle.setMass(this.weight);
     return this.weight; 
     
  }

  //returns if we are currently loading an image
  boolean loadingImage(){
    if (this.imgLoader != null && this.imgLoader.ready == false)  return true;
    return false;    
  }
  
  //returns if we are currently loading an image
  boolean hasImage(){
    if (this.imgLoader != null && this.imgLoader.ready == true && this.imgLoader.theImage != null)  return true;
    return false;    
  }
  
  
  void drawImage(){
    
    if (this.hasImage()){
      //logit(this.tag+ " has an Image"); 
      //Draw the Image
       imageMode(CORNER);
       image(this.imgLoader.theImage, this.x()-this.imgLoader.theImage.width/2, this.y()-this.imgLoader.theImage.height);
      
     } 
     else {
      if (this.loadingImage()) {
     //  logit(this.tag+ " is loading an Image"); 
         fill(LOADING_COLOR );
        ellipse(this.x()-30, this.y()-30, 20,20);
      } 
      else {
     //  logit(this.tag+ " has no Image"); 
      }
     }
    
  }
  
  void drawDeletionMarker(){
    
     fill(NODE_DELETE_BACKGROUND_COLOR,150);
     stroke(NODE_DELETE_BACKGROUND_COLOR,150);
     strokeWeight(6);
     int crossSize = 10;
     line(this.x()-crossSize, this.y()-crossSize, this.x()+crossSize, this.y()+crossSize);
     line(this.x()-crossSize, this.y()+crossSize, this.x()+crossSize, this.y()-crossSize);
    // text("XXX", this.x(), this.y()+5);
/*     rectMode(CENTER);
     noStroke();
     fill(255,0,0, 120);
     text("X", this.x(), this.y());
    rect(this.x(), this.y(), 44,24); 
  
 */
  }

  void draw(){
     
    
  //   logit("drawing Tag:" + this.tag);
    String theTag = this.tag;
    textFont(nodeFont);
/*
    
    if (this.zoom < 0.65) textFont(nodeFontSmall);
    if (this.zoom > 2)    textFont(nodeFontBig);
  */  
    float tagWidth = textWidth(theTag);
    tagWidth = 65;
    float tagHeight = 10;

    //DRAW THE TAG BACKGROUND RECTANGLE    
    rectMode(CORNER);
    stroke(0);
    fill(NODE_BACKGROUND_COLOR);
    if (this.particle.isFixed()) fill(NODE_FIXED_BACKGROUND_COLOR);
    if (this.highlighted)     fill(NODE_HIGH_BACKGROUND_COLOR);
    
    
    
    noStroke();
    rect( this.x()-37.5, this.y()-1, tagWidth+10, tagHeight );
    //draw the Tag

    //DRAW THE TEXT
    fill(NODE_FONT_COLOR);
    textAlign(LEFT);
    text(theTag, this.x()-37.5, this.y()+8);
   /* DEBUG X, Y
   textFont(smallFont);
    fill(255,0,0);
    text("x: "+ round(this.x())+" | y: "+round(this.y()), this.x(), this.y()+tagHeight); 
*/   

   
     if (this.highlighted){
      textFont(smallFont);
        fill(255,0,0);
      if (debug){
      text("x: "+ round(this.x())+" | y: "+round(this.y())+" | Mass: " +this.particle.mass(), this.x(), this.y()+tagHeight);  
      }
    }
    
    if (this.deletionCandidate){
      this.drawDeletionMarker(); 
    }
  }

  float x(){
    return this.particle.position().x(); 
  }

  float y(){
    return this.particle.position().y(); 
  }

}

