import java.io.*;
NeuralNetwork numberNet;

void setup() {
  
  println(getCharForNumber(useNeuralNetwork("Y.jpg")));
}

void draw() {
}

int useNeuralNetwork(String path) {
  PImage number = loadImage(path);
  number.resize(200,200);
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
  number.resize(200,200);
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
