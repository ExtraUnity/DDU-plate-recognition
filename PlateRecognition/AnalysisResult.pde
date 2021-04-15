class AnalysisResult {
  String expectedName;
  String foundName;
  long processingTime;
  PImage originalImage;
  Picture plate;
  ArrayList <PImage> segmented;

  AnalysisResult(String expectedName, String foundName, long processingTime, PImage originalImage, Picture plate, ArrayList <PImage> segmented) {
    this.expectedName = expectedName;
    this.foundName = foundName;
    this.processingTime = processingTime;
    this.originalImage = originalImage;
    this.plate = plate;
    this.segmented = segmented;
  }
  
  @Override
  String toString() {
    long time = processingTime /1000000;

    
    String form = "Success: %b, Success %%: %s, Expected plate: %s, Found plate: %s, Time: %d ms";
    return String.format(form, analysisCorrect(), error(), expectedName, foundName, time);
  }

  boolean analysisCorrect() {
    return this.expectedName.equals(this.foundName);
  }

  String error() {
    float total = 0; 
    float correct = 0;
    for (int i = 0; i<expectedName.length() && i<foundName.length(); i++) {
      total++;
      if (expectedName.charAt(i) == foundName.charAt(i)) correct++;
    }
    
    if (total == 0) return str(0);
    return str(correct/total*100);
  }

  void renderPictures() {
    renderPictures(90);
  }

  void renderPictures(int spacing) {
    background(120);
    image(this.originalImage, 0, 0);

    for (int i = 0; i < this.segmented.size(); i++) {
      image(this.segmented.get(i), i*spacing, this.originalImage.height+40);
      fill(255);
      textSize(36);
      text(this.foundName.charAt(i), i*spacing, this.originalImage.height+35);
    }

    strokeWeight(3);
    stroke(0, 255, 0);
    fill(0, 0);
    rect(plate.boundingBox[0], plate.boundingBox[1], plate.width, plate.height);
  }
}
