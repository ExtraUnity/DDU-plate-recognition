import java.io.*;
NeuralNetwork numberNet;

void setup() {
  
  println(useNeuralNetwork("5.jpg"));
}

void draw() {
}

int useNeuralNetwork(String path) {
  PImage number = loadImage(path);
  number.resize(200,200);
  int imageArea = number.height * number.width;
  numberNet = new NeuralNetwork(imageArea, 600, 300, 10);

  number.filter(GRAY);
  double[] pixelList = new double[number.pixels.length];

  for (int i = 0; i< pixelList.length; i++) pixelList[i] = brightness(number.pixels[i]);
  
  numberNet.feedForward(pixelList);
  return numberNet.getIndexOfLargest(numberNet.activation[numberNet.NETWORK_SIZE-1]);
}


int useNeuralNetwork(String path, NeuralNetwork network) {
  PImage number = loadImage(path);
  number.resize(200,200);
  numberNet = network;

  number.filter(GRAY);
  double[] pixelList = new double[number.pixels.length];

  for (int i = 0; i< pixelList.length; i++) pixelList[i] = brightness(number.pixels[i]);
  
  numberNet.feedForward(pixelList);
  return numberNet.getIndexOfLargest(numberNet.activation[numberNet.NETWORK_SIZE-1]);
}
