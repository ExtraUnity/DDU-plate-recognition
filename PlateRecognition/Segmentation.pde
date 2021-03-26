static class Segmentation {

  static ArrayList <PImage> plateSegmentation(PImage plate, PApplet outer) {
    // based on Koo et al, 2009

    plate = preprossing(plate, outer);

    color[] pix = plate.pixels;
    float[] colVal = new float[plate.width];
    outer.image(plate, 0, 0);

    int[][] verticalBreaks = new int[plate.width][2];
    outer.image(plate, 0, 0);


    for (int col = 0; col<plate.width; col++) {
      int breakTop = 0;
      int breakBottom = plate.height;

      for (int row = 0; row<plate.height; row++) {
        if (outer.red(pix[row*plate.width+col]) == 255) {
          breakTop = row; 
          break;
        }
      }

      for (int row = plate.height-1; row>=0; row--) {
        if (outer.red(pix[row*plate.width+col]) == 255) {
          breakBottom = row; 
          break;
        }
      }

      for (int row = breakTop; row <breakBottom; row++) {
        if (outer.red(pix[row*plate.width+col]) == 255) {
          colVal[col] ++;
        }
      }
      verticalBreaks[col][0] = breakTop;
      verticalBreaks[col][1] = breakBottom;

      colVal[col] /= breakBottom-breakTop;
    }

    ArrayList<Integer> whiteSpace = new ArrayList<Integer>();
    for (int i = 0; i<colVal.length; i++) {
      if (colVal[i] >= 0.9) { // this number controlls how many percent of the collumn that must be white for it to be considered a empty line
        whiteSpace.add(i); 
        outer.stroke(#ff0000);
        //outer.line(i, 0, i, outer.height);
      }
    }

    ArrayList<Integer> breakpoints = new ArrayList<Integer>();
    for (int i = 1; i<whiteSpace.size()-1; i++) {
      if (whiteSpace.get(i+1) - whiteSpace.get(i) >1 || whiteSpace.get(i) - whiteSpace.get(i-1) >1) {
        breakpoints.add(whiteSpace.get(i));
        outer.stroke(#00ff00);
        //outer.line(whiteSpace.get(i), 0, whiteSpace.get(i), outer.height);
      }
    }


    ArrayList <PImage> output = new ArrayList <PImage>();

    for (int i = 0; i< breakpoints.size(); i+= 2) {
      int _width = breakpoints.get(i+1) -  breakpoints.get(i);

      int[] range = findSmallestLength(verticalBreaks, breakpoints.get(i), breakpoints.get(i+1), plate.height);

      output.add(plate.get(breakpoints.get(i), range[0], _width, range[1]-range[0]));
      outer.image(output.get(output.size()-1), breakpoints.get(i), 200);
    }

    if (output.size() == 0) {
      output.add(plate);
    }

    return output;
  }

  static PImage preprossing(PImage plate, PApplet outer) {
    plate.resize(700, 0);
    plate.filter(GRAY);
    plate.filter(BLUR, 0.5);
    
    //plate = ImageUtils.contrastExtension(plate,outer);
    plate = ImageUtils.filterImageByMedian(plate, outer);
    plate.resize(plate.width+1, plate.height+1);
    //println(ImageUtils.averageBrightness(plate, outer), ImageUtils.medianBrightness(plate), (ImageUtils.averageBrightness(plate, outer)+ ImageUtils.medianBrightness(plate))/2.0);
    //plate.filter(THRESHOLD, ImageUtils.averageBrightness(plate, outer)); // find the average intensity to filter dynamicly insted of taking a static value
    plate.filter(THRESHOLD, (ImageUtils.averageBrightness(plate, outer)+ ImageUtils.medianBrightness(plate))/2.0); 
    plate = ImageUtils.cropBorders(plate, outer);
    return plate;
  }


  static ArrayList <PImage> blobSegmentation(PImage plate, PApplet outer) {
    // Based on Yoon, 2011
    plate = preprossing(plate, outer);
    
    ArrayList <PImage> blobs = connectedComponentAnalysis(plate, outer);

    ArrayList <PImage> nonCharBlobs = new ArrayList <PImage>();

    for (int i = 0; i<blobs.size(); i++) {
      if (!isCharacterImage(blobs.get(i), plate, outer)) nonCharBlobs.add(blobs.get(i));
    }
    blobs.removeAll(nonCharBlobs);

    // visual feedback system
    /*
    outer.background(125);
    outer.stroke(#00ff00);
    int xCord = 0; 
    for (int i = 0; i< blobs.size(); i++) {
      if (i == 0) { 
        outer.image(blobs.get(i), 0, 0);
      } else {
        outer.rect(xCord+blobs.get(i-1).width, 0, blobs.get(i).width, blobs.get(i).height);
        outer.image(blobs.get(i), xCord+blobs.get(i-1).width, 0);
        xCord+= blobs.get(i-1).width;
      }
      xCord+= 5;
    }
    */
    
    return blobs; 
  }


  static boolean isCharacterImage(PImage img, PImage originalPlate, PApplet outer) {
    // rule 1, Too large or small
    if (img.width < 0.02*originalPlate.width) return false;
    if (img.width > 0.3*originalPlate.width) return false; 
    if (img.height < 0.25* originalPlate.height) return false;

    // rule 2, Area
    int area =  countBlackPix(img, outer);
    if (area < 0.15*img.height*img.width) return false; 

    // rule 3, Blobs positioned at too high or low
    if (img.height/2 < 0.25 * originalPlate.height) return false;
    if (img.height/2 > 0.75 * originalPlate.height) return false;


    // rule 4, Blobs at the corners of the image
    int[] massCenter = ImageUtils.computeCenterOfMass(img, outer);

    if (massCenter[0] < 0.015*originalPlate.width && massCenter[1] < 0.015 *originalPlate.height) return false;
    if (massCenter[0] < 0.015*originalPlate.width && massCenter[1] > 0.985 *originalPlate.height) return false;
    if (massCenter[0] > 0.985*originalPlate.width && massCenter[1] < 0.015 *originalPlate.height) return false;
    if (massCenter[0] > 0.985*originalPlate.width && massCenter[1] > 0.985 *originalPlate.height) return false;

    return true;
  }


  static int countBlackPix(PImage img, PApplet outer) {
    int sum = 0; 
    for (int c : img.pixels) if (outer.red(c) == 0) sum++;
    return sum;
  }


  static ArrayList <PImage> connectedComponentAnalysis(PImage plate, PApplet outer) {
    class Pixel {
      int col; // the grayscale value from 0 to 255
      int label;
      Pixel(int _col, int _label) {
        this.col = _col;
        this.label = _label;
      }
      boolean isBlack() {
        return col == 0;
      }
    }
    Pixel[] pix = new Pixel[plate.pixels.length];
    for (int i = 0; i<pix.length; i++) {
      pix[i] = new Pixel((int)outer.red(plate.pixels[i]), 0);
    }


    LinkedList<Integer> queue = new LinkedList<Integer>();
    //println(pix.length, plate.width, plate.width+pix.length);

    int currentLabel = 1; 
    pix[0].label = 1;
    for (int i = 0; i<pix.length; i++) {
      if (pix[i].isBlack() && pix[i].label == 0) {
        pix[i].label = currentLabel;
        queue.add(0, i);
        while (queue.size()>0) {
          int index = queue.pop(); // return the element and removes it from the list
          for (int j = index>plate.width ? -plate.width: 0; j<= (index<pix.length-plate.width ? plate.width: 0); j+= plate.width) { // this is not horror :)
            for (int k = index%plate.width >0 ? -1: 0; k<= (index%plate.width < plate.width-1 ? 1: 0 ); k++) {
              if (pix[index+j+k].isBlack()&& pix[index+j+k].label == 0) {
                pix[index+j+k].label = currentLabel;
                queue.add(0, index+j+k);
              }
            }
          }
        }
        currentLabel++;
      }
    }

    
    ArrayList <PImage> allBlob =  new ArrayList <PImage> ();
    ArrayList <Integer> smallestX =  new ArrayList <Integer> ();


    for (int k = 1; k<currentLabel; k++) {
      int[] boundingBox = new int[]{plate.width, plate.height, 0, 0}; // smalles x, smallest y, largest x, largest y
      for (int i = 0; i<pix.length; i++) {
        if (pix[i].label == k) {
          //outer.point(i%plate.width, i/plate.width);
          boundingBox[0] = min(boundingBox[0], i%plate.width);
          boundingBox[1] = min(boundingBox[1], i/plate.width);
          boundingBox[2] = max(boundingBox[2], i%plate.width);
          boundingBox[3] = max(boundingBox[3], i/plate.width);
        }
      }
      PImage temp = outer.createImage((boundingBox[2]- boundingBox[0]), (boundingBox[3]- boundingBox[1]), ALPHA);
      smallestX.add(boundingBox[0]);
      temp.copy(plate, boundingBox[0], boundingBox[1], temp.width, temp.height, 0, 0, temp.width, temp.height);
      allBlob.add(temp);
      //println(boundingBox[0], boundingBox[2]);
    }

    /*
    in order to sort the blobs from left to right, 
    we have to make a class that can be sorted, 
    as PImage cannot be sorted based on the x coordiantes by itself.
    */
    class Picture implements Comparable<Picture> {
      PImage img;
      int leftMostX;
      Picture(PImage _img, int _leftMostX) {
        this.img = _img;
        this.leftMostX = _leftMostX;
      }

      public int compareTo(Picture other) {
        return round(this.leftMostX - other.leftMostX) ;
      }
    }
    
    ArrayList <Picture> pics =  new ArrayList <Picture> ();
    
    for(int i = 0;i<allBlob.size(); i++){
      pics.add(new Picture(allBlob.get(i), smallestX.get(i)));
    }
    Collections.sort(pics);
    allBlob.clear();
    for(Picture p : pics) allBlob.add(p.img);

    return allBlob;
  }

  static int[] findSmallestLength(int[][] breaks, int start, int stop, int _height) {
    int max = _height, min = 0;
    for (int i = start; i < stop; i++) {
      min = max(min, breaks[i][0]);
      max = min(max, breaks[i][1]);
    }
    return new int[] {min, max};
  }
}
