import frames.timing.*;
import frames.primitives.*;
import frames.processing.*;

// 1. Frames' objects
Scene scene;
Frame frame;
Vector v1, v2, v3;
// timing
TimingTask spinningTask;
boolean yDirection;
// scaling is a power of 2
int n = 4;
int anti = 1;

// 2. Hints
boolean triangleHint = true;
boolean gridHint = true;
boolean debug = true;

// 3. Use FX2D, JAVA2D, P2D or P3D
String renderer = P3D;

void setup() {
  //use 2^n to change the dimensions
  size(512, 512, renderer);
  scene = new Scene(this);
  if (scene.is3D())
    scene.setType(Scene.Type.ORTHOGRAPHIC);
  scene.setRadius(width/2);
  scene.fitBall();

  // not really needed here but create a spinning task
  // just to illustrate some frames.timing features. For
  // example, to see how 3D spinning from the horizon
  // (no bias from above nor from below) induces movement
  // on the frame instance (the one used to represent
  // onscreen pixels): upwards or backwards (or to the left
  // vs to the right)?
  // Press ' ' to play it :)
  // Press 'y' to change the spinning axes defined in the
  // world system.
  spinningTask = new TimingTask() {
    public void execute() {
      spin();
    }
  };
  scene.registerTask(spinningTask);

  frame = new Frame();
  frame.setScaling(width/pow(2, n));

  // init the triangle that's gonna be rasterized
  randomizeTriangle();
}

void draw() {
  background(0);
  stroke(0, 255, 0);
  if (gridHint)
    scene.drawGrid(scene.radius(), (int)pow( 2, n));
  if (triangleHint)
    drawTriangleHint();
  pushMatrix();
  pushStyle();
  scene.applyTransformation(frame);
  triangleRaster();
  popStyle();
  popMatrix();
}

int getIntensity(int a, int b) {
  float pixel_witdh = 1/(anti * 1.0);
  int inside = 0;
  for(int i = 0; i < anti ; i++){
    for(int j = 0; j < anti ; j++){
      float x_a = a + pixel_witdh * i;
      float y_a = b + pixel_witdh * j;
      if( testSide(x_a, y_a) ) {
        inside += 1;
      }
    }
  }
  
  int intensity = Math.round(255*(inside/(1.0 * anti * anti)));
  return intensity;
}

// Implement this function to rasterize the triangle.
// Coordinates are given in the frame system which has a dimension of 2^n
void triangleRaster() {
  // frame.coordinatesOf converts from world to frame
  // here we convert v1 to illustrate the idea
  if (debug) {
    pushStyle();
    noStroke();
    fill(255, 255, 0, 125);
    //Vector v4;
    
    int potencia = (int)Math.pow(2, n-1);
    for(int i = - potencia; i <= potencia; i++){
      for(int j = - potencia; j <= potencia; j++){
        putColor(i, j, getIntensity(i, j));
        rect(i, j, 1, 1);
      }
    }
    
    // point( round(frame.coordinatesOf(v4).y()), round(frame.coordinatesOf(v4).y()));
    // point(round(frame.coordinatesOf(v2).x()), round(frame.coordinatesOf(v2).y()));
    // point(round(frame.coordinatesOf(v3).x()), round(frame.coordinatesOf(v3).y()));
    
    popStyle();
  }
  
  
}

void randomizeTriangle() {
  int low = -width/2;
  int high = width/2;
  v1 = new Vector(random(low, high), random(low, high));
  v2 = new Vector(random(low, high), random(low, high));
  v3 = new Vector(random(low, high), random(low, high));
}

void drawTriangleHint() {
  pushStyle();
  noFill();
  strokeWeight(2);
  stroke(255, 0, 0);
  triangle(v1.x(), v1.y(), v2.x(), v2.y(), v3.x(), v3.y());
  strokeWeight(5);
  stroke(0, 255, 255);
  point(v1.x(), v1.y());
  point(v2.x(), v2.y());
  point(v3.x(), v3.y());
  popStyle();
}

void spin() {
  if (scene.is2D())
    scene.eye().rotate(new Quaternion(new Vector(0, 0, 1), PI / 100), scene.anchor());
  else
    scene.eye().rotate(new Quaternion(yDirection ? new Vector(0, 1, 0) : new Vector(1, 0, 0), PI / 100), scene.anchor());
}

void keyPressed() {
  if (key == 'g')
    gridHint = !gridHint;
  if (key == 't')
    triangleHint = !triangleHint;
  if (key == 'd')
    debug = !debug;
  if (key == '+') {
    n = n < 7 ? n+1 : 2;
    frame.setScaling(width/pow( 2, n));
  }
  if (key == '-') {
    n = n >2 ? n-1 : 7;
    frame.setScaling(width/pow( 2, n));
  }
  if (key == 'r')
    randomizeTriangle();
  if (key == ' ')
    if (spinningTask.isActive())
      spinningTask.stop();
    else
      spinningTask.run(20);
  if (key == 'y')
    yDirection = !yDirection;
  if ( key == 'a'){
    anti *= 2;
    if( anti > 8 ){
      anti = 1;
    }
  } 
}

void putColor(float x , float y, int intensity) {
     float ax = frame.coordinatesOf(v1).x();
      float ay = frame.coordinatesOf(v1).y();
      
      float bx = frame.coordinatesOf(v2).x();
      float by = frame.coordinatesOf(v2).y();
      
      float cx = frame.coordinatesOf(v3).x();
      float cy = frame.coordinatesOf(v3).y();
      
      // a -> b      
      float t1 = abs((( bx - ax) * ( y - ay)) - ((x - ax) * (by - ay)));
      // b -> c
      float t2 = abs(((cx - bx) * (y - by)) - ((x - bx) * (cy - by)));
      // c -> a
      float t3 = abs(((ax - cx) * (y - cy)) - ((x - cx) * (ay - cy)));
      
      float m = max(t1, max(t2, t3));
      t1/=m;
      t2/=m;
      t3/=m;
      
      fill(255*(t1), 255*(t2), 255*(t3), intensity);
  }

boolean testSide(float x , float y) {
      float ax = frame.coordinatesOf(v1).x();
      float ay = frame.coordinatesOf(v1).y();
      
      float bx = frame.coordinatesOf(v2).x();
      float by = frame.coordinatesOf(v2).y();
      
      float cx = frame.coordinatesOf(v3).x();
      float cy = frame.coordinatesOf(v3).y();
      
      // a -> b      
      float t1 = (( bx - ax) * ( y - ay)) - ((x - ax) * (by - ay));
      // b -> c
      float t2 = ((cx - bx) * (y - by)) - ((x - bx) * (cy - by));
      // c -> a
      float t3 = ((ax - cx) * (y - cy)) - ((x - cx) * (ay - cy));

      return (t2>0 && t3>0 && t1>0) || (t2<0 && t3<0 && t1<0);
}
