class ShapeGrower {
  
  PixelGrid pxg;
  int cols, rows, size;
  PVector seed;
  ArrayList<PVector> targets, grown;
  
  ShapeGrower(PixelGrid _pxg, int _size)
  {
    pxg = _pxg;
    cols = pxg.cols;
    rows = pxg.rows;
    size = _size;
    seed = new PVector();
    findSeed();
    targets = new ArrayList<PVector>();
    grown = new ArrayList<PVector>();
    updateTargets(seed);
  }
  void findSeed()
  {
    seed = new PVector(random(cols), random(rows));
    for (int attempt = 0; attempt < 10; attempt++) {
      if (pxg.pxs[int(seed.x)][int(seed.y)].isActive) {
        seed = new PVector(random(cols), random(rows));
        if (attempt == 9) {
          seed = new PVector();
        }
      } else {
        break;
      }
    }
  }
  void updateTargets(PVector target)
  {
    grown.add(target);
    if (!pxg.pxs[int(target.x)][int(target.y)].isActive) {
      if (target.x < cols - 1) {
        if (!pxg.pxs[int(target.x + 1)][int(target.y)].isActive) {
          targets.add(new PVector(target.x + 1, target.y));
        }
      }
      if (target.x > 0) {
        if (!pxg.pxs[int(target.x - 1)][int(target.y)].isActive) {
          targets.add(new PVector(target.x - 1, target.y));
        }
      }
      if (target.y < rows - 1) {
        if (!pxg.pxs[int(target.x)][int(target.y + 1)].isActive) {
          targets.add(new PVector(target.x, target.y + 1));
        }
      }
      if (target.y > 0) {
        if (!pxg.pxs[int(target.x)][int(target.y - 1)].isActive) {
          targets.add(new PVector(target.x, target.y - 1));
        }
      }
      for (int i = 0; i < grown.size(); i++) {
        targets.remove(grown.get(i));
      }
    }
  }
  void grow()
  {
    for (int i = 0; i < size; i++) {
      if (targets.size() > 0) {
        PVector t = targets.get(floor(random(targets.size())));
        updateTargets(t);
      } else {
        break;
      }
    }
  }
  ArrayList<PVector> generate()
  {
    grow();
    return grown;
  }
}
