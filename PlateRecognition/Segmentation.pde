static class Segmentation {  //<>// //<>//
  static PImage preprossing(PImage plate) {
    if (plate == null) return null;
    plate.resize(700, 0);
    plate.filter(GRAY);
    plate = ImageUtils.filterImageByMedian(plate);
    plate.resize(plate.width+1, plate.height+1);
    plate.filter(THRESHOLD, (ImageUtils.averageBrightness(plate)+ ImageUtils.medianBrightness(plate))/2.0);
    plate = ImageUtils.cropBorders(plate);

    return plate;
  }


  static ArrayList <PImage> blobSegmentation(PImage plate, NeuralNetwork numberNetwork, NeuralNetwork letterNetwork, PlateRecognition main) {
    // Based on Yoon, 2011
    plate = preprossing(plate);
    ArrayList <Picture> blobs = connectedComponentAnalysis(plate, main);

    ArrayList <Picture> nonCharBlobs = new ArrayList <Picture>();

    for (int i = 0; i<blobs.size(); i++) {
      if (!isCharacterImage(blobs.get(i), plate, main)) nonCharBlobs.add(blobs.get(i));
    }

    blobs.removeAll(nonCharBlobs);
    if (blobs.size()==0) {
      ArrayList<PImage> arr = new ArrayList<PImage>();
      arr.add(plate);
      return arr;
    }
    blobs = blobSplit(blobs, plate, main);

    Collections.sort(blobs); 


    ArrayList <PImage> output = new ArrayList <PImage>();
    for (Picture p : blobs) output.add(p.img);

    ArrayList<Double> confidences = new ArrayList<Double>();

    for (PImage p : output) {

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

  static ArrayList <Picture> blobSplit(ArrayList <Picture> blobs, PImage plate, PApplet outer) {
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
        if (isCharacterImage(leftPicture, plate, outer) && isCharacterImage(rightPicture, plate, outer)) {
          blobs.add(leftPicture);
          blobs.add(rightPicture);
          blobs.remove(i);
        }
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
    int[] massCenter = ImageUtils.computeCenterOfMass(blob.img);

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
          for (int j = index>plate.width ? -plate.width: 0; j<= (index<pix.length-plate.width ? plate.width: 0); j+= plate.width) { // check in eight direction unless at the edges
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

    return pics;
  }
}
