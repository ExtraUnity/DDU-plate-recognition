class Button {
  PVector pos;
  int sizeX, sizeY;
  String text;
  color textColor;
  int rounded;
  Button(int x, int y, int sizeX, int sizeY, String text) {
    this(x, y, sizeX, sizeY, text, color(255, 255, 255),0);
  }
  
  Button(int x, int y, int sizeX, int sizeY, String text, color textColor) {
    this(x, y, sizeX, sizeY, text, textColor,0);
  }

  Button(int x, int y, int sizeX, int sizeY, String text, color textColor, int rounded) {
    pos = new PVector(x, y);
    this.sizeX = sizeX;
    this.sizeY = sizeY;
    this.text = text;
    this.textColor = textColor;
    this.rounded = rounded;
  }

  boolean pressed() {
    return (mousePressed && mouseWithin());
  }

  boolean hovered() {
    return (!mousePressed && mouseWithin());
  }

  boolean mouseWithin() { //mouse is within the rectangular button
    return (mouseX > this.pos.x && mouseX < this.pos.x + this.sizeX && mouseY > this.pos.y && mouseY < this.pos.y + this.sizeY);
  }

  void render() {
    fill(80);
    if (hovered()) fill(120); 
    strokeWeight(1);
    stroke(0);
    rect(pos.x, pos.y, sizeX, sizeY);

    fill(textColor);
    textSize(20);
    textAlign(CENTER, CENTER);

    text(text, pos.x+sizeX/2, pos.y+sizeY/2);
  }
}
