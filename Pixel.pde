class Pixel {
  
  PVector pos;
  color col;
  float alpha;
  boolean isActive;
  
  Pixel(PVector _pos, color _col)
  {
    pos = _pos;
    col = _col;
    alpha = 200;
    isActive = false;
  }
  void flash()
  {
    alpha = 0;
  }
  void show()
  {
    fill(col);
    noStroke();
    rect(pos.x, pos.y, RES, RES);
    if (alpha < 200) {
      alpha += 0.2;
    } else if (!isActive) {
      alpha = 255;
    }
    fill(0, alpha);
    rect(pos.x, pos.y, RES, RES);
  }
}
