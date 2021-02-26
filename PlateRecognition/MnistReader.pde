import java.io.*;

class MnistReader {
  BufferedInputStream input;

  int[][] loadMnistImages(File inputFile) throws IOException {

    input = new BufferedInputStream(new FileInputStream(inputFile));

    //The first four entries are 32-bit integers, hence the 4's
    input.skip(4); //Skips the magic number

    int imageNum = nextBytes(4); //number of images in file

    int rows = nextBytes(4); //reads the number of rows in an image.
    int cols = nextBytes(4); //reads the number of cols in an image

    int[][] images = new int[imageNum][rows*cols]; //Array of images containing array of pixels

    for (int i = 0; i<imageNum; i++) { //All the images
      for (int j = 0; j<rows*cols; j++) { //All the pixels in image
        images[i][j] = nextBytes(1);
      }
    }

    input.close();

    return images;
  }

  int[] loadMnistLabels(File inputFile) throws IOException {

    input = new BufferedInputStream(new FileInputStream(inputFile));

    input.skip(4);

    int labelsNum = nextBytes(4);
    int[] labels = new int[labelsNum];
    
    for(int i = 0; i<labelsNum; i++) {
      labels[i] = nextBytes(1);
    }

    return labels;
  }

  int nextBytes(int n) throws IOException {
    int num = 0;
    for (int i = n-1; i>=0; i--) { //this is only nessecary for the first lines, which have 32-bit integers
      int temp = input.read();
      num+=temp<<(i*8); //shift the series of bytes 8*i to the left, so k forms the actual value
      //60000 gets loaded as 00000000 00000000 11101010 01100000, so 4 times in the for loop. To read it correctly the bytes needs to be shifted.
    }

    return num;
  }
}
