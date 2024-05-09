class ShapeScanner_withHoles {
  
  Shape shape;
  
  ArrayList<PVector> axis; // all pixel positions which belong to axis
  float axisAngle; // angle between a horizontal line and the axis (from 0 to 180);
  int posIdx; // index for axis to get ShapeScanner center on axis
  PVector pos; // position of ShapeScanner center (pos = axis.get(posIdx))
  
  int wingWidth; // width of the wings to either side of the center (so the total width is 2 * wingWidth + 1)
  int hopLength; // step size between scanner positions
  PVector[][][] wings; // all pixel positions which belong to wings in format [left or right wing][offset from pos parallel to axis][offset from pos perpendicular to axis]
  int[][] wingIdx; // index for wings to get reading head position in format [left or right wing][offset from pos parallel to axis][offset from pos perpendicular to axis]
  PVector[] wingPos; // positions of left and right reading head (wingPos[0] = wings[wingIdx[0]][wingIdx[1]][wingIdx[2]])
  boolean[] isWingDone; // true if wing is fully scanned in format (isLeftWingDone, isRightWingDone)
  
  ShapeScanner_withHoles(Shape _shape)
  {
    shape = _shape;
    wingWidth = 8;
    hopLength = 8;
    init();
  }
  void init()
  {
    axis = shape.majorAxis;
    axisAngle = angle(axis.get(0), axis.get(axis.size() - 1));
    posIdx = 0;
    pos = axis.get(posIdx);
    
    wings = new PVector[2][2 * wingWidth + 1][];
    wingIdx = new int[2][2];
    wingPos = new PVector[2];
    isWingDone = new boolean[2];
    updateWings();
  }
  void updatePos()
  {
    posIdx += hopLength;
    if (posIdx < 0 || posIdx >= axis.size()) {
      posIdx = 0;
    }
    pos = axis.get(posIdx);
    updateWings();
  }
  void showPos()
  {
    noStroke();
    fill(255);
    rect(pos.x * RES, pos.y * RES, RES, RES);
    noStroke();
    fill(shape.col);
    circle(pos.x * RES + RES/2, pos.y * RES + RES/2, RES/2);
  }
  void updateWings()
  {
    for (int i = 0; i < wings.length; i++) { // left or right wing
      for (int j = 0; j < wings[i].length; j++) { // offset from pos parallel to axis (from -wingWidth to wingWidth)
        String type;
        if (i == 0) {type = "left";} else {type = "right";}
        int k = posIdx - wingWidth + j;
        if (k >= 0 && k < axis.size()) {
          wings[i][j] = list2array(drawPerpendicularLine(axis, axis.get(k), type));
        } else {
          wings[i][j] = new PVector[0];
        }
      }
    }
  }
  void showWings()
  {
    for (int i = 0; i < wings.length; i++) { // left or right wing
      for (int j = 0; j < wings[i].length; j++) { // offset from pos parallel to axis (from -wingWidth to wingWidth)
        for (int k = 0; k < wings[i][j].length; k++) { // offset from pos perpendicular to axis
          if (isShape(new PVector(wings[i][j][k].x, wings[i][j][k].y))) {
            stroke(shape.col);
            noFill();
            //rect(wings[i][j][k].x * RES, wings[i][j][k].y * RES, RES, RES);
          }
        }
      }
    }
  }
  void updateWingPos()
  {
    for (int i = 0; i < wings.length; i++) { // left or right wing
      int masterIdx = 0; // is used to break while loop if none of wingPos belongs to shape
      do {
        wingIdx[i][0]++; // offset from pos parallel to axis (from -wingWidth to wingWidth)
        if (wingIdx[i][0] >= wings[i].length) {
          wingIdx[i][0] = 0;
          wingIdx[i][1]++; // offset from pos perpendicular to axis
          if (wingIdx[i][1] >= wings[i][wingWidth + 1].length) {
            wingIdx[i][1] = 0;
            isWingDone[i] = true;
            if (isWingDone[0] && isWingDone[1]) { // break while loop if both wings are scanned
              break;
            }
          }
        }
        masterIdx++;
        if (masterIdx >= wings[i].length * wings[i][wingWidth + 1].length) { // break while loop if none of wingPos belongs to shape
          break;
        }
      } while (wings[i][wingIdx[i][0]].length == 0 || !isShape(wings[i][wingIdx[i][0]][wingIdx[i][1]]));
      if (wings[i][wingIdx[i][0]].length > 0) {
        wingPos[i] = wings[i][wingIdx[i][0]][wingIdx[i][1]];
      } else {
        wingPos[i] = new PVector();
      }
    }
    if (isWingDone[0] && isWingDone[1]) { // update pos and reset wingIdx and wingPos
      updatePos();
      for (int i = 0; i < wings.length; i++) {
        wingIdx[i][0] = 0;
        wingIdx[i][1] = 0;
        if (wings[i][wingIdx[i][0]].length > 0) {
          wingPos[i] = wings[i][wingIdx[i][0]][wingIdx[i][1]];
        } else {
          wingPos[i] = new PVector();
        }
        isWingDone[i] = false;
      }
    }
  }
  void showWingPos()
  {
    for (int i = 0; i < wings.length; i++) { // left or right wing
      stroke(255);
      noFill();
      rect(wingPos[i].x * RES, wingPos[i].y * RES, RES, RES);
      pxg.pxs[int(wingPos[i].x)][int(wingPos[i].y)].flash();
    }
  }
  boolean isShape(PVector pos)
  {
    if (pos.x >= 0 && pos.x < shape.shapeMask.length && pos.y >= 0 && pos.y < shape.shapeMask[0].length && shape.shapeMask[int(pos.x)][int(pos.y)]) {
      return true;
    } else {
      return false;
    }
  }
  void run()
  {
    updateWingPos();
    showWings();
    showPos();
    showWingPos();
  }
}
