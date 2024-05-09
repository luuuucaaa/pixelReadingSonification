class ShapeScanner_old {
  
  Shape shape;
  ArrayList<PVector> axis, wingL, wingR;
  int posIdx, wingLIdxY, wingRIdxY, wingLIdxX, wingRIdxX, wingLDir, wingRDir;
  int wingWidth;
  PVector pos, wingLPos, wingRPos;
  boolean isWingLDone, isWingRDone;
  
  PVector wingLReader;

  ShapeScanner_old(Shape _shape)
  {
    shape = _shape;
    axis = shape.majorAxis;
    wingWidth = 3;
    init();
  }
  void init()
  {
    posIdx = 0;
    wingLIdxY = 0;
    wingRIdxY = 0;
    wingLIdxX = -wingWidth;
    wingRIdxX = -wingWidth;
    pos = axis.get(posIdx);
    wingL = drawPerpendicularLine(axis, pos, "left");
    wingR = drawPerpendicularLine(axis, pos, "right");
    wingLPos = wingL.get(wingLIdxY);
    wingRPos = wingR.get(wingRIdxY);
    wingLDir = 1;
    wingRDir = 1;
    isWingLDone = false;
    isWingRDone = false;
    
    wingLReader = new PVector();
  }
  void updatePos()
  {
    posIdx++;
    if (posIdx > axis.size() - 1) {
      posIdx = 0;
    }
    pos = axis.get(posIdx);
    wingL = drawPerpendicularLine(axis, pos, "left");
    wingR = drawPerpendicularLine(axis, pos, "right");
  }
  void updateWingIdcsY()
  {
    if (isWingLDone && isWingRDone) {
      wingLDir = 1;
      wingLIdxY = 0;
      isWingLDone = false;
      wingRDir = 1;
      wingRIdxY = 0;
      isWingRDone = false;
      updatePos();
    }
    
    wingLPos = wingL.get(wingLIdxY); 
    
    do {
      wingLIdxY += wingLDir;
    } while ((wingLIdxY > 0 && wingLIdxY < wingL.size()) && !isShape(wingL.get(wingLIdxY)));
    
    if (wingLIdxY >= wingL.size()) {
      wingLIdxY = wingL.size() - 1;
      wingLDir *= -1;
     // isWingLDone = true;
      do {
        wingLIdxY += wingLDir;
      } while ((wingLIdxY > 0 && wingLIdxY < wingL.size()) && !isShape(wingL.get(wingLIdxY)));
    } else if (wingLIdxY <= 0) {
      wingLIdxY = 0;
      wingLDir *= -1;
      isWingLDone = true;
    }
    
    wingRPos = wingR.get(wingRIdxY); 
    
    do {
      wingRIdxY += wingRDir;
    } while ((wingRIdxY > 0 && wingRIdxY < wingR.size()) && !isShape(wingR.get(wingRIdxY)));
    
    if (wingRIdxY >= wingR.size()) {
      wingRIdxY = wingR.size() - 1;
      wingRDir *= -1;
      // isWingRDone = true;
      do {
        wingRIdxY += wingRDir;
      } while ((wingRIdxY > 0 && wingRIdxY < wingR.size()) && !isShape(wingR.get(wingRIdxY)));
    } else if (wingRIdxY <= 0) {
      wingRIdxY = 0;
      wingRDir *= -1;
      isWingRDone = true;
    }
  }
  void updateWingIdcsX()
  {
    wingLIdxX++;
    wingLReader = new PVector(wingLPos.x + wingLIdxX, wingLPos.y);
    if (wingLIdxX > wingWidth) {
      wingLIdxX = - wingWidth;
      updateWingIdcsY();
    }
    println(wingLIdxX);
  }
  void show()
  {
    for (int i = 0; i < wingL.size(); i++) {
      fill(shape.col);
      if (exists(wingL.get(i))) {
        if (shape.shapeMask[int(wingL.get(i).x)][int(wingL.get(i).y)]) {
          rect(wingL.get(i).x * RES, wingL.get(i).y * RES, RES, RES);
        }
      }
      if (exists(wingR.get(i))) {
        if (shape.shapeMask[int(wingR.get(i).x)][int(wingR.get(i).y)]) {
          rect(wingR.get(i).x * RES, wingR.get(i).y * RES, RES, RES);
        }
      }
    }
    fill(255);
    rect(pos.x * RES, pos.y * RES, RES, RES);
    
    rect(wingLPos.x * RES, wingLPos.y * RES, RES, RES);
    rect(wingRPos.x * RES, wingRPos.y * RES, RES, RES);
    
    fill(255,0,0);
    rect(wingLReader.x * RES, wingLReader.y * RES, RES, RES);
  }
  void run()
  {
    updateWingIdcsX();
    show();
  }
  boolean exists(PVector pos)
  {
    if (pos.x >= 0 && pos.x < shape.shapeMask.length && pos.y >= 0 && pos.y < shape.shapeMask[0].length) {
      return true;
    } else {
      return false;
    }
  }
  boolean isShape(PVector pos)
  {
    if (exists(pos) && shape.shapeMask[int(pos.x)][int(pos.y)]) {
      return true;
    } else {
      return false;
    }
  }
}
