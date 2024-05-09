class PixelGrid {
  
  PImage imgData;
  color[] img;
  int cols, rows;
  Pixel[][] pxs;
  
  PixelGrid(String filepath)
  {
    loadImageData(filepath);
    cols = floor(imgData.width);
    rows = floor(imgData.height);
    pxs = new Pixel[cols][rows];
    int imgIdx = 0;
    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols; x++) {
        PVector pixelPos = new PVector(x * RES, y * RES);
        pxs[x][y] = new Pixel(pixelPos, img[imgIdx]);
        imgIdx++;
      }
    }
  }
  void loadImageData(String filepath)
  {
    imgData = loadImage(filepath);
    imgData.resize(floor(SCL * imgData.width / RES), floor(SCL * imgData.height / RES));
    imgData.loadPixels();
    img = imgData.pixels;
  }
  void activate(ArrayList<PVector> pixelPositions)
  {
    for (int i = 0; i < pixelPositions.size(); i++) {
      pxg.pxs[int(pixelPositions.get(i).x)][int(pixelPositions.get(i).y)].isActive = true;
    }
  }
  void show()
  {
    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols; x++) {
        pxs[x][y].show();
      }
    }
  }
}
