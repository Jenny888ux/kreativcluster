class SynLoader implements Runnable{

  Boolean ready = false;
  Thread thread;

  TagMap parentMap;
  Tag parentTag;
  
  SynLoader(Tag cTag, TagMap parentMap){
    this.parentMap = parentMap;
    this.parentTag = cTag;
    this.ready = false;
    
    this.thread = new Thread(this);
    this.thread.start( );
  }

  public void run( ) {
     ArrayList relatedTags = this.loadSynsFL(this.parentTag.tag);
    //do we have any results?
    if (relatedTags.size() < 1) return;
    //add allRelatedTags
    for (int i = 0; i < relatedTags.size(); i++) {
      String relatedTag = (String) relatedTags.get(i);
      //Add relation between the "parent" tag and the related Tag
      //this will either create a new Tag for related or use an existing one if we found it.
      this.parentMap.addRelation(this.parentTag, this.parentMap.addTag(relatedTag));
      
    }
    this.ready = true;
    this.parentMap.expandingReady(this.parentTag, relatedTags.size());
    }
    
    
    //Load Syns from flickR
  ArrayList loadSynsFL(String searchTag){

    logit("loading related Tags from Flickr for "+searchTag);
    String[] rows = loadStrings(SYN_URL+searchTag);
    

    int rowCount = constrain(rows.length, 0,MAX_EXPAND_TAGS);
    
//    if (rowCount > MAX_EXPAND_TAGS) rowCount = MAX_EXPAND_TAGS;
    logit("Found "+rowCount+" related Tags");

    ArrayList resultList = new ArrayList();

    for (int row = 0; row < rowCount; row++) {
      if (rows[row].length() > 0){
        resultList.add(rows[row]);
      }
    }

    return resultList;
  } 

    
}  
  

