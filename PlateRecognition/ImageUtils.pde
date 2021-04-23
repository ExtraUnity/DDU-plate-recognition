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


  static PImage filterImageByMedian(PImage img) {
    img.filter(INVERT);
    PImage newImg = main.createImage(img.width-1, img.height-1, ARGB);

    for (int startY = 1; startY<newImg.height; startY++) {
      for (int startX = 1; startX<newImg.width; startX++) {
        int[] imgMatrix = new int[9];
        for (int matrixY = 0; matrixY<3; matrixY++) {
          for (int matrixX = 0; matrixX<3; matrixX++) {
            imgMatrix[(matrixY)*3+(matrixX)] = (int)main.red(img.pixels[(startY+matrixY-1)*img.width+(startX+matrixX-1)]);
          }
        }

        newImg.pixels[(startY)*newImg.width+(startX)] = main.alphaToPixel(median(imgMatrix));
      }
    }
    newImg.filter(INVERT);
    return newImg;
  }

  static int median(int[] array) {
    array = sort(array);
    return array[array.length/2];
  }

  static float medianBrightness(PImage img) {
    int[] brightnesses = new int[img.pixels.length];
    for (int i = 0; i < brightnesses.length; i++) {
      brightnesses[i] = (int)main.red(img.pixels[i]);
    }
    brightnesses = sort(brightnesses);
    return (float) brightnesses[brightnesses.length/2]/255.0;
  }

  static float averageBrightness(PImage img) {
    img.filter(GRAY);
    float sum = 0;
    for (int i = 0; i < img.pixels.length; i++) {
      sum += main.red(img.pixels[i]);
    }
    return (sum/img.pixels.length)/255.0;
  }
}
