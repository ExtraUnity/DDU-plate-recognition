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

    if (this.originalImage!=null) {
      int w = originalImage.width;
      int h = originalImage.height;
      this.originalImage.resize(0, 300);
      if (this.plate!=null) {
        this.plate.width=(int)map(plate.width, 0, w, 0, this.originalImage.width);
        this.plate.height=(int)map(plate.height, 0, h, 0, this.originalImage.height);
        this.plate.boundingBox[1]=(int)map(plate.boundingBox[1], 0, h, 0, this.originalImage.height);
        this.plate.boundingBox[3]=this.plate.boundingBox[1]+this.plate.height;
        this.plate.boundingBox[0]=(int)map(plate.boundingBox[0], 0, w, 0, this.originalImage.width);
        this.plate.boundingBox[2]=this.plate.boundingBox[0]+this.plate.width;
      }
    }
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

    image(this.originalImage, width/2-this.originalImage.width/2, 0);

    for (int i = 0; i < this.segmented.size(); i++) {
      if(this.segmented.get(i).height>100) this.segmented.get(i).resize(0,100);
      
      image(this.segmented.get(i), i*spacing, this.originalImage.height+40);
      fill(0);
      textSize(36);
      textAlign(CORNER);
      text(this.foundName.charAt(i), i*spacing, this.originalImage.height+35);
    }

    strokeWeight(3);
    stroke(0, 255, 0);
    fill(0, 0);
    rect(width/2-this.originalImage.width/2+plate.boundingBox[0], plate.boundingBox[1], plate.width, plate.height);
  }
}
