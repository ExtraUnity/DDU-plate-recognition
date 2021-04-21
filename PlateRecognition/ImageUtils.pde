static class ImageUtils {
  static PlateRecognition main;

  static PImage stretchRandom(PImage img) {
    PImage newImg = img.get();
    int imgWidth = img.width;
    int imgHeight = img.height;
    int newWidth = (int)(main.random(0.8, 1.2)*imgWidth);
    int newHeight = (int)(main.random(0.8, 1.2)*imgHeight);
    newImg.resize(newWidth, newHeight); //NOTE: resize() takes a very long time
    newImg.resize(0, imgHeight);
    return newImg;
  }

  static PImage lowerResolution(PImage img) {
    PImage newImg = img.get();
    int imgWidth = img.width;
    int imgHeight = img.height;
    float random = main.random(0.1, 0.2); 
    newImg.resize(ceil(random*imgWidth), ceil(random*imgHeight)); //lowers to random amount between 10% and 20%
    newImg.resize(imgWidth, imgHeight); //return the same image but lower resolution
    return newImg;
  }

  static PImage randomDots(PImage img, int maxAmount) {
    PImage newImg = img.get();
    int random = (int)main.random(0, maxAmount); //random amount of dots
    for (int i = 0; i<random; i++) {

      newImg.pixels[(int)main.random(0, newImg.pixels.length)] = main.alphaToPixel((main.random(0, 1)>0.7 ? 255 : 0)); //70% black dots
    }

    return newImg;
  }

  static PImage cropBorders(PImage img) {
    int upperBound = 0, lowerBound = 0, rightBound = 0, leftBound = 0;
  upper: 
    for (int y = 0; y<img.height; y++) {
      for (int x = 0; x<img.width; x++) {
        if (main.brightness(img.pixels[y*img.width+x]) != 0) {
          upperBound = y;
          break upper;
        }
      }
    }

  lower: 
    for (int y = img.height-1; y>=0; y--) {
      for (int x = 0; x<img.width; x++) {
        if (main.brightness(img.pixels[y*img.width+x]) != 0) {
          lowerBound = y;
          break lower;
        }
      }
    }
    if (lowerBound == 0) {
      lowerBound = img.height-1;
    }

  left: 
    for (int x = 0; x<img.width; x++) {
      for (int y = 0; y<img.height; y++) {
        if (main.brightness(img.pixels[y*img.width+x]) != 0) {
          leftBound = x;
          break left;
        }
      }
    }

  right: 
    for (int x = img.width-1; x>=0; x--) {
      for (int y = 0; y<img.height; y++) {
        if (main.brightness(img.pixels[y*img.width+x]) != 0) {
          rightBound = x;
          break right;
        }
      }
    }
    if (rightBound == 0) {
      rightBound = img.width-1;
    }

    return img.get(leftBound, upperBound, rightBound-leftBound, lowerBound-upperBound);
  }

  static PImage fitInto(PImage img, int newWidth, int newHeight, int backgroundColor) {

    float sourceAspectRatio = (float) img.width / (float) img.height;
    float resultAspectRatio = (float) newWidth / (float) newHeight;
    float newImgWidth, newImgHeight;

    if (resultAspectRatio > sourceAspectRatio) {
      //Use heights
      newImgHeight = newHeight;
      newImgWidth = (newImgHeight / (float)img.height) * (float)img.width;
    } else {
      //Use widths
      newImgWidth = (float) newWidth;
      newImgHeight = (newImgWidth / (float)img.width) * (float)img.height;
    }

    PImage scaledImg = img.copy();
    scaledImg.resize(round(newImgWidth), round(newImgHeight));

    PImage newImg = main.createImage(newWidth, newHeight, ARGB);

    for (int i = 0; i<newImg.pixels.length; i++) {
      newImg.pixels[i] = backgroundColor;
    }
    newImg.copy(scaledImg, 0, 0, (int)scaledImg.width, (int)scaledImg.height, (int)(newImg.width/2)-(int)(newImgWidth/2), (int)(newImg.height/2)-(int)(newImgHeight/2), (int)scaledImg.width, (int)scaledImg.height);

    return newImg;
  }

  static PImage centerWithMassInto(PImage source, int imgWidth, int imgHeight, int backgroundColor) {
    PImage result = main.createImage(imgWidth, imgHeight, ARGB);
    for (int i = 0; i<result.pixels.length; i++) {
      result.pixels[i] = backgroundColor;
    }
    int[] centerOfMass = computeCenterOfMass(source);
    result.copy(source, 0, 0, source.width, source.height, round(result.width/2f)-centerOfMass[0], round(result.height/2f)-centerOfMass[1], source.width, source.height);
    return result;
  }

  static int[] computeCenterOfMass(PImage img) {
    long xSum = 0;
    long ySum = 0;
    long num = 0;

    for (int x = 0; x < img.width; x++) {
      for (int y = 0; y < img.height; y++) {
        int weight = (int)main.red(img.pixels[y*img.width+x]);
        xSum += x * weight;
        ySum += y * weight;
        num += weight;
      }
    }
    return new int[] {(int)((double) xSum / num), (int)((double)ySum / num)};
  }


  static PImage filterImageByMedian(PImage img, PApplet outer) {
    img.filter(INVERT);
    PImage newImg = outer.createImage(img.width-1, img.height-1, ARGB);

    for (int startY = 1; startY<newImg.height; startY++) {
      for (int startX = 1; startX<newImg.width; startX++) {
        int[] imgMatrix = new int[9];
        for (int matrixY = 0; matrixY<3; matrixY++) {
          for (int matrixX = 0; matrixX<3; matrixX++) {
            imgMatrix[(matrixY)*3+(matrixX)] = (int)outer.red(img.pixels[(startY+matrixY-1)*img.width+(startX+matrixX-1)]);
          }
        }

        newImg.pixels[(startY)*newImg.width+(startX)] = main.alphaToPixel(median(imgMatrix));
      }
    }
    //img.filter(INVERT);
    newImg.filter(INVERT);
    return newImg;
  }

  static int median(int[] array) {
    array = sort(array);
    return array[array.length/2];
  }

  static float medianBrightness(PImage image) {
    //image.filter(GRAY);
    int[] brightnesses = new int[image.pixels.length];
    for (int i = 0; i < brightnesses.length; i++) {
      brightnesses[i] = (int)main.red(image.pixels[i]);
    }
    brightnesses = sort(brightnesses);
    return (float) brightnesses[brightnesses.length/2]/255.0;
  }

  static float averageBrightness(PImage image) {
    image.filter(GRAY);
    float sum = 0;
    for (int i = 0; i < image.pixels.length; i++) {
      sum += main.red(image.pixels[i]);
    }
    return (sum/image.pixels.length)/255.0;
  }
  
  @Deprecated
  static PImage contrastExtension(PImage out) {
    //  the contrast extension makes the image sharper
    /*
     Find the sum of the histogram values.
     Normalize these values dividing by the total number of pixels. 
     Multiply these normalized values by the maximum gray-level value (in the picture).
     Map the new gray level values
     */

    out.filter(GRAY);
    float[] valueFrequency = new float[256];

    for (color c : out.pixels) {
      valueFrequency[(int)main.red(c)]++;
    }

    float[] cumulative  = new float[256];
    cumulative[0] = valueFrequency[0]/out.pixels.length;

    for (int i = 1; i< cumulative.length; i++) {
      cumulative[i] = cumulative[i-1] + valueFrequency[i]/out.pixels.length;
    }
    for (int i = 0; i<out.pixels.length; i++) {
      out.pixels[i] = main.alphaToPixel(floor(255 * cumulative[(int)main.red(out.pixels[i])]));
    }

    float[] valueFrequencyPost = new float[256];

    for (color c : out.pixels) {
      valueFrequencyPost[(int)main.red(c)]++;
    }

    float[] cumulativePost = new float[256];
    cumulativePost[0] = valueFrequencyPost[0]/out.pixels.length;
    for (int i = 1; i< cumulativePost.length; i++) {
      cumulativePost[i] = cumulativePost[i-1] + valueFrequencyPost[i]/out.pixels.length;
    }
    float mostCommon = main.getIndexOfLargest(valueFrequencyPost);
    //println(mostCommon);

    //for (int i = 0; i<256; i++) {
    //  outer.stroke(main.alphaToPixel(255));
    //  outer.strokeWeight(3);  
    //  outer.point(i, 400-(cumulativePost[i])*400);
    //  outer.stroke(main.alphaToPixel(0));
    //  outer.point(i, 400-(valueFrequencyPost[i])/12);
    //}

    return out;
  }

  static int myColor(int grayscale) { // converts a single grayscale value to the color dataformat in processing.
    String binary = String.format("%8s", Integer.toBinaryString(grayscale)).replace(' ', '0');
    String binaryCombined = ("11111111"+binary+binary+binary);
    return Integer.parseUnsignedInt(binaryCombined, 2);
  }

  
  // inspired by Edge Detection example in processing
  @Deprecated
  static PImage cannyEdgeDetector(PImage img) {
    img.filter(BLUR, 1.4);

    Edge[] edges = sobelFilter(img);

    PImage thinEdges = edgeThinning(img, edges);
    PImage output = hysteresis(thinEdges, 0.1, 0.3); // wiki recommends 0.1 and 0.3

    return output;
  }
  
  @Deprecated
  static PImage edgeThinning(PImage img, Edge[] edges) {
    PImage output = main.createImage(img.width-4, img.height-4, ARGB);

    for (int row = 0; row < output.height; row++) {
      for (int col = 0; col < output.width; col++) {
        Edge center = edges[(row+1)*(output.width+2) + (col+1)];
        Edge positive = null;
        Edge negative = null;


        switch(center.direction) {
        case 0:
          positive = edges[(row+1)*(output.width+2) + (col+2)];
          negative = edges[(row+1)*(output.width+2) + (col)];        
          break; 

        case 1:
          positive = edges[(row+2)*(output.width+2) + (col+2)];
          negative = edges[(row)*(output.width+2) + (col)];        
          break;

        case 2:
          positive = edges[(row+2)*(output.width+2) + (col+1)];
          negative = edges[(row)*(output.width+2) + (col+1)];
          break;

        case 3:
          positive = edges[(row+2)*(output.width+2) + (col)];
          negative = edges[(row)*(output.width+2) + (col+2)];        
          break;         

        default:
          positive = center;
          negative = center;
          break;
        }

        int index = row * output.width + col;

        if (center.magnitude > positive.magnitude && center.magnitude > negative.magnitude) {
          output.pixels[index] = main.alphaToPixel(center.magnitude);
        } else {
          center.magnitude = 0;
          output.pixels[index] = main.alphaToPixel(0);
        }
      }
    }
    return output;
  }


  static enum Threshold {
    STRONG, WEAK, NONE
  }
  
  @Deprecated
  static PImage hysteresis(PImage img, float lowThreshold, float highThreshold) {
    PImage output = main.createImage(img.width-2, img.height-2, ARGB);
    Threshold[] thresholds = new Threshold[img.pixels.length];

    for (int i = 0; i < img.pixels.length; i++) {
      if (main.red(img.pixels[i])/255d > highThreshold) thresholds[i] = Threshold.STRONG;
      else if (main.red(img.pixels[i])/255d < lowThreshold) thresholds[i] = Threshold.NONE;
      else thresholds[i] = Threshold.WEAK;
    }

    for (int row = 0; row < output.height; row++) {
      for (int col = 0; col < output.width; col++) {
        int outputIndex = row *output.width + col;
        int imgIndex = (row+1) * (img.width) + (col+1);

        if (thresholds[imgIndex] == Threshold.STRONG) output.pixels[outputIndex] = main.alphaToPixel(255);
        if (thresholds[imgIndex] == Threshold.NONE) output.pixels[outputIndex] = main.alphaToPixel(0);

        if (thresholds[imgIndex] == Threshold.WEAK) {
          for (int dy = -1; dy<=1; dy++) {
            for (int dx = -1; dx<=1; dx++) {
              if (thresholds[imgIndex +dy *img.width + dx] == Threshold.STRONG) {
                output.pixels[outputIndex] = main.alphaToPixel(255);
                break;
              }
            }
          }
          output.pixels[outputIndex] = main.alphaToPixel(0);
        }
      }
    }

    return output;
  }

  @Deprecated
  static Edge[] sobelFilter(PImage img) {
    int [][] xKernel= new int[][] { {1, 0, -1}, 
      {2, 0, -2}, 
      {1, 0, -1}};

    int [][] yKernel= new int[][] { {1, 2, 1}, 
      {0, 0, 0}, 
      {-1, -2, -1}};   

    int lengthOut = img.pixels.length - 2*img.height - 2*(img.width-2);

    Edge[] edges = new Edge[lengthOut];
    PImage output = main.createImage(img.width-2, img.height-2, ARGB);

    for (int row = 1; row < img.height-1; row++) {
      for (int col = 1; col < img.width-1; col++) {
        int xSum = 0;
        int ySum = 0;
        for (int kRow = -1; kRow <=1; kRow++ ) {
          for (int kCol = -1; kCol <= 1; kCol++) {
            float grayValue = main.red(img.pixels[(row+kRow) * img.width + (col + kCol)]);
            xSum += grayValue * xKernel[kRow+1][kCol+1];
            ySum += grayValue * yKernel[kRow+1][kCol+1];
          }
        }

        Edge temp = new Edge(xSum, ySum);
        edges[(row-1) * (img.width-2) + (col-1)] = temp;
        output.pixels[(row-1) * (img.width-2) + (col-1)] = main.alphaToPixel(temp.magnitude); //
      }
    }

    //outer.image(output, 0, 200);    

    return edges;
  }


  static class Edge { // a polar vector. Stores the intencity of the edge and its direction, in 8 directions. 
    int magnitude; 
    int direction;
    Edge(int gradientX, int gradientY) {
      this.magnitude = (int) sqrt(gradientX*gradientX + gradientY*gradientY);

      float fullAngle = atan2(gradientY, gradientX); // from -pi to pi
      if (fullAngle < 0) fullAngle += PI;
      this.direction = roundDirection((int)(fullAngle / (PI/8)));
      //if(fullAngle != 0) println(fullAngle, fullAngle / (PI/8), this.direction);
    }

    int roundDirection(int partialAngle) {
      switch(partialAngle) {
      case 0:
      case 7:
      case 8:
        return 0;

      case 1:
      case 2:
        return 1;

      case 3:
      case 4:
        return 2;

      case 5:
      case 6:
        return 3;

      default:
        return -1;
      }
    }
  }

  static boolean localMinima(int[] a, int index) {
    return a[index] <=  a[index-1] && a[index] <=  a[index+1];
  }
}
