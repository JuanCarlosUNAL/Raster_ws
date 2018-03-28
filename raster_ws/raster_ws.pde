import java.util.List;
import java.util.ArrayList;

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

// 2. Hints
boolean triangleHint = true;
boolean gridHint = true;
boolean debug = true;

// 3. Use FX2D, JAVA2D, P2D or P3D
String renderer = P3D;

void setup() {
  //use 2^n to change the dimensions
  size(1024, 1024, renderer);
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

// Implement this function to rasterize the triangle.
// Coordinates are given in the frame system which has a dimension of 2^n
void triangleRaster() {
  // frame.coordinatesOf converts from world to frame
  // here we convert v1 to illustrate the idea
  if (debug) {
    pushStyle();
    noStroke();
    
    int potencia = (int)Math.pow(2, n-1);
    for(int i = - potencia; i <= potencia; i++){
      for(int j = - potencia; j <= potencia; j++){
        List<Float>  baricentric = getBaricentricCoords(i,j);
        if( testSide(baricentric) ){
          getFill(baricentric);
          rect(i - 0.5, j - 0.5, 1, 1);
        }
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
}

void getFill(List<Float> baricentric) {
  List<Float> components = new ArrayList<Float>();
  float sum = 0;
  for(float x : baricentric) sum += Math.abs(x);
  for(float x : baricentric){
    components.add( 255 * Math.abs(x)/sum );
  }
  fill(components.get(0), components.get(1), components.get(2));
}

List<Float> getBaricentricCoords(float x , float y){
      float ax = frame.coordinatesOf(v1).x();
      float ay = frame.coordinatesOf(v1).y();
      
      float bx = frame.coordinatesOf(v2).x();
      float by = frame.coordinatesOf(v2).y();
      
      float cx = frame.coordinatesOf(v3).x();
      float cy = frame.coordinatesOf(v3).y();
      
      List<Float> ans = new ArrayList<Float>();
      // a -> b      
      ans.add( ((bx - ax) * ( y - ay)) - ((x - ax) * (by - ay)) );
      // b -> c
      ans.add( ((cx - bx) * (y - by)) - ((x - bx) * (cy - by)) );
      // c -> a
      ans.add( ((ax - cx) * (y - cy)) - ((x - cx) * (ay - cy)) );

      return ans;
}

boolean testSide(List<Float> coords) {
    return (coords.get(1)>0 && coords.get(2)>0 && coords.get(0)>0)
        || (coords.get(1)<0 && coords.get(2)<0 && coords.get(0)<0);
}