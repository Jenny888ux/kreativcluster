import fullscreen.*;
import controlP5.*;
import traer.physics.*;
import processing.pdf.*;


//ORANGE final color NODE_BACKGROUND_COLOR  = #ff6633;
final color NODE_BACKGROUND_COLOR  = #646567;
final color NODE_FIXED_BACKGROUND_COLOR  = #46a12a;
final color NODE_MASTER_BACKGROUND_COLOR  = #d50052;
final color NODE_HIGH_BACKGROUND_COLOR  = #009de0;
final color NODE_DELETE_BACKGROUND_COLOR  = #e1007a;
final color CONNECTOR_COLOR  = #feed00;

final color NODE_HASCHILDS_BACKGROUND_COLOR  = #C0FF80;

final color NODE_FONT_COLOR        = #FFFFFF;
final color LOADING_COLOR  = #287fe0;

final color SPRING_COLOR           = #dedede;
final color SPRING_HIGH_COLOR           = #287fe0;

final float ATTRACTION = -6000;
final float ATTRACTION_MIN_DIST = 40;
final float MIN_REST_LENGTH = 350;
//final String SYN_URL = "http://localhost/ProgrammableWeb/Flickr/getFlickrRelatedTags.php?keyword=";
final String SYN_URL = "http://kreativcluster.de/api/flickr/getFlickrRelatedTags.php?keyword=";


final int MAX_EXPAND_TAGS =15;
PFont nodeFont;
PFont nodeFontSmall;
PFont nodeFontBig;
PFont smallFont ;



ControlP5 controlP5;
Textfield newTagField;
Slider sliderZoom;
Radio toolBox;
Controller saveButton;


boolean record = false;
boolean overController = false;

PImage bg;

TagMap myMap;
Connector myConnector;

FullScreen fs;

//turns on "debugging". basicly it prints out everything that was logged with "logit(String whatsoever);"
boolean debug = false;
//turns on and off loading of FLickr Images
boolean loadImages = true;
void setup()
{
  size( 1200  , 800);
  fs = new FullScreen(this); 

  smooth();
  fill( 0 );
  frameRate(30  );
  ellipseMode( CENTER );

  bg = loadImage("hintergrund.jpg");

  //nodeFont = createFont("Arial", 11);
  nodeFont = loadFont("Simple-BoldTitling-12.vlw");
  smallFont = createFont("Arial",10);

  myMap = new TagMap();
  Tag newTag =  myMap.addTag("bier");

  //newTag.particle.setMass(100);
  newTag.particle.moveTo(0,0,0);
  newTag.particle.makeFixed();
  myMap.setCenter(width/2, height/2);
  myMap.expandTag(newTag);
  myConnector = new Connector(); 

  /*
  GUI
   */
  controlP5 = new ControlP5(this);
  color tmpColor;
  //Suchbegriff 
  newTagField = controlP5.addTextfield("Suchbegriff",10,10,200,20);
  newTagField.setFocus(true);
  newTagField.setId(1);
  
  tmpColor = #009de0;
  newTagField.setColorForeground(tmpColor);
  tmpColor = #009de0;
  newTagField.setColorBackground(tmpColor);
  tmpColor = #009de0;
  newTagField.setColorActive(tmpColor);

  /* will call method button() below */
  saveButton = controlP5.addButton("savePDF",10,300,10,60,20);
  tmpColor = #e1007a;
  saveButton.setColorForeground(tmpColor);
  tmpColor = #009de0;
  saveButton.setColorBackground(tmpColor);
  tmpColor = #e1007a;
  saveButton.setColorActive(tmpColor);


  //ZOOM Slider
  sliderZoom = controlP5.addSlider("Zoom",1,500,100,width -200,11,150,20);
  sliderZoom.setSliderMode(Slider.FLEXIBLE);
  tmpColor = #e1007a;
  sliderZoom.setColorForeground(tmpColor);
  tmpColor = #009de0;
  sliderZoom.setColorBackground(tmpColor);
  tmpColor = #e1007a;
  sliderZoom.setColorActive(tmpColor);

  // toolBox
  toolBox = controlP5.addRadio("toolBox",10,60,100,10,20);
  tmpColor = #e1007a;
  toolBox.setColorActive(tmpColor);
  tmpColor = #009de0;
  toolBox.setColorForeground(tmpColor);

  toolBox.add("Cursor",0);
  toolBox.add("Eraser",1);
  toolBox.add("Connector",2);
  toolBox.activate("Cursor");
 
  addMouseWheelListener(new java.awt.event.MouseWheelListener() { 
    public void mouseWheelMoved(java.awt.event.MouseWheelEvent evt) { 
      mouseWheel(evt.getWheelRotation());
    }
  }
  ); 

}


void draw(){

  background(178);
  myMap.physics.advanceTime( 1.0 );
  
  //myMap.drawSystem();

  if (record) {
      // Note that #### will be replaced with the frame number. Fancy!
      nodeFont = createFont("Arial", 11);
      beginRecord(PDF, "frame-####.pdf"); 
      background(178);
  }

  myMap.draw();

  if (record) {
    // NoteendRecordthat #### will be replaced with the frame number. Fancy!
    endRecord(); 
    nodeFont = loadFont("Simple-BoldTitling-12.vlw");
    record = false;
  }

  /*
Ouput the fps
   */

  //  textMode(CORNER);
  if (debug){
  translate(0,0);
  scale(1);
  textAlign(LEFT);
  textFont(smallFont);
  text("fps: "+frameRate, 10, height-8);
  text("REAL mX: "+mouseX+" | mY: " +mouseY, 10, height-28);
  text("MAP mX: "+myMap.getMouseX()+" | mY: " +myMap.getMouseY(), 10, height-38);
  text("nodes: "+myMap.tags.size()+" | relations: " +myMap.relations.size(), 10, height-48);
  textFont(nodeFont);
  }
}





/*
Interaction
 */

void mouseMoved(){

  if (myMap.over != null) myMap.over.highlighted = false;
  myMap.over = myMap.findClosestToMouse();
  if (myMap.over != null){
    myMap.over.highlighted = true;
    
    
       switch(tool){
          //Cursor
         case(0):
         break; 
         //Eraser
         case(1):
         break;
        }

  }

}

float lastX = 0;
float lastY = 0;
//this store the currently selected Tool
int tool = 0; // 0 = Cursor | 1 = eraser | 2 = connector
  
  
void mousePressed(){

  myMap.selection = myMap.findClosestToMouse();

  //if we found a note within minDistance
  if (myMap.selection != null){
    if (mouseButton == LEFT) { 
      // mouseEvent variable contains the current event information
      if (mouseEvent.getClickCount()==2) {

        logit("<double click>");
       if (tool == 0)
        myMap.expandTag(myMap.selection);
      } 
      else {  
        switch(tool){
          //Cursor
         case(0): myMap.selection.particle.makeFixed(); 
         break; 
         //Eraser
         case(1):
             myMap.deleteTag(myMap.selection, true);
         break;
         
         //Connector
         case(2):
             myConnector.start = myMap.selection;
             myConnector.setPositionsToStart();
         break;
         
        }
        
      }

    } 
    else if (mouseButton == RIGHT) { 
      myMap.selection.particle.makeFree();
    } 

  } 
  else {
    //no Selection so the Canvas has been clicked
    lastX = mouseX - myMap.centerX;
    lastY = mouseY - myMap.centerY;
    logit("lastX: "+lastX+ " | lastY: "+lastY);
  }

}



void mouseDragged() { 

  if (myMap.selection != null) { 
     switch(tool){
          //Cursor
         case(0):
          float  nx = myMap.getMouseX();
          float  ny = myMap.getMouseY();
          myMap.moveTagTo(myMap.selection,nx,ny); 
         break; 
         //Eraser
         case(1):
            
         break;
         
         //Connector
         case(2):
             myConnector.tmouseDragged(myMap.getMouseX(), myMap.getMouseY());
             if (myConnector.end != null) myConnector.end.highlighted = false;
              myConnector.end = myMap.findClosestToMouse();
            if (myConnector.end != null){
             myConnector.end.highlighted = true;
            }
             
         break;
         
        }
    
    
    
   
  } 
  else {
    //mouse hase been Dragged on Canvas
    //Look how far we moved from initial Point.
    
    float dx = mouseX - lastX;
    float dy = mouseY - lastY;
    stroke(0);
    logit ("dx: "+dx+" | dy: "+dy);
    //line(lastX, lastY, mouseX, mouseY);
    myMap.setCenter(dx, dy);

  }

} 
void mouseReleased() { 
 myConnector.tmouseReleased(myMap);
} 



void mouseWheel(int delta) {
  logit(delta);
  myMap.changeScale(delta); 
  sliderZoom.setValue(round(myMap.zoom*100));
}

void keyPressed() {

}




void controlEvent(ControlEvent theEvent) {
  logit("got a control event from controller with id "+theEvent.controller().id());

  switch(theEvent.controller().id()) {
    case(1):
    Tag newTag = myMap.addTag(newTagField.getText());
    newTag.particle.makeFixed();
    //myMap.expandTag(newTag);

    break;
    case(2):
    logit("nothing to do");
    break;  
  }
}

void Zoom(int theValue) {
  logit("<zoomSlider Event>. Int Value: "+theValue);
  myMap.setScale(theValue); 
}

void savePDF(int theValue) {
  record = true;
}


void toolBox(int theValue){
   logit("<ToolBox clicked> "+theValue); 
   tool = theValue;
}


void logit(String logline){
   if (debug){
       println(logline); 
   } 
}

void logit(int logline){
   if (debug){
       println(logline); 
   } 
}

void logit(float logline){
   if (debug){
       println(logline); 
   } 
}
