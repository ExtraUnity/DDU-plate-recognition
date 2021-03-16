
import java.io.*;
NeuralNetwork numberNet;
NeuralNetwork letterNet;
DataSet trainingLettersSet;
DataSet testingLettersSet;
DataSet trainingDigitsSet;
DataSet testingDigitsSet;
ArrayList<PVector> points;
double[] drawNum;
void setup() {
  size(200, 200);
  background(0);
  points = new ArrayList<PVector>();
  stroke(255);
  strokeWeight(5);
  String path = dataPath("");
  try {
    letterNet = new NeuralNetwork(784, 600, 400, 200, 27);


    numberNet = NeuralNetwork.loadNetwork(path + "\\networks\\numberNet.txt");
    //println(useNeuralNetwork("eight.jpg"));

    //numberNet = new NeuralNetwork(784, 300, 100, 10);
    //trainingDigitsSet = createTrainingSet(0, 240000, 784, 10, "emnist-digits-train-images.idx3-ubyte", "emnist-digits-train-labels.idx3-ubyte");
    //trainData(50, 50, 4800, "numberNet.txt", trainingDigitsSet, numberNet);

    testingDigitsSet = createTestingSet(0, 40000, 784, 1, "emnist-digits-test-images.idx3-ubyte", "emnist-digits-test-labels.idx3-ubyte");
    //testData(numberNet, testingDigitsSet);

    //trainingLettersSet = createTrainingSet(0, 60000, 784, 27, "emnist-letters-train-images.idx3-ubyte", "emnist-letters-train-labels.idx3-ubyte"); //60000 is the number of letters. change this maybe
    //trainData(50, 50, 1200, "letterNet.txt", trainingLettersSet, letterNet);

    //String path = dataPath("");
    //println(path);
    //numberNet = NeuralNetwork.loadNetwork(path + "\\saves\\network.txt");
    //testingDigitsSet = createTestSet(0, 10000);
    //testData();
  } 
  catch(Exception e) {
    println(e);
  }

  println(useNeuralNetwork(path+"\\five.jpg"));
}

void draw() {
  if (mousePressed) {
    if (points.size()>0) {
      if (mouseX != points.get(points.size()-1).x && mouseY != points.get(points.size()-1).y) {
        points.add(new PVector(mouseX, mouseY));
        if (points.size()>=2) {
          line(points.get(points.size()-2).x, points.get(points.size()-2).y, points.get(points.size()-1).x, points.get(points.size()-1).y);
        }
      }
    } else {
      points.add(new PVector(mouseX, mouseY));
    }
  } else {
    if (points.size()>=2) {
      background(0);

      translate(width/2, height/2);
      rotate(-PI/2);
      translate(-width/2, -height/2);

      for (int i = 1; i<points.size(); i++) {
        line(width-points.get(i-1).x, points.get(i-1).y, width-points.get(i).x, points.get(i).y);
      }

      //for (int i = 1; i<points.size(); i++) {
      //  line(points.get(i-1).x, points.get(i-1).y, points.get(i).x, points.get(i).y);
      //}

      translate(width/2, height/2);
      rotate(PI/2);
      translate(-width/2, -height/2);

      PImage img = new PImage();
      img = createImage(200, 200, ALPHA);

      loadPixels();
      updatePixels();
      for (int i = 0; i<pixels.length; i++) {
        img.pixels[i] = pixels[i];
      }

      points.clear();


      //translate(width/2,height/2);
      //rotate(PI/2);
      //scale(-1,1);


      img = ImageUtils.cropBorders(img, this);  
      img = ImageUtils.fitInto(img, 20, 20, color(0), this);
      img = ImageUtils.centerWithMassInto(img, 28, 28, color(0), this);
      //img.filter(THRESHOLD, 0.1);
      //img.filter(INVERT);


      background(0);
      img.loadPixels();

      drawNum = new double[img.pixels.length];
      for (int i = 0; i<img.pixels.length; i++) {
        drawNum[i] = (double)brightness(img.pixels[i]);
      }
      double[] confidences = numberNet.feedForward(drawNum);
      println(getIndexOfLargest(confidences), confidences[getIndexOfLargest(confidences)]);
      //background(0);
    }
  }
}



int useNeuralNetwork(String path) {
  PImage img = loadImage(path);

  /*
this might become part of another step
   */
  img.filter(GRAY);
  img.filter(THRESHOLD, 0.5);
  img.filter(INVERT);

  /*
  Preprocess image to look like the ones from EMNISt database
   */
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
  //for(int y = 0; y<img.width; y++) {
  //  for(int x = 0; x<img.height; x++) {
  //    img.pixels[y*img.width+x] = pixels[x*img.height+y];
  //  }
  //}
  img = createImage(width, height, ALPHA);
  img.pixels = pixels;
  img = ImageUtils.cropBorders(img, this);  
  img = ImageUtils.fitInto(img, 20, 20, color(0), this);
  img = ImageUtils.centerWithMassInto(img, 28, 28, color(0), this);


  double[] pixelList = new double[img.pixels.length];

  for (int i = 0; i< pixelList.length; i++) {
    pixelList[i] = (double)(brightness(img.pixels[i])) / ((double)256);
  }
  double[] guess = numberNet.feedForward(pixelList);
  return getIndexOfLargest(guess);
}

int useNeuralNetwork(String path, NeuralNetwork network) {
  PImage number = loadImage(path);
  number.resize(200, 200);
  numberNet = network;

  number.filter(GRAY);
  double[] pixelList = new double[number.pixels.length];

  for (int i = 0; i< pixelList.length; i++) pixelList[i] = brightness(number.pixels[i]);

  numberNet.feedForward(pixelList);
  return getIndexOfLargest(numberNet.activation[numberNet.NETWORK_SIZE-1]);
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

DataSet createTestingSet(int lower, int upper, int inputSize, int outputSize, String imageFile, String labelFile) throws IOException {
  DataSet set = new DataSet(inputSize, outputSize); //input size output size

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
    System.out.println("Epoch:  " + (e+1) + "  Out of:  " + epochs);
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
      println(getIndexOfLargest(net.feedForward(testingSet.data.get(i)[0])), testingSet.data.get(i)[1][0]);
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
