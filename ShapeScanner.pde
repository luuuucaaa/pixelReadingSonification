class ShapeScanner {
  
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
  
  ShapeScanner(Shape _shape)
  {
    shape = _shape;
    wingWidth = 4;
    hopLength = 4;
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
    // create wings without holes
    PVector center = axis.get(posIdx);
    for (int i = 0; i < wings.length; i++) { // left or right wing
      for (int j = 0; j < wings[i].length; j++) { // offset from pos parallel to axis (from -wingWidth to wingWidth)
        String type;
        if (i == 0) {type = "left";} else {type = "right";}
        int offset = -wingWidth + j;
        PVector intercept;
        if (axisAngle > 45 && axisAngle < 135) {
          intercept = new PVector(center.x, center.y + offset);
        } else {
          if (axisAngle >= 135) {
            offset *= -1;
          }
          intercept = new PVector(center.x + offset, center.y);
        }
        wings[i][j] = list2array(drawPerpendicularLine(axis, intercept, type));
      }
    }
    // create correction signal
    int[] correctionSignal = new int[2 * wingWidth + 1];
    int j = -wingWidth;
    for (int i = 0; i < correctionSignal.length; i++) {
      if (posIdx + j >= 0 && posIdx + j < axis.size()) {
        if (axisAngle > 45 && axisAngle < 135) {
          correctionSignal[i] = floor(axis.get(posIdx + j).x - pos.x);
        } else {
          correctionSignal[i] = floor(axis.get(posIdx + j).y - pos.y);
        }
      } else {
        correctionSignal[i] = 0;
      }
      j++;
    }
    println(j);
    // correct wings
    PVector[][] buffer = new PVector[2][];
    String dir1, dir2;
    /*
    if (axisAngle >= 0 && axisAngle <= 45) || axisAngle <= 45 && axisAngle >= 135) {
      dir1 = "l2r";
      dir2 = "r2l";
    } else {
      dir1 = "r2l";
      dir2 = "l2r";
    }
    */
    dir1 = "r2l";
    dir2 = "l2r";    
    for (int i = 0; i < correctionSignal.length; i++) {
      //for (int k = 0; k < abs(correctionSignal[i]); k++) {
        if (correctionSignal[i] < 0) {
          buffer = correctWings(wings[0][i], wings[1][i], dir1);
        } else if (correctionSignal[i] > 0) {
          buffer = correctWings(wings[0][i], wings[1][i], dir2);
        } else {
          buffer[0] = wings[0][i];
          buffer[1] = wings[1][i];
        }
        wings[0][i] = buffer[0];
        wings[1][i] = buffer[1];
      //}
    }
  }
  void showWings()
  {
    if (DEBUG) {
      for (int i = 0; i < wings.length; i++) { // left or right wing
        for (int j = 0; j < wings[i].length; j++) { // offset from pos parallel to axis (from -wingWidth to wingWidth)
          for (int k = 0; k < wings[i][j].length; k++) { // offset from pos perpendicular to axis
            if (isShape(new PVector(wings[i][j][k].x, wings[i][j][k].y))) {
              stroke(0 + j * 20, 255 - j * 20, 200 * i);
              noFill();
              rect(wings[i][j][k].x * RES, wings[i][j][k].y * RES, RES, RES);
            }
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
          if (wingIdx[i][1] >= wings[i][wingWidth].length) {
            wingIdx[i][1] = 0;
            isWingDone[i] = true;
            if (isWingDone[0] && isWingDone[1]) { // break while loop if both wings are scanned
              break;
            }
          }
        }
        masterIdx++;
        if (masterIdx >= wings[i].length * wings[i][wingWidth].length) { // break while loop if none of wingPos belongs to shape
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
      if (isShape(wingPos[i])) {
        stroke(255);
        fill(255, 200 * i, 0);
        rect(wingPos[i].x * RES, wingPos[i].y * RES, RES, RES);
        if (!DEBUG) {
          if (wingPos[i].x >= 0 && wingPos[i].x < pxg.cols && wingPos[i].y >= 0 && wingPos[i].y < pxg.rows) {
            pxg.pxs[int(wingPos[i].x)][int(wingPos[i].y)].flash();
          }
        }
      }
    }
  }
  boolean isShape(PVector pos)
  {
    if (pos.x >= 0 && pos.x < pxg.cols && pos.y >= 0 && pos.y < pxg.rows && shape.shapeMask[int(pos.x)][int(pos.y)]) {
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

/*
// create correction signal
    int[] correctionSignal = new int[wings[0].length];
    float centerX = pos.x;
    float centerY = pos.y;
    int a = -wingWidth;
    if (axisAngle > 45 && axisAngle < 135) {
      for (int i = 0; i < wings[0].length; i++) {
        if (posIdx + a >= 0 && posIdx + a < axis.size()) {
          correctionSignal[i] = int(centerX - axis.get(posIdx + a).x);
        } else {
          correctionSignal[i] = 0;
        }
        a++;
      }
    } else {
      for (int i = 0; i < wings[0].length; i++) {
        if (posIdx + a >= 0 && posIdx + a < axis.size()) {
          correctionSignal[i] = int(centerY - axis.get(posIdx + a).y);
        } else {
          correctionSignal[i] = 0;
        }
        a++;
      }
    }
    // correct wing around pos
    PVector[][] buffer;
    a = -wingWidth;
    for (int i = 0; i < wings[0].length; i++) {
      if (a > 0) {
        if (axisAngle >= 0 && axisAngle <= 45 || axisAngle >= 90 && axisAngle <= 135) {
          for (int j = 0; j < abs(correctionSignal[i]); j++) {
            buffer = correctWings(wings[0][i], wings[1][i], "r2l");
            wings[0][i] = buffer[0];
            wings[1][i] = buffer[1];
          }
        } else {
          for (int j = 0; j < abs(correctionSignal[i]); j++) {
            buffer = correctWings(wings[0][i], wings[1][i], "l2r");
            wings[0][i] = buffer[0];
            wings[1][i] = buffer[1];
          }
        }
      } else if (a < 0) {
        if (axisAngle >= 0 && axisAngle <= 45 || axisAngle >= 90 && axisAngle <= 135) {
          for (int j = 0; j < abs(correctionSignal[i]); j++) {
            buffer = correctWings(wings[0][i], wings[1][i], "l2r");
            wings[0][i] = buffer[0];
            wings[1][i] = buffer[1];
          }
        } else {
          for (int j = 0; j < abs(correctionSignal[i]); j++) {
            buffer = correctWings(wings[0][i], wings[1][i], "r2l");
            wings[0][i] = buffer[0];
            wings[1][i] = buffer[1];
          }
        }
      }
      a++;
    }
*/
