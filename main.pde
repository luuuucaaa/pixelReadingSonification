boolean DEBUG = false;
int RES = 10;
float SCL = 2;
int N_SHAPES = 5;

PixelGrid pxg;
ShapeGrower sg;
Shape[] sh = new Shape[N_SHAPES];
ShapeScanner_withHoles[] sc = new ShapeScanner_withHoles[N_SHAPES];

void settings()
{
  pxg = new PixelGrid("sample.jpg");
  size(pxg.cols * RES, pxg.rows * RES);
}

void setup()
{
  frameRate(200);
  for (int i = 0; i < sh.length; i++) {
    sg = new ShapeGrower(pxg, floor(random(1000, 5000)));
    sh[i] = new Shape(sg.generate());
    sh[i].analyze();
    sc[i] = new ShapeScanner_withHoles(sh[i]);
  }
}

void draw()
{
  background(0);
  pxg.show();
  for (int i = 0; i < sh.length; i++) {
    sh[i].show();
    sc[i].run();
  }
  // logMemoryStats();
}

int drawIdx = 0;
void logMemoryStats()
{
  drawIdx++;
  long maxMemory = Runtime.getRuntime().maxMemory();
  long allocatedMemory = Runtime.getRuntime().totalMemory();
  long freeMemory = Runtime.getRuntime().freeMemory();
  println(drawIdx, maxMemory, allocatedMemory, freeMemory);
}
