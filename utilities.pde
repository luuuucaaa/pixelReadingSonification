ArrayList<PVector> drawLine(int x0, int y0, int x1, int y1)
{
  ArrayList<PVector> line = new ArrayList<PVector>();
  int dx = Math.abs(x1 - x0);
  int sx = x0 < x1 ? 1 : -1;
  int dy = -Math.abs(y1 - y0);
  int sy = y0 < y1 ? 1 : -1;
  int err = dx + dy;
  while (true) {
    line.add(new PVector(x0, y0));
    if (x0 == x1 && y0 == y1) break;
    int e2 = 2 * err;
    if (e2 >= dy) {
        err += dy;
        x0 += sx;
    }
    if (e2 <= dx) {
        err += dx;
        y0 += sy;
    }
  }
  return line;
}

ArrayList<PVector> drawPerpendicularLine(ArrayList<PVector> line, PVector intercept, String type)
{
  ArrayList<PVector> perpendicularLine = new ArrayList<PVector>();
  PVector p1 = line.get(0);
  PVector p2 = line.get(line.size() - 1);
  int dX = floor(p2.x - p1.x);
  int dY = floor(p2.y - p1.y);
  switch (type) {
    case "left":
      perpendicularLine = drawLine(int(intercept.x), int(intercept.y), int(intercept.x + dY), int(intercept.y - dX));
      break;
    case "right":
      perpendicularLine = drawLine(int(intercept.x), int(intercept.y), int(intercept.x - dY), int(intercept.y + dX));
      break;
  }
  return perpendicularLine;
}

PVector[] list2array(ArrayList<PVector> list)
{
  PVector[] arr = list.toArray(new PVector[list.size()]);
  return arr;
}

float angle(PVector p1, PVector p2)
{
  float angle = atan2(p2.y - p1.y, p2.x - p1.x);
  return degrees(angle);
}

PVector[] rotateArray(PVector[] arr, String dir, int n)
{
  int l = arr.length;
  PVector[] rotatedArr = new PVector[l];
  switch (dir) {
    case "right":
      break;
    case "left":
      n = l - n;
      break;
  }
  for (int i = 0; i < l; i++) {
    rotatedArr[(i + n) % l] = arr[i];
  }
  return rotatedArr;
}

PVector nullVector()
{
  return new PVector(-1, -1);
}

PVector[][] correctWings(PVector[] leftWing, PVector[] rightWing, String dir)
{
  int l = leftWing.length;
  PVector[] correctedLeftWing = new PVector[l];
  PVector[] correctedRightWing = new PVector[l];
  PVector buffer;
  PVector[][] correctedWings = new PVector[2][l];
  
  switch (dir) {
    case "l2r":
      buffer = leftWing[1];
      correctedLeftWing = rotateArray(leftWing, "left", 1);
      correctedLeftWing[correctedLeftWing.length - 1] = nullVector();
      correctedRightWing = rotateArray(rightWing, "right", 1);
      correctedRightWing[0] = buffer;
      break;
    case "r2l":
      buffer = rightWing[1];
      correctedRightWing = rotateArray(rightWing, "left", 1);
      correctedRightWing[correctedRightWing.length - 1] = nullVector();
      correctedLeftWing = rotateArray(leftWing, "right", 1);
      correctedLeftWing[0] = buffer;
      break;
  }
  correctedWings[0] = correctedLeftWing;
  correctedWings[1] = correctedRightWing;
  return correctedWings;
}
