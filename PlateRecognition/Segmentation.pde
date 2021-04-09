static class Segmentation { //<>//
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
    plate.filter(BLUR, 1);

    //plate = ImageUtils.contrastExtension(plate,outer);
    plate = ImageUtils.filterImageByMedian(plate, outer);
    plate.resize(plate.width+1, plate.height+1);
    //println(ImageUtils.averageBrightness(plate, outer), ImageUtils.medianBrightness(plate, outer), (ImageUtils.averageBrightness(plate, outer)+ ImageUtils.medianBrightness(plate, outer))/2.0);
    //plate.filter(THRESHOLD, ); // find the average intensity to filter dynamicly insted of taking a static value
    //outer.image(plate, 0, 0);
    plate.filter(THRESHOLD, (ImageUtils.averageBrightness(plate, outer)+ ImageUtils.medianBrightness(plate, outer))/2.0);
    //outer.image(plate, 0, 250);
    plate = ImageUtils.cropBorders(plate, outer);


    return plate;
  }


  static ArrayList <PImage> blobSegmentation(PImage plate, PApplet outer, NeuralNetwork numberNetwork, NeuralNetwork letterNetwork, PlateRecognition main) {
    // Based on Yoon, 2011
    plate = preprossing(plate, outer);

    ArrayList <Picture> blobs = connectedComponentAnalysis(plate, outer);

    ArrayList <Picture> nonCharBlobs = new ArrayList <Picture>();
    blobs = blobSplit(blobs, outer);
    for (int i = 0; i<blobs.size(); i++) {
      if (!isCharacterImage(blobs.get(i), plate, outer)) nonCharBlobs.add(blobs.get(i));
    }

    blobs.removeAll(nonCharBlobs);
    blobs = blobSplit(blobs, outer);
    blobs = doubleLineSort(plate, blobs, outer);

    //int k = 4;
    //isCharacterImage(blobs.get(k), plate, outer);
    //outer.image(blobs.get(k).img, 0, 0);

    // visual feedback system:
    /*
    outer.background(125);
     outer.stroke(#00ff00);
     int xCord = 0; 
     for (int i = 0; i< blobs.size(); i++) {
     if (i == 0) { 
     outer.image(blobs.get(i).img, 0, 0);
     } else {
     outer.rect(xCord+blobs.get(i-1).img.width, 0, blobs.get(i).img.width, blobs.get(i).img.height);
     outer.image(blobs.get(i).img, xCord+blobs.get(i-1).img.width, 0);
     xCord+= blobs.get(i-1).img.width;
     }
     xCord+= 5;
     }
     */

    ArrayList <PImage> output = new ArrayList <PImage>();
    for (Picture p : blobs) output.add(p.img);
    //println();
    ArrayList<Double> confidences = new ArrayList<Double>();
    for (PImage p : output) {

      //THIS GIVES THE EXCEPTION: java.lang.IllegalArgumentException: Width (0) and height (43) cannot be <= 0
      double[] numberConfidence = main.useNeuralNetwork(p, numberNetwork);
      double[] letterConfidence = main.useNeuralNetwork(p, letterNetwork);

      confidences.add(Math.max(numberConfidence[1], letterConfidence[1]));
    }

    while (output.size()>7) {  
      double[] confidencesa = new double[confidences.size()];
      for (int i = 0; i<confidences.size(); i++) confidencesa[i] = (double) confidences.get(i);
      output.remove(main.getIndexOfSmallest(confidencesa));
      confidences.remove(main.getIndexOfSmallest(confidencesa));
    }

    return output;
  }

  static boolean isDoubleLine(PImage plate, ArrayList <Picture> blobs, PApplet outer) {
    int[] heights = new int[blobs.size()];

    for (int i = 0; i<heights.length; i++) {
      heights[i] = blobs.get(i).img.height;
    }

    int median = ImageUtils.median(heights);

    boolean lessHalf = median < 0.5 * plate.height;

    int topHalf = 0; 
    for (Picture p : blobs) {
      if (p.center[1] < 0.5 * plate.height) topHalf++;
    }

    boolean fourTop = topHalf == 4;

    return lessHalf && fourTop;
  }

  static ArrayList <Picture> doubleLineSort(PImage plate, ArrayList <Picture> blobs, PApplet outer) {
    if (!isDoubleLine(plate, blobs, outer)) {
      Collections.sort(blobs); 
      return blobs;
    }

    ArrayList <Picture> top = new ArrayList <Picture>();
    ArrayList <Picture> bottom = new ArrayList <Picture>();

    for (Picture p : blobs) {
      if (p.center[1] < 0.5 * plate.height) top.add(p);
      else bottom.add(p);
    }
    Collections.sort(top);
    Collections.sort(bottom);
    top.addAll(bottom);

    return top;
  }

  static ArrayList <Picture> blobSplit(ArrayList <Picture> blobs, PApplet outer) {
    int[] widths = new int[blobs.size()];

    for (int i = 0; i<widths.length; i++) {
      widths[i] = blobs.get(i).img.width;
    }

    float median = ImageUtils.median(widths);

    for (int i = 0; i< blobs.size(); i++) {
      //println(blobs.size());
      if (blobs.get(i).img.width > 1.8*median) {
        int splitRow = leastBlackVerticalLine(blobs.get(i), outer);
        // create the left picture
        Picture fullBlob = blobs.get(i);
        PImage img = fullBlob.img.get(0, 0, splitRow, fullBlob.img.height );

        Picture leftPicture = new Picture(img, new int[]{fullBlob.boundingBox[0], fullBlob.boundingBox[1], fullBlob.boundingBox[0]+splitRow, fullBlob.boundingBox[3]});


        // create the right picture
        img = fullBlob.img.get(splitRow, 0, fullBlob.img.width-splitRow, fullBlob.img.height);
        Picture rightPicture = new Picture(img, new int[]{fullBlob.boundingBox[0]+splitRow, fullBlob.boundingBox[1], fullBlob.boundingBox[2], fullBlob.boundingBox[3]});

        // remove the old picture
        blobs.add(leftPicture);
        blobs.add(rightPicture);
        blobs.remove(i);
      }
    }
    return blobs;
  }


  static int leastBlackVerticalLine(Picture blob, PApplet outer) {
    int min = blob.img.height; 
    int minIndex = blob.img.width;
    for (int col = 1; col < blob.img.width-1; col++) {
      int blackpixels = 0;
      for (int row = 0; row <blob.img.height; row++) {
        if (outer.red(blob.img.pixels[row *blob.img.width + col]) == 0) blackpixels++;
      }
      if (blackpixels < min) {
        minIndex = col; 
        min = blackpixels;
      }
    }
    return minIndex;
  }


  static boolean isCharacterImage(Picture blob, PImage originalPlate, PApplet outer) {
    // rule 1, Too large or small
    if (blob.img.width < 0.02*originalPlate.width) return false; 
    if (blob.img.width > 0.3*originalPlate.width) return false; 
    if (blob.img.height < 0.25* originalPlate.height) return false;

    // rule 2, Area
    int area =  countBlackPix(blob.img, outer);
    if (area < 0.25*blob.img.height*blob.img.width) return false;  

    // rule 3, Blobs positioned at too high or low
    if (blob.boundingBox[3] - ((blob.boundingBox[3]- blob.boundingBox[1])/2) < 0.25 * originalPlate.height) return false;
    if (blob.boundingBox[3] - ((blob.boundingBox[3]- blob.boundingBox[1])/2) > 0.75 * originalPlate.height) return false; 


    // rule 4, Blobs at the corners of the image
    int[] massCenter = ImageUtils.computeCenterOfMass(blob.img, outer);

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


  static ArrayList <Picture> connectedComponentAnalysis(PImage plate, PApplet outer) {
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
    pix[0].label = 0; // If this is one, the alogritm returns the wrong boxes, but the sources says that it should be one. 
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
    ArrayList <int[]> boundingBoxes =  new ArrayList <int[]> ();

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

      // make a clean PImage
      // color the k labeled pixels black, keeping the rest white.
      // cut out the correct blob
      PImage kBlob = outer.createImage(plate.width, plate.height, ALPHA);

      for (int i = 0; i<kBlob.pixels.length; i++) {
        if (pix[i].label == k) kBlob.pixels[i] = ImageUtils.main.alphaToPixel(0);
        else kBlob.pixels[i] = ImageUtils.main.alphaToPixel(255);
      }

      PImage temp = outer.createImage((boundingBox[2]- boundingBox[0]), (boundingBox[3]- boundingBox[1]), ALPHA);
      boundingBoxes.add(boundingBox);
      temp.copy(kBlob, boundingBox[0], boundingBox[1], temp.width, temp.height, 0, 0, temp.width, temp.height); 
      allBlob.add(temp);
    }

    /*
     in order to sort the blobs from left to right, 
     we have to make a class that can be sorted, 
     as PImages cannot be sorted based on the x coordiantes, or any other attribute.
     */

    ArrayList <Picture> pics =  new ArrayList <Picture> ();

    for (int i = 0; i<allBlob.size(); i++) {
      pics.add(new Picture(allBlob.get(i), boundingBoxes.get(i)));
    }
    Collections.sort(pics);
    //allBlob.clear();
    //for (Picture p : pics) allBlob.add(p.img);

    return pics;
  }



  static int[] findSmallestLength(int[][] breaks, int start, int stop, int _height) {
    int max = _height, min = 0;
    for (int i = start; i < stop; i++) {
      min = max(min, breaks[i][0]);
      max = min(max, breaks[i][1]);
    }
    return new int[] {min, max};
  }

  static class Picture implements Comparable<Picture> {
    PImage img;
    int[] boundingBox;
    int[] center;
    Picture(PImage _img, int[] boundingBox) {
      this.img = _img;
      this.boundingBox = boundingBox;
      this.center = this.center();
    }
    Picture() {
    }

    public int compareTo(Picture other) {
      return round(this.boundingBox[0] - other.boundingBox[0]);
    }

    private int[] center() {
      int[] output = new int[]{0, 0};
      output[0] = (this.boundingBox[0] + this.boundingBox[2])/2;
      output[1] = (this.boundingBox[1] + this.boundingBox[3])/2;
      return output;
    }
  }
}
