class Connector{
  ParticleSystem ph;
  Particle[] pl;
  Tag start = null;
  Tag end = null;
  Connector(){
    this.ph = new ParticleSystem( 5.0, 0.05 );
    this.pl = new Particle[10];
    
    this.pl[0] = this.ph.makeParticle( 1.0, width/2, height/2, 0 );


    this.pl[0].makeFixed(); 

    for ( int i = 1; i < this.pl.length; ++i )
    {
      this.pl[i] = this.ph.makeParticle( 1.0, width/2, height/2+i, 0 );
      this.ph.makeSpring( this.pl[i-1],  this.pl[i], 2.0, 0.1, 0.01 );
    }

    this.pl[this.pl.length-1].setMass( 5.0 );
 }

  void tmouseDragged(float mx, float my){
     if (this.start == null) return;
     this.pl[this.pl.length-1].makeFixed();
     this.pl[this.pl.length-1].moveTo(mx, my, 0);
     
  }
  
  void setPositionsToStart(){
     if (start == null) return;
    
    for ( int i = 1; i < this.pl.length; ++i )
    {

      this.pl[i].moveTo(start.x(), start.y(),0);

    }
     
  }
  
   void tmouseReleased(TagMap tMap){
     
     if (this.start!= null && this.end !=null){
         tMap.addRelation(this.start, this.end);  
     }
     
     this.start = null;
     this.end = null;

   }

  void draw(){
    if (this.start == null) return;
    this.pl[0].moveTo(this.start.x(), this.start.y(),0);
    
    this.ph.advanceTime(1.0); 
    fill(CONNECTOR_COLOR);
    /*
   if ( mousePressed )
     {
     this.pl[this.pl.length-1].moveTo( mouseX, mouseY, 0 );
     this.pl[this.pl.length-1].velocity().clear();
     }
     */
    strokeWeight(3);
    beginShape( );
    noFill();
    stroke(CONNECTOR_COLOR);
    curveVertex( this.pl[0].position().x(), this.pl[0].position().y() );
    for ( int i = 0; i < this.pl.length; ++i )
    {
      curveVertex( this.pl[i].position().x(), this.pl[i].position().y() );
    }
    curveVertex( this.pl[this.pl.length-1].position().x(), this.pl[this.pl.length-1].position().y() );
    endShape();

    ellipse( this.pl[0].position().x(), this.pl[0].position().y(), 5, 5 );
    ellipse( this.pl[this.pl.length-1].position().x(), this.pl[this.pl.length-1].position().y(), 20, 20 );
  }

}

