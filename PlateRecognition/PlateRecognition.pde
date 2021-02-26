import java.io.*;
NeuralNetwork numberNet;
NeuralNetwork letterNet;
DataSet trainingLettersSet;
DataSet testingLettersSet;
DataSet trainingDigitsSet;
DataSet testingDigitsSet;
void setup() {
  //println(useNeuralNetwork("5.jpg"));
  try {
    letterNet = new NeuralNetwork(784, 600, 400, 200, 27);
    numberNet = new NeuralNetwork(784, 300, 100, 10);
    /*
    trainingDigitsSet = createTrainingSet(0, 60000, 784, 10, "emnist-digits-train-images.idx3-ubyte", "emnist-digits-train-labels.idx3-ubyte");
    trainData(50, 50, 1200, "numberNet");
     */

    trainingLettersSet = createTrainingSet(0, 60000, 784, 27, "emnist-letters-train-images.idx3-ubyte", "emnist-letters-train-labels.idx3-ubyte"); //60000 is the number of letters. change this maybe
    trainData(50, 50, 1200, "letterNet.txt", trainingLettersSet, letterNet);

    //String path = dataPath("");
    //println(path);
    //numberNet = NeuralNetwork.loadNetwork(path + "\\saves\\network.txt");
    //testingDigitsSet = createTestSet(0, 10000);
    //testData();
  } 
  catch(Exception e) {
    println(e);
  }
}

void draw() {
}

int useNeuralNetwork(String path) {
  PImage number = loadImage(path);
  number.resize(200, 200);
  int imageArea = number.height * number.width;
  numberNet = new NeuralNetwork(imageArea, 600, 300, 26);

  number.filter(GRAY);
  double[] pixelList = new double[number.pixels.length];

  for (int i = 0; i< pixelList.length; i++) pixelList[i] = brightness(number.pixels[i]);

  numberNet.feedForward(pixelList);
  return numberNet.getIndexOfLargest(numberNet.activation[numberNet.NETWORK_SIZE-1]);
}

int useNeuralNetwork(String path, NeuralNetwork network) {
  PImage number = loadImage(path);
  number.resize(200, 200);
  numberNet = network;

  number.filter(GRAY);
  double[] pixelList = new double[number.pixels.length];

  for (int i = 0; i< pixelList.length; i++) pixelList[i] = brightness(number.pixels[i]);

  numberNet.feedForward(pixelList);
  return numberNet.getIndexOfLargest(numberNet.activation[numberNet.NETWORK_SIZE-1]);
}

// https://stackoverflow.com/questions/10813154/how-do-i-convert-a-number-to-a-letter-in-java
private String getCharForNumber(int i) {
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

void trainData(int epochs, int loops, int batch_size, String file, DataSet set, NeuralNetwork net) throws IOException {
  for (int e = 0; e < epochs; e++) {
    net.train(set, loops, batch_size);
    System.out.println("Epoch:  " + (e+1) + "  Out of:  " + epochs);
    String path = dataPath("");
    net.saveNetwork(path + "\\networks\\" + file);
  }
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
