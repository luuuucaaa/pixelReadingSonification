class Shape {
  
  int cols, rows;
  ArrayList<PVector> pixelPositions;
  boolean[][] shapeMask;
  ArrayList<PVector> contour = new ArrayList<PVector>();
  ArrayList<PVector> majorAxis = new ArrayList<PVector>();
  color col;
  
  Shape(ArrayList<PVector> _pixelPositions)
  {
    pixelPositions = _pixelPositions;
    cols = pxg.cols;
    rows = pxg.rows;
    shapeMask = new boolean[cols][rows];
    for (int y = 0; y < rows; y++) { 
      for (int x = 0; x < cols; x++) {
        shapeMask[x][y] = false;
      }
    }
    for (int i = 0; i < pixelPositions.size(); i++) {
      shapeMask[int(pixelPositions.get(i).x)][int(pixelPositions.get(i).y)] = true;
    }
    pxg.activate(pixelPositions);
    col = color(random(255), 100, random(255), 200);
  }
  void findContour()
  {
    for (int y = 0; y < rows; y++) { 
      for (int x = 0; x < cols; x++) {
        outerloop:
        if (shapeMask[x][y]) {
          if (x < cols - 1) {
            if (!shapeMask[x + 1][y]) {
              contour.add(new PVector(x, y));
              break outerloop;
            }
          }
          if (x > 0) {
            if (!shapeMask[x - 1][y]) {
              contour.add(new PVector(x, y));
              break outerloop;
            }
          }
          if (y < rows - 1) {
            if (!shapeMask[x][y + 1]) {
              contour.add(new PVector(x, y));
              break outerloop;
            }
          }
          if (y > 0) {
            if (!shapeMask[x][y - 1]) {
              contour.add(new PVector(x, y));
              break outerloop;
            }
          }
          // add egde pixels
          if (x == 0 || x == cols - 1 || y == 0 || y == rows - 1) {
            contour.add(new PVector(x, y));
          }
        };
      }
    }
  }
  void findMajorAxis()
  {
    float d, maxD;
    PVector maxD_p1 = new PVector();
    PVector maxD_p2 = new PVector();
    maxD = 0;
    for (int i = 0; i < contour.size(); i++) {
      for (int j = 0; j < contour.size(); j++) {
        d = sqrt(pow(contour.get(i).x - contour.get(j).x, 2) + pow(contour.get(i).y - contour.get(j).y, 2));
        if (d > maxD) {
          maxD = d;
          maxD_p1 = contour.get(i);
          maxD_p2 = contour.get(j);
        }
      }
    }
    majorAxis = drawLine(int(maxD_p1.x), int(maxD_p1.y), int(maxD_p2.x), int(maxD_p2.y));
  }
  void analyze()
  {
    findContour();
    findMajorAxis();
  }
  void show()
  {
    noStroke();
    for (int i = 0; i < contour.size(); i++) {
      stroke(col);
      noFill();
      rect(contour.get(i).x * RES, contour.get(i).y * RES, RES, RES);
    }
    for (int i = 0; i < majorAxis.size(); i++) {
      noStroke();
      fill(col);
      circle(majorAxis.get(i).x * RES + RES/2, majorAxis.get(i).y * RES + RES/2, RES/2);
    }
  }
}
