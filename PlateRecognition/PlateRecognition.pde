 //<>// //<>// //<>// //<>// //<>//
import java.io.*;
NeuralNetwork numberNet;
NeuralNetwork letterNet;
DataSet trainingLettersSet;
DataSet testingLettersSet;
DataSet trainingDigitsSet;
DataSet testingDigitsSet;
ArrayList<PVector> points;
double[] drawNum;

int debugCounter = 0; 

void setup() {
  size(700, 700);
  background(0);
  String path = dataPath("");

  try {
    /*
    letterNet = new NeuralNetwork(784, 600, 400, 200, 27);
     numberNet = new NeuralNetwork(784, 300, 100, 10);
     
     trainingDigitsSet = createTrainingSet(0, 60000, 784, 10, "emnist-digits-train-images.idx3-ubyte", "emnist-digits-train-labels.idx3-ubyte");
     trainData(50, 50, 1200, "numberNet", trainingDigitsSet, numberNet);
     trainingLettersSet = createTrainingSet(0, 60000, 784, 27, "emnist-letters-train-images.idx3-ubyte", "emnist-letters-train-labels.idx3-ubyte"); //60000 is the number of letters. change this maybe
     trainData(50, 50, 1200, "letterNet", trainingLettersSet, letterNet);
     
     testingDigitsSet = createTestingSet(0, 40000, 784, 1, "emnist-digits-test-images.idx3-ubyte", "emnist-digits-test-labels.idx3-ubyte");
     testData(numberNet, testingDigitsSet);
     
     testingLettersSet = createTestingSet(0, 14800, 784, 1, "emnist-letters-test-images.idx3-ubyte", "emnist-letters-test-labels.idx3-ubyte"); //60000 is the number of letters. change this maybe
     testData(letterNet, testingLettersSet);
     */


    letterNet = NeuralNetwork.loadNetwork(path + "\\networks\\letterNet.txt");
    numberNet = NeuralNetwork.loadNetwork(path + "\\networks\\numberNet.txt");

    PImage test = loadImage(path+"\\AK.jpg");
    ArrayList <PImage> images = Segmentation.plateSegmentation(test, this);

    //PImage testTwo = Segmentation.blobColor(test,this, ? );


    String readPlate = recognizeImages(images, numberNet, letterNet);
    println(readPlate);

    background(120);
    for (int i = 0; i < images.size(); i++) {
      image(images.get(i), i*100, 150);
      fill(255);
      textSize(26);
      text(readPlate.charAt(i), i*100, 145);
    }
    //exportPicture(test, readPlate);
  }
  catch(Exception e) {
    println(e);
  }

  noLoop();
}

void exportPicture(PImage plate, String fileName) {
  String path = dataPath("") + "\\exports\\"+fileName+".jpg";
  plate.save(path);
}


int useNeuralNetwork(String path, NeuralNetwork network) {
  PImage img = loadImage(path);
  return useNeuralNetwork(img, network);
}

int useNeuralNetwork(PImage _img, NeuralNetwork network) {
  PImage img = _img.get();


  /*
  this might become part of another step
   */
  img.filter(GRAY);
  img.filter(THRESHOLD, 0.5);
  img.filter(INVERT);
  img.resize(width, height);

  /*
  Preprocess image to look like the ones from EMNIST database
   */

  // The images must be drawn on the screeen if they are to be rotated and flipped
  translate(width/2, height/2);
  rotate(-PI/2);
  scale(-1, 1);
  translate(-width/2, -height/2);

  image(img, 0, 0);

  translate(width/2, height/2);
  scale(-1, 1);
  rotate(PI/2);
  translate(-width/2, -height/2);

  loadPixels();
  background(0);

  img = createImage(width, height, ALPHA);
  img.pixels = pixels;
  img = ImageUtils.cropBorders(img, this); 
  img = ImageUtils.fitInto(img, 20, 20, color(0), this);
  img = ImageUtils.centerWithMassInto(img, 28, 28, color(0), this);

  image(img, 0, 0);

  double[] pixelList = new double[img.pixels.length];

  for (int i = 0; i< pixelList.length; i++) {
    pixelList[i] = (double)(brightness(img.pixels[i])) / ((double)256);
  }
  double[] guess = network.feedForward(pixelList);
  return getIndexOfLargest(guess);
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
      set.addData(input, output);
    }
  } 
  catch(Exception e) {
    println(e);
  }
  return set;
}


void trainData(int epochs, int loops, int batch_size, String file, DataSet set, NeuralNetwork net) throws IOException {
  for (int e = 0; e < epochs; e++) {
    net.train(set, loops, batch_size);
    println("Epoch:  " + (e+1) + "  Out of:  " + epochs);
    String path = dataPath("");
    net.saveNetwork(path + "\\networks\\" + file);
  }
}

void testData(NeuralNetwork net, DataSet testingSet) {
  int correct = 0;
  int wrong = 0;
  for (int i = 0; i<testingSet.data.size(); i++) {

    if (getIndexOfLargest(net.feedForward(testingSet.data.get(i)[0]))==testingSet.data.get(i)[1][0]) {
      correct++;
    } else {
      wrong++;
    }
    println((1f*correct)/(1f*(correct+wrong)));
  }
  println("Final test accuracy: " + ((1f*correct)/(1f*(correct+wrong)))*100 + "%");
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


String recognizeImages(ArrayList <PImage> images, NeuralNetwork numberNet, NeuralNetwork letterNet) {
  // Asume the format is AA 99 999
  String outputs = ""; 

  for (int i = 0; i<images.size(); i++) {
    if (i <2) {
      outputs += getCharForNumber(useNeuralNetwork(images.get(i), letterNet));
    } else {
      outputs += str(useNeuralNetwork(images.get(i), numberNet));
    }
  }
  return outputs;
}
