static class Segmentation {

  static ArrayList <PImage> plateSegmentation(PImage plate, PApplet outer) {
    return plateSegmentation(plate, 0.6, outer);
  }

  static ArrayList <PImage> plateSegmentation(PImage plate, float threshold, PApplet outer) {
    // based on Koo et al, 2009
    plate.resize(700, 0);
    plate.filter(GRAY);
    plate.filter(BLUR, 1.5);
    //float threshold = 0.6;
    plate.filter(THRESHOLD, threshold);
    plate = ImageUtils.cropBorders(plate, outer);
    color[] pix = plate.pixels;
    float[] colVal = new float[plate.width];

    //outer.image(plate, 0, 0);


    for (int col = 0; col<plate.width; col++) {
      for (int row = 0; row< plate.height; row++) {
        if (outer.red(pix[row*plate.width + col]) == 255) {
          colVal[col]++;
        }
      }
      colVal[col] /= plate.height;
    }


    ArrayList<Integer> whiteSpace = new ArrayList<Integer>();
    for (int i = 0; i<colVal.length; i++) {
      if (colVal[i] >= 0.9) {
        whiteSpace.add(i);
        //outer.stroke(#ff0000);
        //outer.line(i, 0, i, outer.height);
      }
    }

    ArrayList<Integer> breakpoints = new ArrayList<Integer>();
    for (int i = 1; i<whiteSpace.size()-1; i++) {
      if (whiteSpace.get(i+1) - whiteSpace.get(i) >1 || whiteSpace.get(i) - whiteSpace.get(i-1) >1) {
        breakpoints.add(whiteSpace.get(i));
        //outer.stroke(#00ff00);
        //outer.line(whiteSpace.get(i), 0, whiteSpace.get(i), outer.height);
      }
    }

    ArrayList <PImage> output = new ArrayList <PImage>();

    for (int i = 0; i< breakpoints.size(); i+= 2) {
      int _width = breakpoints.get(i+1) -  breakpoints.get(i);
      output.add(plate.get(breakpoints.get(i), 0, _width, plate.height));
      //outer.image(output.get(output.size()-1), breakpoints.get(i), 200);
    }


    return output;
  }

  static PImage blobColor(PImage _plate, PApplet outer, color[] colors) {
    // we make a new PImage rather than changing the existing one. that operation would be a void returning variant. 
    int k = 0;
    
    PImage plate = _plate.get(); 
    plate.resize(200, 0);
    plate.filter(GRAY);
    plate.filter(THRESHOLD, 0.6);
    outer.image(plate, 0, 200);
    
    PImage output = plate.get(); 
    
    plate.pixels[1*plate.width+1-1]= colors[k];

    for (int i = 1; i<output.height; i++) {
      for (int j = 1; j<output.height; j++) {
        float xl = outer.red(output.pixels[j*plate.width+i-1]);
        float xu = outer.red(output.pixels[(j-1)*plate.width+i]);
        float xc = outer.red(output.pixels[j*plate.width+i]);

        xl = norm(xl, 0, 255);
        xu = norm(xu, 0, 255);
        xc = norm(xc, 0, 255);

        println(xl, xu, xc, k);
        if (xc == 0) {
          continue;
        } else {
          if (xu == 1 && xl == 0) {
            output.pixels[j*plate.width+i] = output.pixels[(j-1)*plate.width+i];
          }
          if(xl == 1 && xu == 0){
             output.pixels[j*plate.width+i] = output.pixels[j*plate.width+i-1];
          }
          if(xl == 1 && xu == 1){
             output.pixels[j*plate.width+i] = output.pixels[j*plate.width+i-1];
             output.pixels[j*plate.width+i-1] = output.pixels[(j-1)*plate.width+i];
          }
          if(xl == 0 && xu == 0){
            output.pixels[j*plate.width+i-1] = colors[k];
            k++;
            if(k >= colors.length){
              k = 0;
            }
          }
        }
      }
    }


    return output;
  }
}
