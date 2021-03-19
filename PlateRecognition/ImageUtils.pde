static class ImageUtils {

  static PImage cropBorders(PImage img, PApplet main) {
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

  static PImage fitInto(PImage img, int newWidth, int newHeight, int backgroundColor, PApplet main) {

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
    scaledImg.resize((int)newImgWidth, (int)newImgHeight);

    PImage newImg = main.createImage(newWidth, newHeight, ARGB);

    for (int i = 0; i<newImg.pixels.length; i++) {
      newImg.pixels[i] = backgroundColor;
    }
    newImg.copy(scaledImg, 0, 0, (int)scaledImg.width, (int)scaledImg.height, (int)(newImg.width/2)-(int)(newImgWidth/2), (int)(newImg.height/2)-(int)(newImgHeight/2), (int)scaledImg.width, (int)scaledImg.height);

    return newImg;
  }

  static PImage centerWithMassInto(PImage source, int imgWidth, int imgHeight, int backgroundColor, PApplet main) {
    PImage result = main.createImage(imgWidth, imgHeight, ARGB);
    for (int i = 0; i<result.pixels.length; i++) {
      result.pixels[i] = backgroundColor;
    }
    int[] centerOfMass = computeCenterOfMass(source, main);
    result.copy(source, 0, 0, source.width, source.height, round(result.width/2f)-centerOfMass[0], round(result.height/2f)-centerOfMass[1], source.width, source.height);
    return result;
  }

  static int[] computeCenterOfMass(PImage img, PApplet main) {
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


  static float medianBrightness(PImage _image) {
    _image.filter(GRAY);
    int[] brightnesses = new int[_image.pixels.length];
    for (int i = 0; i < brightnesses.length; i++) {
      brightnesses[i] = _image.pixels[i] >> 16 & 0xFF;
    }
    sort(brightnesses);
    return brightnesses[brightnesses.length/2]/255.0;
  }

  static float averageBrightness(PImage _image) {
    _image.filter(GRAY);
    float sum = 0;
    for (int i = 0; i < _image.pixels.length; i++) {
      sum += _image.pixels[i] >> 16 & 0xFF;
    }

    return sum/_image.pixels.length/255.0;
  }

  static void contrastExtension(PImage image, PApplet outer) {
    //  the contrast extension makes the image sharpen
    /*
    Find the sum of the histogram values.
     Normalize these values dividing by the total number of pixels. 
     Multiply these normalized values by the maximum gray-level value.
     Map the new gray level values
     */
    image.filter(GRAY);

    float sum = 0; 
    for (color c : image.pixels) sum += outer.red(c);

    float normalized = sum / (float) image.pixels.length; // creates a floating number between 0 and 1

    normalized *=255; // creates a floating number between 0 and 255

    for (int i = 0; i< image.pixels.length; i++) {
      //image.pixels[i] = color(outer.red(image.pixels[i]) * normalized); // TODO: change to better color function
    }
  }

  static int myColor(int grayscale) { // converts a single grayscale value to the color dataformat in processing.
    String binary = String.format("%8s", Integer.toBinaryString(grayscale)).replace(' ', '0');
    String binaryCombined = ("11111111"+binary+binary+binary);
    return Integer.parseUnsignedInt(binaryCombined, 2);
  }
}
