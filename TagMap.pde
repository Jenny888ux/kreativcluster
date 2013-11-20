class TagMap{

  ArrayList relations;
  ArrayList expanded;
  ArrayList tags;

  ParticleSystem physics;
  Tag selection = null;
  Tag over = null;
  SynLoader synLoader = null;
  float centerX = 0;
  float centerY = 0;
  float zoom = 1;



  TagMap(){
    this.physics = new ParticleSystem(0,0.6 );
    this.tags = new ArrayList();
    this.relations = new ArrayList();
    this.expanded = new ArrayList();
  }



  void draw(){
    pushMatrix();   
    translate(this.centerX, this.centerY);
    scale(this.zoom);
    //logit("tags size: " + this.tags.size());
    for (int i = 0; i < this.tags.size(); i++) {
      Tag cTag = (Tag) this.tags.get(i);
      cTag.drawImage();
    }

    // logit("relations size: " + this.relations.size());
    for (int i = 0; i < this.relations.size(); i++) {
      Relation cRelation = (Relation) this.relations.get(i);
      cRelation.draw();
    }  


    //logit("tags size: " + this.tags.size());
    for (int i = 0; i < this.tags.size(); i++) {
      Tag cTag = (Tag) this.tags.get(i);
      cTag.draw();
    }  



    //Now Draw The Tag currently under the mouse
    //yeah its once again i know
    //we could avoid drawing the tag in the above loops, but who cares.
    if (this.over!=null){

      switch(tool){
        //Cursor
        case(0):
        this.over.drawImage();
        this.over.draw();
        break; 
        //Eraser
        case(1):
        myMap.deleteTag(myMap.over, false);
        break;
     }
   }
   
   if (tool == 2) myConnector.draw();


    popMatrix();

  }


  void changeScale(int delta){

    float dScale = (float) delta / 100;
    this.zoom += dScale;
    this.zoom = constrain(this.zoom, 0.001, 5.0);
    // this.zoom = (float) constrain(this.zoom + delta , 0.0, 10.0);
    logit("zoom: " +this.zoom);
  }

  //Takes a Zoom Factor in Percentage e.g. 150.00%
  void setScale(float zoom){
    this.zoom = constrain((float) zoom/100, 0.001, 5.0);
    logit("zoom: " +this.zoom);
  }

  void moveTagTo(Tag cTag, float x, float y){
    cTag.particle.moveTo(x, y, 0); 
  }

  //Adds All missing Attractions.
  //Takes a long time
  void updateAttractions(){
    //logit("tags size: " + this.tags.size());
    for (int i = 0; i < this.tags.size(); i++) {
      Tag aTag = (Tag) this.tags.get(i);
      for (int j = i; j < this.tags.size(); j++) {
        Tag bTag = (Tag) this.tags.get(j);
        if (aTag == bTag) continue;
        addAttraction(aTag, bTag);
      }

    }  

  }


  //Adds All missing Attractions.
  //Takes not as long because it only adds attraction for the new Tag
  void hateOthers(Tag newTag){
    for (int i = 0; i < this.tags.size(); i++) {
      Tag aTag = (Tag) this.tags.get(i);
      if (aTag == newTag) continue;
      addAttraction(aTag, newTag);
    }  

  }

  void addAttraction(Tag aTag, Tag bTag){
    logit("adding Attraction:" + aTag.tag+" <-> " + bTag.tag);
    if (attractionExists(aTag, bTag)) return;
    logit(aTag.tag+" <-> " + bTag.tag + " Had no Attraction");
    this.physics.makeAttraction(aTag.particle, bTag.particle, ATTRACTION, ATTRACTION_MIN_DIST);
  }

  boolean attractionExists(Tag aTag, Tag bTag){
    for(int i = 0; i < this.physics.numberOfAttractions(); i++){
      Attraction cAttraction = this.physics.getAttraction(i);
      Particle oneEnd = cAttraction.getOneEnd();
      Particle otherEnd = cAttraction.getTheOtherEnd();
      //If this Attraction matches our Tags
      if ((oneEnd == aTag.particle && otherEnd == bTag.particle) || (oneEnd == bTag.particle && otherEnd == aTag.particle)){
        return true;      
      }
    }
    return false;
  }

  Tag addTag(String startTag){
    //Look if this Tag already Exists
    logit("adding tag: "+startTag); 
    Tag existingTag = this.findTag(startTag);
    //if it does just increase the Tags Weight
    if (existingTag != null){
      existingTag.increaseWeight();
      logit("Tag: "+startTag+" exists");
      return existingTag;
    } 
    else {
      //Add the new Tag to our List
      Tag newTag = new Tag(startTag, this.physics);
      this.tags.add(newTag);
      logit("Tag: "+startTag+" IS NEW");
      if (loadImages) newTag.loadImage();
      this.hateOthers(newTag);
      return newTag; 
    }
  }

  //Will load related Tags for the given one,
  //add them to the map
  //and add all relations
  void expandTag(Tag cTag){
    //load RelatedTags
    this.synLoader = new SynLoader(cTag, this);
    logit("##################### Expand "+cTag.tag);
    // this.updateAttractions(); 
  }

  //this function will be called from the SynLoader after Expanding is Ready
  //it gets the expanded Tag and how many Child Nodes have been Added
  void expandingReady(Tag cTag, int childCount){
    if (childCount > 3) {
      cTag.particle.setMass(childCount*2.5);
      //DOnt you add it twice to the ArrayList           
      if (this.expanded.contains(cTag))  return ; 
      //Put it to the List.
      logit("#####################  Make Attractions for "+cTag.tag);
      //Loop Through the List and Hate all!
      for (int i = 0; i < this.expanded.size() ; i++){
        Tag eTag = (Tag) this.expanded.get(i);
        logit("#####################  Make Attraction "+cTag.tag+" <-> "+eTag.tag);
        this.physics.makeAttraction(cTag.particle, eTag.particle, -20000, 20);  
      }

      this.expanded.add(cTag);
    }  
  }



  Relation addRelation(Tag start, Tag end){
    logit("adding relation:" + start.tag+" <-> " + end.tag);
    //Look if the Relation already Exists
    if (start.equals(end)) return null;
    Relation existingRelation = this.findRelation(start, end);
    //if it does just increase the Relation weight
    if (existingRelation != null) {
      logit(start.tag+" <-> " + end.tag+" Already Exists");
      existingRelation.increaseWeight();  
      return existingRelation;
    } 
    else {
      logit(start.tag+" <-> " + end.tag+" IS NEW");
      Relation newRelation = new Relation (start, end, this.physics);
      this.relations.add(newRelation);
      return newRelation;
    }
  }

  //returns the Relation that connects both Tags
  //ignoring the direction
  //and null if none matches both tags
  Relation findRelation(Tag tagA, Tag tagB){
    for (int i = 0; i < this.relations.size(); i++){  
      Relation cRelation = (Relation) this.relations.get(i);
      if (cRelation.connects(tagA, tagB)){
        return cRelation;
      }   
    }
    return null;
  }

  //returns a List of all Nodes that can be called Children
  //means that cTag is the start Tag in a Relation
  ArrayList findChildren(Tag cTag) {
    ArrayList results = new ArrayList();
    for (int i = 0; i < this.relations.size(); i++){ 
      Relation cRelation = (Relation) this.relations.get(i);
      if (cRelation.start == cTag){
        results.add(cRelation.end);
      }   
    }
    return results;
  }

  int relationsCount(Tag cTag){
    int cnt = 0;
    for (int i = 0; i < this.relations.size(); i++){ 
      Relation cRelation = (Relation) this.relations.get(i);
      if (cRelation.start == cTag || cRelation.end == cTag){
        cnt++;
      }   
    }
    return cnt;
  }

  //returns a List of all Nodes that can be called Children
  //means that cTag is the start Tag in a Relation
  boolean hasOtherParents(Tag cTag, Tag parentTag) {
    ArrayList results = new ArrayList();
    for (int i = 0; i < this.relations.size(); i++){ 
      Relation cRelation = (Relation) this.relations.get(i);
      //Relation end is cTag && Relation start is not the parent we exclude by the mean of "other"
      if (cRelation.end == cTag && cRelation.start != parentTag){
        return true;
      }   
    }
    return false;
  }



  //Calls deleteRelation for all Relations that connect the given Tag
  //
  void deleteAllRelations(Tag cTag, boolean serious){
    logit("Deletion relations for : "+cTag.tag);

    synchronized(this.relations){

      for(Iterator i = this.relations.iterator(); i.hasNext(); ){
        Relation cRelation = (Relation) i.next(); 
        if (cRelation.start.equals(cTag) || cRelation.end.equals(cTag)) {
          if (serious) i.remove();
          else cRelation.drawDeletionMarker();  
        }
      }
    }
  }


  //Removes a relation Object from our relations List
  void deleteRelation(Relation dRelation, boolean serious){
    logit("Deleting Relation "+ dRelation.start.tag +" --> "+dRelation.end.tag);
    if (serious){
      if (this.relations.contains(dRelation)) this.relations.remove(this.relations.indexOf(dRelation)); 
    } 
    else {
      dRelation.drawDeletionMarker();
    }

  }

  //Simply kills a given Tag and its Particle
  //removing it from all relevant lists
  //and Setting References to null
  void killTag(Tag dTag){
    //kill the Particle from Physics
    this.selection = null;
    this.over = null;
    //Remove the Particle from System
    dTag.particle.kill();
    //delete Yourself
    if (this.tags.contains(dTag)) this.tags.remove(this.tags.indexOf(dTag));
    //remove from the Expanded-List
    if (this.expanded.contains(dTag)) this.expanded.remove(this.expanded.indexOf(dTag));
    //Some thing to destroy the Object? dTag();
  }

  //delete the tag and all children not used other wise recursivly
  void deleteTag(Tag dTag, boolean serious){

    logit("deleteTag( "+dTag.tag+" )");
    if (this.tags.contains(dTag)) logit(dTag.tag+" is in our List. Trying to  DELETE!");
    else return;
    //this.tags.remove(this.tags.indexOf(dTag));


    //find Child Nodes by looping through the relations
    ArrayList children = this.findChildren(dTag);

    for (int i = 0; i < children.size(); i++){
      Tag cChild = (Tag) children.get(i);  
      logit(dTag.tag+" has child: "+cChild.tag+" ");
      //delete Child only if it has no other Connections
      //Since we are the parent thats the case when relationsCount is higher than 1
      //Delete Only if its 0 or 1
      if (this.relationsCount(cChild) < 2){
        if(serious) this.killTag(cChild);
        else  cChild.drawDeletionMarker(); 
      }

    }

    //delete Relations
    this.deleteAllRelations(dTag, serious);
    //Kill The Tag
    if (serious){
      this.killTag(dTag);

    } 
    else {
      dTag.drawDeletionMarker();  
    }

  }



  void moveCenterBy(float x, float y){
    this.centerX += x;
    this.centerY += y;
  }

  void setCenter(float x, float y){
    this.centerX = x;
    this.centerY = y;

  }

  void drawSystem(){
    stroke(100);
    //X-Achse nach Rechts
    line(this.centerX, this.centerY, width, this.centerY);
    //X-Achse nach Links
    line(this.centerX, this.centerY, 0, this.centerY);
    //Y-Achse nach Oben
    line(this.centerX, this.centerY, this.centerX, height);
    //Y-Achse nach Unten
    line(this.centerX, this.centerY, this.centerX, 0);


    textFont(smallFont);
    textMode(CENTER);


    for (int i = -100; i< 100; i++){
      //xAchsenSchnitte
      int abstand = 25;
      line (this.centerX + i*abstand, this.centerY - 4, this.centerX+i*abstand, this.centerY+4);
      text(round(i*abstand/this.zoom ), this.centerX + i*abstand, this.centerY + 15);

      line (this.centerX+4, this.centerY + i*abstand, this.centerX - 4, this.centerY+i*abstand);
      text(round(i*abstand / this.zoom), this.centerX, this.centerY + i*abstand);
    }

    textFont(nodeFont);
  }

  float getMouseX(){
    return (mouseX - this.centerX) / this.zoom; 
  }

  float getMouseY(){
    return (mouseY - this.centerY) /this.zoom;    
  }

  //Maps the MouseX and MouseY to our System
  Tag findClosestToMouse(){
    return this.findClosest(this.getMouseX(), this.getMouseY(), 36); 
  }

  Tag findClosest(float x, float y, float minDistance) {

    Tag closest = null;

    for (int i = 0; i < this.tags.size(); i++){
      Tag cTag = (Tag) this.tags.get(i);

      //Get The distance

      float d = dist(x, y, cTag.x(), cTag.y());
      //Update minDistance and closest if we are closer to x,y      
      if (d < minDistance) {
        minDistance = d;     
        closest = cTag;
      }
    } 
    return closest;      
  }

  //Returns Tag Object with the given searchTag or null if none equals()
  Tag findTag(String searchTag){

    for (int i = 0; i < this.tags.size(); i++){
      Tag cTag = (Tag) this.tags.get(i);
      if (cTag.tag.equals(searchTag)){
        return cTag; 
      } 
    } 
    return null;
  }


}







