static class Segmentation {


  static ArrayList <PImage> plateSegmentation(PImage plate, PApplet outer) {
    // based on Koo et al, 2009

    plate = preprossing(plate, outer);

    color[] pix = plate.pixels;
    float[] colVal = new float[plate.width];

    outer.image(plate, 0, 0);

    //for (int col = 0; col<plate.width; col++) {
    //  int breakTop = 0, breakBottom = plate.height;
    //  for (int row = 0; row<plate.height; row++) {
    //    if (outer.red(pix[row*plate.width + col]) == 255) {
    //      breakTop = row;
    //      break;
    //    }
    //  }
    //  for (int row = plate.height-1; row>=0; row--) {
    //    if (outer.red(pix[row*plate.width + col]) == 255) {
    //      breakBottom = row;
    //      break;
    //    }
    //  }
    //  for (int row = breakTop; row< breakBottom; row++) {
    //    if (outer.red(pix[row*plate.width + col]) == 255) {
    //      colVal[col]++;
    //    }
    //  }

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
    plate.filter(THRESHOLD, 1-ImageUtils.averageBrightness(plate)); // find the average intensity to filter dynamicly insted of taking a static value
    plate = ImageUtils.cropBorders(plate, outer);
    return plate;
  }


  static ArrayList <PImage> blobSegmentation(PImage plate, PApplet outer) {
    plate = preprossing(plate, outer);
    
    
    
    return null;
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
