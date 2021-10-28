import java.util.*;
import controlP5.*;
int unit = 5;
boolean makeTerrain = true;
PShape coloredSquare;
PShape triangleFan;
PShape hexFan;
PShape monster;
Slider rows;
Slider columns;
Slider terrainSize;
Slider heightModifier;
Slider snowThreshold;
Button generate;
Textfield loadFromFile; 
Toggle strokeActive;
Toggle colorActive;
Toggle blendActive;
CameraController controller = new CameraController();
RadioButton cameraMovement;
ControlP5 cp5;

ArrayList<PVector> vertData = new ArrayList<PVector>();
ArrayList<Integer> triangleData = new ArrayList<Integer>();

class CameraController {
   PVector position; 
   PVector target;
   float FOV = 90;
   float theta = 0;
   float phi = 0;
   float radius;
   int xClickedStart = -1;
   int yClickedStart = -1;
   
   ArrayList<PVector> targetList = new ArrayList<PVector>();
   int currPos = 0;
   
   int movementType;
   
   CameraController(){
     this.position = new PVector(width/2, -height/2, (height/2.0) / tan(PI*30.0 / 180.0));
     this.target = new PVector(0, 0, 0);
     this.radius = abs(target.dist(position));
     this.theta = (acos(position.y/radius)*180)/PI;
     this.phi = (acos(position.x/(radius*sin(radians(theta))))*180)/PI;
   }
   
   void Update(){
     if(movementType == 1){
       if(mousePressed == true && !cp5.isMouseOver()){
         if(xClickedStart != -1 && yClickedStart != -1){
           phi += map(mouseX, xClickedStart, width-1, 0, 360);
           theta += map(mouseY, yClickedStart, height-1, 0, 179);
           position.x = target.x + radius*cos(radians(phi))*sin(radians(theta));
           position.y = target.y + radius*cos(radians(theta));
           position.z = target.z + radius*sin(radians(theta))*sin(radians(phi));
           xClickedStart = mouseX;
           yClickedStart = mouseY;
         }
         else {
           xClickedStart = mouseX;
           yClickedStart = mouseY;
         }
       }
       else {
         xClickedStart = -1;
         yClickedStart = -1;
       }
     }
     if(movementType == 0){
       phi += 1;
       position.x = target.x + radius*cos(radians(phi))*sin(radians(theta));
       position.y = target.y + radius*cos(radians(theta));
       position.z = target.z + radius*sin(radians(theta))*sin(radians(phi));
     }
     
    perspective(radians(FOV), width/(float)height, 0.1, 1000);
     
    camera(position.x, position.y, position.z, 
            target.x, target.y,target.z, 
            0, sin(radians(theta)),0);
   }
   
   void AddLookAtTarget(PVector target){
     targetList.add(target);
   }
   
   void cycleTarget(){
     this.target = targetList.get(currPos);
      position.x = target.x + radius*cos(radians(phi))*sin(radians(theta));
         position.y = target.y + radius*cos(radians(theta));
         position.z = target.z + radius*sin(radians(theta))*sin(radians(phi));
     currPos++;
     if(currPos >= targetList.size()){
         currPos = 0;
     }
   }
   
   void Zoom(float FOV){
     this.FOV += FOV*3;
   }
   
}

void setup(){
  size(1600, 1000, P3D);
  cp5 = new ControlP5(this);
  cameraMovement = cp5.addRadioButton("Camera Movement")
                      .setPosition(200,200)
                      .setSize(40,40)
                      .setColorForeground(color(120))
                      .setColorActive(color(255))
                      .setColorLabel(color(255))
                      .setItemsPerRow(1)
                      .setSpacingColumn(50)
                      .addItem("Camera Rotate (press num1)",1)
                      .addItem("Click and Drag (press num2)",2);
                      
   cameraMovement.activate(0);
   rows =  cp5.addSlider("rows")
                            .setMin(1)
                            .setMax(100)
                            .setPosition(20,20)
                            .setHeight(15)
                            .setWidth(160)
                            .setValue(1)
                            .setCaptionLabel("ROWS");
                            
   columns = cp5.addSlider("columns")
                            .setMin(1)
                            .setMax(100)
                            .setPosition(20,50)
                            .setHeight(15)
                            .setWidth(160)
                            .setValue(1)
                            .setCaptionLabel("COLUMNS");
                            
    terrainSize = cp5.addSlider("terrainSize")
                            .setMin(20)
                            .setMax(50)
                            .setPosition(20,80)
                            .setHeight(15)
                            .setWidth(160)
                            .setValue(20)
                            .setCaptionLabel("TERRAIN SIZE");
                            
    heightModifier = cp5.addSlider("heightModifier")
                            .setMin(-5)
                            .setMax(5)
                            .setPosition(300,80)
                            .setHeight(15)
                            .setWidth(160)
                            .setValue(-5)
                            .setCaptionLabel("HEIGHT MODIFIER");
                            
    snowThreshold = cp5.addSlider("snowThreshold")
                            .setMin(1)
                            .setMax(5)
                            .setPosition(300,110)
                            .setHeight(15)
                            .setWidth(160)
                            .setValue(1)
                            .setCaptionLabel("SNOW THRESHOLD");
                            
    generate = cp5.addButton("generate")
                            .setPosition(20,115)
                            .setHeight(20)
                            .setSize(100,30)
                            .setValue(0); 
                            
    loadFromFile = cp5.addTextfield("load from file")
              .setPosition(20, 160)
              .setSize(200, 30)
              .setAutoClear(false)
              .setValue("");
              
    strokeActive = cp5.addToggle("stroke active")
                 .setPosition(300, 20)
                 .setSize(70,30);
                 
    colorActive = cp5.addToggle("color active")
                 .setPosition(400, 20)
                 .setSize(70,30);
                 
    blendActive = cp5.addToggle("blend active")
                 .setPosition(500, 20)
                 .setSize(70,30);
 controller.movementType = 1;
                      
 cp5.setAutoDraw(false);
 

}

void draw(){
  
  controller.Update();
  
    
  background(128);
  //   for(int i = -10; i < 11; i ++){
  //  stroke(255);
  //  if(i==0)
  //    stroke(0,0,255);
  //  line(i*10,0,100, i*10,0,-100);
  //  if(i==0)
  //    stroke(255,0,0);
  //  line(100,0,i*10, -100,0,i*10);
  //}
   colorMode(RGB);
     for(int i = 0; i < vertData.size(); i++){
      pushMatrix();
      translate(vertData.get(i).x*unit, vertData.get(i).y*unit, vertData.get(i).z*unit);
      sphere(5);
      popMatrix();
    }
  
  
  camera();
  perspective();
  cp5.draw();
  
}

void mouseWheel(MouseEvent event){
  float e = event.getCount();
  controller.Zoom(e);
}

void keyPressed(){
  //spacebar
  if(keyCode == 32){
    controller.cycleTarget();
  }
  if(keyCode == 49){
    cameraMovement.activate(0);
    controller.movementType = 0;
  }
  if(keyCode == 50){
    cameraMovement.activate(1);
    controller.movementType = 1;
  }
  println(keyCode);
}

public void rows(int val){
  
}

public void columns(int val){
}

public void terrainSize(int val){
}

public void generate(){
   vertData.clear();
  for(int i = (int)-(terrainSize.getValue()/2); i < terrainSize.getValue()/2; i+=(int)(terrainSize.getValue()/rows.getValue())){
     for(int j =(int)-(terrainSize.getValue()/2); j < terrainSize.getValue()/2; j+=(int)(terrainSize.getValue()/columns.getValue())){
       vertData.add(new PVector(i,0,j));
     }  
   }
}

void controlEvent(ControlEvent theEvent) {
  if(theEvent.isFrom(cameraMovement)) {
    print("got an event from "+theEvent.getName()+"\t");
 }
}
