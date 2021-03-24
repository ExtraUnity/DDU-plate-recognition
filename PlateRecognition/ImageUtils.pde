static class ImageUtils {
  static PlateRecognition main;
  static PImage cropBorders(PImage img, PApplet main) {
    int upperBound = 0, lowerBound = 0, rightBound = 0, leftBound = 0;
  upper: 
    for (int y = 0; y<img.height; y++) {
      for (int x = 0; x<img.width; x++) {
        //println(255-brightness(img.get(x, y)), 0);
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
    //println(newImgWidth, newImgHeight);
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
  
  
}
