class AnalysisResult{
  String expectedName;
  String foundName;
  long processingTime;
  PImage originalImage;
  ArrayList <PImage> segmented;
  
  AnalysisResult(String expectedName, String foundName, long processingTime, PImage originalImage, ArrayList <PImage> segmented){
    this.expectedName = expectedName;
    this.foundName = foundName;
    this.processingTime = processingTime;
    this.originalImage = originalImage;
    this.segmented = segmented;
  }
  
  String toString(){
    long time = processingTime /1000000;
    String form = "Success: %b, Success %%: %f, Expected plate: %s, Found plate: %s, Time: %d ms";
    return String.format(form, analysisCorrect(), error(), expectedName, foundName, time);
  }
  
  boolean analysisCorrect(){
    return this.expectedName.equals(this.foundName);
  }
  
  float error(){
    float total = 0; 
    float correct = 0;
    for(int i = 0; i<expectedName.length() && i<foundName.length(); i++){
      total++;
      if(expectedName.charAt(i) == foundName.charAt(i)) correct++;
    }
    if (correct == 0) return 0;
    return correct/total*100;
  }
  
  void renderPictures(){
    renderPictures(80);
  }
  
  void renderPictures(int spacing){
    background(120);
    image(this.originalImage, 0, 0);
    
    for (int i = 0; i < this.segmented.size(); i++) {
      image(this.segmented.get(i), i*spacing, this.originalImage.height+40);
      fill(255);
      textSize(36);
      text(this.foundName.charAt(i), i*spacing, this.originalImage.height+35);
    }
  
  }
}
