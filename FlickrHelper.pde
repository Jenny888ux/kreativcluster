/* Daniel Shiffman               */
/* Programming from A to Z       */
/* Spring 2008                   */
/* http://www.shiffman.net       */
/* daniel.shiffman@nyu.edu       */

/* A Helper class to grab and parse
 * data from the Flickr API
 * This example has little to know functionality
 * and just serves as a starting framework.
 */



import java.io.IOException;
import org.xml.sax.SAXException;
import com.aetrion.flickr.*;
import com.aetrion.flickr.photos.*;

public class FlickrHelper {

	// A Flickr object for making requests
	Flickr f;

	public FlickrHelper() {
		// GET YOUR OWN KEY!!!!
		f = new Flickr("715aa14783a9ed50010da70136e66005");
	}


        public String[] findPhotos(String tag) {
            //Return 1 image as default.
            return this.findPhotos(tag, 1);          
        }
        public String[] findPhotos(String tag, int n) {
            //uses Square Thumb as default ImgSize
            return this.findPhotos(tag, n, 1);
        }
      
        //Tag = search Tag
        //n = number of pictures returned
        //imgSize 1 = SquareThumb | 2 = Thumbnail | 3 = small | 4 = Medium | 5 = Original (might require the Secret)
	public String[] findPhotos(String tag, int n, int imgSize) {
		// Interface with Flickr photos
		PhotosInterface photos = f.getPhotosInterface();
		// Create a search parameters object to control the search
		SearchParameters sp = new SearchParameters();
		// Simple example, just looking for a single tag
		sp.setTags(new String[] {tag});
               sp.setSort(6);
		try {
			// We're looking for n images, starting at "page" 0
			PhotoList list = photos.search(sp, n,0);
			// Grab all the image paths and store in String array
			String[] smallURLs = new String[list.size()];
			for (int i = 0; i < list.size(); i++) {
				// We can get a lot more info from a Photo beyond simply a urlpath
				Photo p = (Photo) list.get(i);

				//smallURLs[i] = p.getThumbnailUrl();
                                  switch(imgSize){
                                    case(2): smallURLs[i] = p.getThumbnailUrl(); break;
                                    case(3):  smallURLs[i] = p.getSmallUrl(); break;
                                    case(4):  smallURLs[i] = p.getMediumUrl(); break;
                                    case(5):  smallURLs[i] = p.getOriginalUrl(); break;
                                   default:
                                      smallURLs[i] = p.getSmallSquareUrl();
                                    break; 
                                  }
		                  


			}
			return smallURLs;
		} catch (IOException e) {
			e.printStackTrace();
		} catch (SAXException e) {
			e.printStackTrace();
		} catch (FlickrException e) {
			e.printStackTrace();
		}
		return null;
	}

}
