/* Jenn (Ka Hyun) Lee
Professor Leong
ITGM 347: Applied Principles | Physical Computing
Project B: Sound Visualization Kinect
*/

// KINECT LIBRARY (SIMPLEOPENNI)
import org.openkinect.processing.*;
import SimpleOpenNI.*;
SimpleOpenNI context;


// AUDIO LIBRARY (MINIM)
import ddf.minim.*;

// Background track
AudioSnippet player;
// Sound effects from hitboxes
AudioSnippet sound;
AudioSnippet sound0;
AudioSnippet sound1;
AudioSnippet sound2;

AudioSnippet []boxSounds = new AudioSnippet[4];

Minim minim;


// Variables for "hitboxes" and point cloud rotation
float rotation = 0;
boolean wasJustInBox = false;
int boxSize = 300;

PVector boxCenter = new PVector(-500,100,600);
PVector boxCenter0 = new PVector(100,600,600);
PVector boxCenter1 = new PVector(2000, -1000, 600);
PVector boxCenter2 = new PVector(-400,-400,500);

PVector []boxCenters = new PVector[4];


// Scale
float s = 1; 


// Variables for line drawing and point interpolations
int closestValue;
int closestX;
int closestY;

// Store depth of the last point captured
int closestZ;
float previousZ;

// Most recent x and y
float previousX;
float previousY;


// Array for points that stay on canvas after being drawn (so the line stays)
float[] xLinePoints = new float[0];
float[] yLinePoints = new float[0];
float[] zLinePoints = new float[0];

int[] brushStrokePoints = new int[0];

int lastTotalBrushStrokePoints = 0;
boolean finishedStroke = true;

PImage bg;


void setup(){
  
// P3D for 3D
  size(1280,960,P3D);
  bg = loadImage("bg.jpg");
  
// Sound "hitbox" arrays
  boxCenters[0] = boxCenter;
  boxCenters[1] = boxCenter0;
  boxCenters[2] = boxCenter1;
  boxCenters[3] = boxCenter2;
  
  context = new SimpleOpenNI(this);
    
  context.enableDepth();
  context.enableUser();
  context.setMirror(false);
  
  //image(context.depthImage(),0,0);


// Loading Minim/sound library
  minim = new Minim(this);
  player = minim.loadSnippet("background.mp3");
  
  sound = minim.loadSnippet("harp.mp3");
  sound0 = minim.loadSnippet("drip.mp3");
  sound1 = minim.loadSnippet("ambient.mp3");
  sound2 = minim.loadSnippet("random.mp3");
  
// Assigning sounds
  boxSounds[0] = sound;
  boxSounds[1] = sound0;
  boxSounds[2] = sound1;
  boxSounds[3] = sound2;

   
// Playing background instrumental
  player.play();
  player.loop();

}



void draw(){
  
// Dark blue bg
 // background(bg);
  background(0);

// Closest value of 
  closestValue = 8000;
  context.update();
  
// Point cloud rotating/mapping
  translate(width/2,height/2,-1000);
  rotateX(radians(180));
  translate(0,0,1000);
  
  rotateY(radians(map(mouseX,0,width,-180,180)));  
  scale(s);
  stroke(255);
    
//image(context.userImage(),0,0, 1280, 960);
  PVector[] depthPoints = context.depthMapRealWorld();


// Call function for checking the depth points are hitting boxes
 checkInBoxes(depthPoints);
  
  
// Drawing sound spheres
// Sphere 1
 translate(boxCenters[0].x,boxCenters[0].y,boxCenters[0].z);
    noStroke();
    fill(163,147,191,50);
    sphere(200);
   
// Sphere 2
 translate(boxCenters[1].x,boxCenters[1].y,boxCenters[1].z);
    noStroke();
    fill(71,229,188,50);
    sphere(500);
 
// Sphere 3
 translate(boxCenters[2].x,boxCenters[2].y,boxCenters[2].z);
    noStroke();
    fill(58,1,92,50);
    sphere(800);
   
// Sphere 4
 translate(boxCenters[3].x,boxCenters[3].y,boxCenters[3].z);
    noStroke();
    fill(163,147,191,50);
    sphere(300);
 
 
// Placing depth values into array
 int[] depthValues = context.depthMap();
  
  
  for(int y = 0; y <480; y++){
     for(int x = 0; x <640; x++) {
       
       // Reverse coordinate values
       int reversedX = 640-x-1;
       int reversedY = 480-y-1;
        
       // Find array index
       int i = reversedX+reversedY*640; 
       int currentDepthValue = depthValues[i];
         
         // Minimum/maximum depth threshold for reading points to draw the line
         //if(currentDepthValue > 10 && currentDepthValue <610 && currentDepthValue < closestValue){
         if(currentDepthValue > 10 && currentDepthValue <8000 && currentDepthValue < closestValue){

           closestValue = currentDepthValue;
          
           closestX = x;
           closestY = y;
           closestZ = currentDepthValue;
           finishedStroke = false;
           
           //println(finishedStroke);
           
         }
        
         else{
          
           //println(finishedStroke+"1");
         
           if(finishedStroke == false){
             
             finishedStroke = true;
             
             // println("ltbsp: "+lastTotalBrushStrokePoints);
             // println("xlp: "+xLinePoints.length);
             
             brushStrokePoints = append(brushStrokePoints, ((xLinePoints.length)-lastTotalBrushStrokePoints));
             lastTotalBrushStrokePoints = brushStrokePoints.length;
             
           }
         
        }
        
     }
  }
  
  
// Linear interpolation
  float interpolatedX = lerp(previousX,closestX,0.3f);
  float interpolatedY = lerp(previousY,closestY,0.3f);
  
  //float interpolatedZ = lerp(previousZ,closestZ,0.3f);
  float interpolatedZ = lerp(previousZ, closestZ,0.3);
  
  // line(previousX,previousY,interpolatedX,interpolatedY);
  
  xLinePoints = append(xLinePoints, (interpolatedX*2));
  yLinePoints = append(yLinePoints, (interpolatedY*2));
  zLinePoints = append(zLinePoints, (interpolatedZ*2));
  
  previousX = interpolatedX;
  previousY = interpolatedY;
  previousZ = interpolatedZ;
  
  
// Drawing the line
  for(int x= 1; x < xLinePoints.length; x++){
    
   stroke(160,236,208,150);
     //  stroke(255,0,0);

    strokeWeight(10);
    
    line(width-xLinePoints[x-1], yLinePoints[x-1], zLinePoints[x-1], width-xLinePoints[x], yLinePoints[x], zLinePoints[x]);
    
    strokeCap(ROUND);
    
  }
  
  int pointsGoneThrough = 0;
  int colorChoice = 255;
  
}


// Function for checking the "hitboxes"
void checkInBoxes(PVector[] depthPoints){
  
  int depthPointsInBox = 0;
  
  //print(depthPoints.length);
  
// Create point cloud
  for(int j= 0; j < boxCenters.length; j++){
    for(int i = 0; i< depthPoints.length;i+=10){
      
       //print("index: "+i);
       PVector currentPoint = depthPoints[i];
      
         if(currentPoint.x > boxCenters[j].x - boxSize/2){
           if(currentPoint.y > boxCenters[j].y - boxSize/2 && currentPoint.y < boxCenters[j].y + boxSize/2){
             if(currentPoint.z > boxCenters[j].z - boxSize/2 && currentPoint.z < boxCenters[j].z + boxSize/2){
                
                depthPointsInBox++;
                
              }
            }
         }
         
       // Blue ish
       stroke(140,222,220);
       strokeWeight(1);
       point(currentPoint.x,currentPoint.y,currentPoint.z);
      
     }
       
  boolean isInBox = (depthPointsInBox > 0);
  //boolean testMe = false;
   
   
  // "Hitting" box
  if(isInBox && !wasJustInBox){
    
    boxSounds[j].play(); 
       
  }
  
  // If not in hitbox
  if(!boxSounds[j].isPlaying()){
  
    boxSounds[j].rewind();
    boxSounds[j].pause();
  
  }
     
  wasJustInBox = isInBox;
    
 } 
}


void mousePressed(){
  
// Saving drawing
  save("myPainting.png");
  
// Reset bg
  background(4,7,20);
  
}


void stop(){
  
// Stopping/closing Minim
  player.close();
  minim.stop(); 
  super.stop();
  
}
