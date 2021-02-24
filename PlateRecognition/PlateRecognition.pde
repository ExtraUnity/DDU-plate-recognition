import java.io.*;
 NeuralNetwork numberNet;

void setup() {
   numberNet = new NeuralNetwork(494314, 600, 300, 10);
   PImage number = loadImage("5.jpg");
   number.filter(GRAY);
   println("here");
   
   double[] pixelList = new double[number.pixels.length];
   
   for (int i = 0;i< pixelList.length; i++) pixelList[i] = brightness(number.pixels[i]);
   
   
   numberNet.feedForward(pixelList);
   println(numberNet.activation[numberNet.NETWORK_SIZE-1]);
}

void draw() {
  
}
