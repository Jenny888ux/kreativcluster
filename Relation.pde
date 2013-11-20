class Relation{
  Tag start;
  Tag end;
  ParticleSystem physics;
  Spring connection;
  int weight;
  boolean deletionCandidate = false;
  Relation(Tag start, Tag end, ParticleSystem physics){
    this.start = start;
    this.end = end;  
    this.weight = 1;
    this.physics = physics;
    this.connection = this.physics.makeSpring( this.start.particle,  this.end.particle, 0.4, 0.2, MIN_REST_LENGTH );
  }
  
  boolean connects(Tag tagA, Tag tagB){
      // Return true when this Relation matches BOTH tags.
      // Direction is ignored
      if ((this.start == tagA && this.end == tagB) || (this.start == tagB && this.end == tagA) ) {
          return true;    
      }  
      return false;
  }
  
   int increaseWeight(){
     this.weight++;
     return this.weight; 
  }
  
  void draw(){
    
    //draw White Outline
    stroke(255, 150);  
    strokeWeight(3);
   
  // line(this.start.x(), this.start.y(), this.end.x(), this.end.y());
    
    
    //draw Solid Black line
    stroke(255);  
    strokeWeight(1.5);
     
    line(this.start.x(), this.start.y(), this.end.x(), this.end.y());
    
    if (start.highlighted || end.highlighted) {
      stroke(SPRING_HIGH_COLOR , 60);
      strokeWeight(6);
      line(this.start.x(), this.start.y(), this.end.x(), this.end.y());
   
    }
    strokeWeight(1);
    
    /*
    ellipseMode(CENTER);
    fill(255,5);
    noStroke();
    ellipse(this.end.x(), this.end.y(), 300,300);
*/
    
    if (this.deletionCandidate){
      this.drawDeletionMarker(); 
    }
    
  }
  
  
  void drawDeletionMarker(){
    
    //draw White Outline
    stroke(NODE_DELETE_BACKGROUND_COLOR,150);  
    strokeWeight(8);
    line(this.start.x(), this.start.y(), this.end.x(), this.end.y());
  }
  
}
