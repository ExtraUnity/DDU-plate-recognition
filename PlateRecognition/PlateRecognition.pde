import java.io.*; //<>// //<>// //<>//
import java.util.LinkedList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Random;
import java.util.Arrays;
import java.lang.Object;
import java.util.*;
import java.lang.*;

DataSet trainingLettersSet;
DataSet testingLettersSet;
DataSet trainingDigitsSet;
DataSet testingDigitsSet;

ArrayList<AnalysisResult> results = new ArrayList<AnalysisResult>();
static PApplet p = new PApplet();

ArrayList<PVector> points;
double[] drawNum;

int debugCounter = 0; 

void setup() {
  size(700, 700);
  NeuralNetwork numberNet;
  NeuralNetwork letterNet;


  //background(0);
  String path = dataPath("");
  ImageUtils.main = this;
  try {

    letterNet = NeuralNetwork.loadNetwork(path + "\\networks\\letterNet.txt");
    numberNet = NeuralNetwork.loadNetwork(path + "\\networks\\numberNet.txt");
    
    //letterNet = new NeuralNetwork(784, 600, 400, 300, 300, 100, 27);
    //numberNet = new NeuralNetwork(784, 300, 100, 10);

    //trainingLettersSet = createTrainingSet(0, 60000, 784, 27, "emnist-letters-train-images.idx3-ubyte", "emnist-letters-train-labels.idx3-ubyte"); //60000 is the number of letters. change this maybe
    //testingLettersSet = createTestingSet(0, 14800, 784, 1, "emnist-letters-test-images.idx3-ubyte", "emnist-letters-test-labels.idx3-ubyte");
    //trainData(50, 50, 1200, "letterNet", 5, trainingLettersSet, testingLettersSet, letterNet);
    //testData(letterNet, testingLettersSet);

    //trainingDigitsSet = createTrainingSet(0, 60000, 784, 10, "emnist-digits-train-images.idx3-ubyte", "emnist-digits-train-labels.idx3-ubyte");
    //testingDigitsSet = createTestingSet(0, 40000, 784, 1, "emnist-digits-test-images.idx3-ubyte", "emnist-digits-test-labels.idx3-ubyte");
    //trainData(50, 50, 1200, "numberNet", 5, trainingDigitsSet, testingDigitsSet, numberNet);
    //testData(numberNet, testingDigitsSet);


    background(255);

    selectFile();

  }
  catch(Exception e) {
    println(e);
  }
}

void draw() {
  try {
    println(results.get(0).toString());
    results.get(0).renderPictures();
    noLoop();
  } 
  catch(Exception e) {
    //println(e);
  }
}

void exportPicture(PImage plate, String fileName) {
  String path = dataPath("") + "\\exports\\"+fileName+".jpg";
  plate.save(path);
}

void selectFile() {
  selectInput("Select a file to process:", "fileSelected");
}

AnalysisResult analyseImage(File selection) {
  String expectedName = selection.getName().replace(".jpg", "");
  PImage mainPicture = loadImage(selection.getAbsolutePath());
  String path = dataPath("");
  mainPicture = loadImage(path+ "\\plates\\"+selection.getName());

  NeuralNetwork letterNet = null; 
  NeuralNetwork numberNet = null; 
  try {
    letterNet = NeuralNetwork.loadNetwork(path + "\\networks\\letterNet.txt");
    numberNet = NeuralNetwork.loadNetwork(path + "\\networks\\numberNet.txt");
  } 
  catch (IOException IOErr) {
    println(IOErr);
  }
  catch(ClassNotFoundException classErr) {
    println(classErr);
  }
  long time = 0; 
  Picture plate = null;
  ArrayList <PImage> segmentedPictures = null;
  String foundName = null;

  try {
    time = System.nanoTime();
    plate = plateLocalisation(mainPicture);
    segmentedPictures = Segmentation.blobSegmentation(plate.img, this, numberNet, letterNet, this);
    foundName = recognizeImages(segmentedPictures, numberNet, letterNet);
    time = System.nanoTime() - time;
  } 
  catch(Exception e) {
    println(e);
  }

  return new AnalysisResult(expectedName, foundName, time, mainPicture, plate, segmentedPictures);
}

void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel");
  } else if (!selection.getName().endsWith("jpg") && !selection.getName().endsWith("png")) {
    println("Wrong file format: Only .jpg and .png are supported");
  } else {
    results.add(analyseImage(selection));
  }
}


double[] useNeuralNetwork(String path, NeuralNetwork network) {
  PImage img = loadImage(path);
  return useNeuralNetwork(img, network);
}

double[] useNeuralNetwork(PImage _img, NeuralNetwork network) {
  PImage img = _img.get();

  /*
  this might become part of another step
   */
  img.filter(INVERT);

  img.resize(width, height);

  /*
  Preprocess image to look like the ones from EMNIST database
   */

  // The images must be drawn on the screeen if they are to be rotated and flipped

  //translate(width/2, height/2);
  //rotate(-PI/2);
  //scale(-1, 1);
  //translate(-width/2, -height/2);

  //image(img, 0, 0);

  //translate(width/2, height/2);
  //scale(-1, 1);
  //rotate(PI/2);
  //translate(-width/2, -height/2);

  //loadPixels();
  //background(0);

  //img = createImage(width, height, ALPHA);
  //img.pixels = pixels;
  //int[] pix = img.pixels;
  //pix = rotateArrayQuarter(pix, (int) sqrt(pix.length), (int) sqrt(pix.length));
  //pix = flipArray(pix, (int) sqrt(pix.length), (int) sqrt(pix.length));
  //img.pixels = rotateArrayQuarter(img.pixels, (int) sqrt(img.pixels.length), (int) sqrt(img.pixels.length));
  //img.pixels = flipArray(img.pixels, (int) sqrt(img.pixels.length), (int) sqrt(img.pixels.length));
  //img.pixels = pix;

  img = ImageUtils.cropBorders(img, this); 
  img = ImageUtils.fitInto(img, 20, 20, color(0), this);
  img = ImageUtils.centerWithMassInto(img, 28, 28, color(0), this);

  //image(img, 0, 0);

  double[] pixelList = new double[img.pixels.length];

  for (int i = 0; i< pixelList.length; i++) {
    pixelList[i] = (double)(brightness(img.pixels[i])) / ((double)256);
  }


  //pixelList = flipArray(pixelList, (int) sqrt(pixelList.length), (int) sqrt(pixelList.length));
  double[] guess = network.feedForward(pixelList, 0);

  return new double[] {getIndexOfLargest(guess), guess[getIndexOfLargest(guess)]};
}

// https://stackoverflow.com/questions/10813154/how-do-i-convert-a-number-to-a-letter-in-java
String getCharForNumber(int i) {
  return i > 0 && i < 27 ? String.valueOf((char)(i + 64)) : null;
}


DataSet createTrainingSet(int lower, int upper, int inputSize, int outputSize, String imageFile, String labelFile) throws IOException {
  DataSet set = new DataSet(inputSize, outputSize); //input size output size

  try {
    MnistReader fileReader = new MnistReader();
    String path = dataPath("");
    int[][] trainingImages = fileReader.loadMnistImages(new File(path + "\\" + imageFile)); 
    int[] trainingLabels = fileReader.loadMnistLabels(new File(path +"\\" + labelFile));
    for (int i = lower; i<upper; i++) {
      double[] input = new double[inputSize];
      double[] output = new double[outputSize];

      output = createLabels(trainingLabels[i], output.length);

      for (int j = 0; j<trainingImages[i].length; j++) {
        input[j] = ((double)trainingImages[i][j]) / ((double)256);
      }
      input = rotateArrayQuarter(input, (int) sqrt(input.length), (int) sqrt(input.length));
      input = flipArray(input, (int) sqrt(input.length), (int) sqrt(input.length));
      set.addData(input, output);
    }
  } 
  catch(Exception e) {
    println(e);
  }
  return set;
}

DataSet createTestingSet(int lower, int upper, int inputSize, int outputSize, String imageFile, String labelFile) throws IOException {
  DataSet set = new DataSet(inputSize, outputSize); 

  try {
    MnistReader fileReader = new MnistReader();
    String path = dataPath("");
    int[][] trainingImages = fileReader.loadMnistImages(new File(path + "\\" + imageFile)); 
    int[] trainingLabels = fileReader.loadMnistLabels(new File(path +"\\" + labelFile));
    for (int i = lower; i<upper; i++) {
      double[] input = new double[inputSize];
      double[] output = new double[outputSize];

      output[0] = (double)trainingLabels[i];

      for (int j = 0; j<trainingImages[i].length; j++) {
        input[j] = ((double)trainingImages[i][j]) / ((double)256);
      }
      input = rotateArrayQuarter(input, (int) sqrt(input.length), (int) sqrt(input.length));
      input = flipArray(input, (int) sqrt(input.length), (int) sqrt(input.length));
      set.addData(input, output);
    }
  } 
  catch(Exception e) {
    println(e);
  }
  return set;
}


void trainData(int epochs, int loops, int batch_size, String file, int stopThreshold, DataSet trainingSet, DataSet testingSet, NeuralNetwork net) throws IOException {
  float bestTest = 0;
  int wrongTurns = 0;
  for (int e = 0; e < epochs; e++) {
    net.train(trainingSet, loops, batch_size);
    System.out.println("Epoch:  " + (e+1) + "  Out of:  " + epochs);
    float test = testData(net, testingSet);
    String path = dataPath("");
    if (test<bestTest) {
      wrongTurns++;
      if (wrongTurns == 0 || wrongTurns == stopThreshold) {//Early stopping to prevent overfitting
        println("stopping training");

        net.saveNetwork(path + "\\networks\\" + file + ".txt");
        break;
      }
    } else {
      bestTest = test;
      wrongTurns = 0;
      net.saveNetwork(path + "\\networks\\" + file + ".txt");
    }
  }
}

float testData(NeuralNetwork net, DataSet testingSet) {

  int correct = 0;
  int wrong = 0;
  for (int i = 0; i<testingSet.data.size(); i++) {
    double[] result = net.feedForward(testingSet.getInput(i), 0);

    if (getIndexOfLargest(result)==testingSet.getOutput(i)[0]) {
      correct++;
    } else {
      wrong++;
    }
  }

  println("Final test accuracy: " + ((1f*correct)/(1f*(correct+wrong)))*100 + "%");
  return ((1f*correct)/(1f*(correct+wrong)));
}

static double[] createLabels(int i, int size) {
  double[] tempLabels = new double[size];
  for (int j = 0; j<size; j++) {
    tempLabels[j] = i==j ? 1 : 0;
  }
  return tempLabels;
}

static double[] createLabels(char c, int size) {
  int i = (int) c;
  i -=65;
  double[] tempLabels = new double[size];
  for (int j = 0; j<size; j++) {
    tempLabels[j] = i==j ? 1 : 0;
  }
  return tempLabels;
}

int getIndexOfLargest(double[] a) {
  int indexMax = 0;
  for (int i = 0; i<a.length; i++) {
    indexMax = a[i] > a[indexMax] ? i : indexMax;
  }
  return indexMax;
}

int getIndexOfLargest(float[] a) {
  double[] temp = new double[a.length];
  for (int i = 0; i<temp.length; i++) temp[i] = (double) a[i];
  return getIndexOfLargest(temp);
}

int getIndexOfLargest(int[] a) {
  double[] temp = new double[a.length];
  for (int i = 0; i<temp.length; i++) temp[i] = (double) a[i];
  return getIndexOfLargest(temp);
}

int getIndexOfSmallest(double[] a) {
  int indexMin = 0;
  for (int i = 0; i<a.length; i++) {
    indexMin = a[i] < a[indexMin] ? i : indexMin;
  }
  return indexMin;
}

String recognizeImages(ArrayList <PImage> images, NeuralNetwork numberNet, NeuralNetwork letterNet) {
  // Assume the format is two lettes at the start, and numbers everywhere else
  String outputs = ""; 

  for (int i = 0; i<images.size(); i++) {
    if (i <2) {
      outputs += getCharForNumber((int)useNeuralNetwork(images.get(i), letterNet)[0] );
    } else {
      outputs += str((int)useNeuralNetwork(images.get(i), numberNet)[0]);
    }
  }  
  return outputs;
}

int alphaToPixel(int gray) {
  return color(gray);
}

//static double[] rotateArrayQuarter(double[] arr, int arrWidth, int arrHeight) {
//  double[] output = new double[arr.length];
//  for (int col = arrWidth-1; col>=0; col--) {
//    for (int row = 0; row<arrHeight; row++) {
//      output[(arrWidth-1-col)*arrWidth+row] = arr[arr.length + col - arrWidth*(arrHeight-row)];
//    }
//  }
//  return output;
//}

static double[] rotateArrayQuarter(double[] arr, int arrWidth, int arrHeight) {
  double[] output = new double[arr.length];
  for (int col = 0; col<arrWidth; col++) {
    for (int row = 0; row<arrHeight; row++) {
      output[col*arrWidth+row] = arr[arr.length + col - arrWidth*(row+1)];
    }
  }
  return output;
}

static double[] flipArray(double[] arr, int arrWidth, int arrHeight) {
  double[] output = new double[arr.length];

  for (int row = 0; row<arrHeight; row++) {
    int col = 0;
    while (col<arrWidth) {
      output[row*arrWidth+col] = arr[(row+1)*arrWidth-1-col];
      col++;
    }
  }

  return output;
}

static int[] getRandomValues(int lower, int upper, int size) {
  Random indexGenerator = new Random();
  int[] is = new int[size];
  for (int i = 0; i< size; i++) {
    int n = indexGenerator.nextInt((upper-lower)) + lower;
    while (containsValue(is, n)) {
      n = indexGenerator.nextInt((upper-lower)) + lower;
      ;
    }

    is[i] = n;
  }
  return is;
}

static boolean containsValue(int[] a, int n) {
  if (a == null) return false;
  for (int i : a) {
    if (i==n) return true;
  }
  return false;
}

Picture plateLocalisation(PImage orgImg) {
  return plateLocalisation(orgImg, 0.005, 0.4, 3, 5);
}

Picture plateLocalisation(PImage orgImg, double minArea, double percentBlack, double aspectLow, double aspectHigh) {
  orgImg.resize(700, 0);
  int orgImgHeight = orgImg.height;
  orgImg = orgImg.get(0, orgImg.height/3, orgImg.width, 2*orgImg.height/3);
  PImage blurImg = orgImg.get();

  blurImg.filter(GRAY);
  blurImg.filter(BLUR, 1.4);
  blurImg.filter(THRESHOLD, 0.7);
  blurImg.filter(INVERT);        


  ArrayList<Picture> components = Segmentation.connectedComponentAnalysis(blurImg, this);
  ArrayList<Picture> removes = new ArrayList<Picture>();
  for (int i = 0; i<components.size(); i++) {
    Picture p = components.get(i);
    if (componentTooSmall(p, blurImg, minArea) || foregroundAreaTooSmall(p, percentBlack) || aspectIntervalWrong(p, aspectLow, aspectHigh)) {
      removes.add(p);
    }
  }
  components.removeAll(removes);
  int i = 0;
  Picture plate = components.get(i);
  PImage orgPlate = orgImg.get(components.get(i).boundingBox[0], components.get(i).boundingBox[1], components.get(i).width, components.get(i).height);
  plate.img = orgPlate;
  plate.boundingBox = new int[]{plate.boundingBox[0],plate.boundingBox[1]+orgImgHeight/3,plate.boundingBox[2],plate.boundingBox[3]+orgImgHeight/3};

  return plate;
}

boolean componentTooSmall(Picture p, PImage img, double minArea) {
  return p.width*p.height < minArea*img.width*img.height;
}

boolean foregroundAreaTooSmall(Picture p, double percentBlack) {
  return Segmentation.countBlackPix(p.img, this)/ (double)p.img.pixels.length < percentBlack;
}

boolean aspectIntervalWrong(Picture p, double lower, double upper) {
  return p.img.width/ (double)p.img.height > upper || p.img.width/ (double)p.img.height < lower;
}
