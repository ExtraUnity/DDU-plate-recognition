static class Picture implements Comparable<Picture> {
  PImage img;
  int[] boundingBox;
  int[] center;
  int width;
  int height;
  Picture(PImage _img, int[] boundingBox) {
    this.img = _img;
    this.boundingBox = boundingBox;
    this.width = boundingBox[2]-boundingBox[0];
    this.height = boundingBox[3]-boundingBox[1];
    this.center = this.center();
  }
  Picture() {
  }

  public int compareTo(Picture other) {
    return round(this.boundingBox[0] - other.boundingBox[0]);
  }

  private int[] center() { //imagine that private functions work :)
    int[] output = new int[]{0, 0};
    output[0] = (this.boundingBox[0] + this.boundingBox[2])/2;
    output[1] = (this.boundingBox[1] + this.boundingBox[3])/2;
    return output;
  }
}
