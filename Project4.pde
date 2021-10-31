
import java.util.*;
import controlP5.*;
float unit = 1.5f;
PShape terrain; 
String imgName = "";
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
boolean strokeSwap = false;
boolean colorSwap = false;
boolean blendSwap = false;
CameraController controller = new CameraController();
RadioButton cameraMovement;
ControlP5 cp5;
color snow = color(255,255,255);
color rock = color(135,135,135);
color grass = color(143,170,64);
color dirt = color(160,128,84);
color water = color(0,75,200);

ArrayList<PVector> vertData = new ArrayList<PVector>();
ArrayList<Integer> triangleData = new ArrayList<Integer>();

class CameraController {
   PVector position; 
   PVector target;
   float FOV = 50;
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
   rows =  cp5.addSlider("rows")
                            .setMin(1)
                            .setMax(100)
                            .setPosition(20,20)
                            .setHeight(15)
                            .setWidth(160)
                            .setValue(10)
                            .setCaptionLabel("ROWS");
                    
         
   columns = cp5.addSlider("columns")
                            .setMin(1)
                            .setMax(100)
                            .setPosition(20,50)
                            .setHeight(15)
                            .setWidth(160)
                            .setValue(10)
                            .setCaptionLabel("COLUMNS");
                            
    terrainSize = cp5.addSlider("terrainSize")
                            .setMin(20)
                            .setMax(50)
                            .setPosition(20,80)
                            .setHeight(15)
                            .setWidth(160)
                            .setValue(30)
                            .setCaptionLabel("TERRAIN SIZE");
                            
    heightModifier = cp5.addSlider("heightModifier")
                            .setMin(-5)
                            .setMax(5)
                            .setPosition(300,80)
                            .setHeight(15)
                            .setWidth(160)
                            .setValue(1)
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
              .setValue("terrain0")
              .setAutoClear(false);
              
    strokeActive = cp5.addToggle("stroke active")
                 .setPosition(300, 20)
                 .setSize(70,30)
                 .setValue(1.0);
                 
    colorActive = cp5.addToggle("color active")
                 .setPosition(400, 20)
                 .setSize(70,30);
                 
    blendActive = cp5.addToggle("blend active")
                 .setPosition(500, 20)
                 .setSize(70,30);
 controller.movementType = 1;
                      
 cp5.setAutoDraw(false);
 generate();
}

void draw(){
  
  controller.Update();
  
  imgName = loadFromFile.getText();
  background(0);
  shape(terrain, 0,0);
  if(strokeSwap != strokeActive.getState()){
    strokeSwap = strokeActive.getState();
    handleShapeChanges();
  }
  else if(colorSwap != colorActive.getState()){
    colorSwap = colorActive.getState();
    handleShapeChanges();
  }
  else if(blendSwap != blendActive.getState()){
    blendSwap = blendActive.getState();
    handleShapeChanges();
  }
  camera();
  perspective();
  cp5.draw();
  
}

void mouseWheel(MouseEvent event){
  float e = event.getCount();
  controller.Zoom(e);
}

public void rows(int val){
  
}

public void columns(int val){
}

public void terrainSize(int val){

}

public void heightModifier(float val){
  handleVertChanges();
  handleShapeChanges();
}

public void snowThreshold(float val){
  handleVertChanges();
  handleShapeChanges();
}

public void generate(){
  //println(imgName);
   //println(vertData);
   
  handleVertChanges();
   triangleData.clear();
   boolean flip = true;
   int startOfRow = 0;
   int startIndex = 0;
   int numCol = (int)columns.getValue();
   int vert2 = -1;
   int vert3 = -1;
   //println(vertData.size());
   while(vert3 < vertData.size()-1){
     //println(startIndex);
     if(flip){
       vert2 = startIndex+1;
       vert3 = startIndex + numCol + 1;
       triangleData.add(startIndex);
       triangleData.add(vert2);
       triangleData.add(vert3);
       startIndex = vert3;
       flip = !flip;
     }
     if(!flip){
       vert2 = startIndex-numCol;
       vert3 = startIndex + 1;
       triangleData.add(startIndex);
       triangleData.add(vert2);
       triangleData.add(vert3);
       startIndex = startIndex-numCol;
       flip = !flip;
     }
     if(vert2 - startOfRow >= numCol && flip){
       startIndex+=1;
       startOfRow = startIndex;
     }
   }
   //println(triangleData);
   handleShapeChanges();
}

public void handleVertChanges(){
   vertData.clear();
  try{
   String img = "data/" + imgName + ".png";
    //println(img);
    PImage terrainImg = loadImage(img);
    //println(terrainImg.width);
    //println((int)columns.getValue());
    //println((int)rows.getValue());
   float i = -((int)rows.getValue())/2.0f;
   float j = -((int)columns.getValue())/2.0f;
   int l = 0;
   int k = 0;
    while( i <= (((int)rows.getValue())/2.0f) + .1){
     while( j <= (((int)columns.getValue())/2.0f) + .1){
       int x_index = (int)map(l, 0, columns.getValue()+1, terrainImg.width, 00);
       int y_index = (int)map(k,0,rows.getValue()+1, 0, terrainImg.height);
       color c = terrainImg.get(x_index, y_index);
       float heightFromColor = map(red(c), 0,255, 0,-1);
       vertData.add(new PVector(i*(terrainSize.getValue()/((int)rows.getValue())),heightFromColor,j*(terrainSize.getValue()/((int)columns.getValue()))));
        j++;
        l++;
     }  
     i++;
     k++;
     j = -((int)columns.getValue())/2.0f;
     l=0;
   }
  }
   catch(Exception e){
     float i = -((int)rows.getValue())/2.0f;
     float j = -((int)columns.getValue())/2.0f;
      while( i <= (((int)rows.getValue())/2.0f) + .1){
       while( j <= (((int)columns.getValue())/2.0f) + .1){
         vertData.add(new PVector(i*(terrainSize.getValue()/((int)rows.getValue())),0,j*(terrainSize.getValue()/((int)columns.getValue()))));
          j++;
       }  
       i++;
       j = -((int)columns.getValue())/2.0f;
     }
   }
   
 }

void handleShapeChanges(){
terrain = createShape();  
   terrain.beginShape(TRIANGLE);
   for(int i =0; i < triangleData.size(); i++){
     //println(i);
     float relativeHeight = vertData.get(triangleData.get(i)).y*heightModifier.getValue()/-snowThreshold.getValue();
     //relativeHeight = map(relativeHeight, 0,-5.0, 0, 1.0);
     //println(relativeHeight);
     if(strokeActive.getValue() == 1){
       terrain.stroke(0);  
     }
     else {
       terrain.noStroke();
     }
     if(colorActive.getValue() == 1){
        if(relativeHeight > 0.8){
          if(blendActive.getValue() == 1.0f){
            float ratio = (relativeHeight-0.8f)/0.2f;
            terrain.fill(lerpColor(rock,snow, ratio));
          }
          else {
            terrain.fill(snow);
          }
        }
        else if(relativeHeight > 0.4 && relativeHeight <= .8){
          if(blendActive.getValue() == 1.0f){
            float ratio = (relativeHeight-0.4f)/0.4f;
            terrain.fill(lerpColor(grass,rock, ratio));
          }
          else {
            terrain.fill(rock);
          }
        }
        else if(relativeHeight > 0.2 && relativeHeight <= .4){
          if(blendActive.getValue() == 1.0f){
            float ratio = (relativeHeight-0.2f)/0.2f;
            terrain.fill(lerpColor(dirt,grass, ratio));
          }
          else {
            terrain.fill(grass);
          }
        }
        else{
          if(blendActive.getValue() == 1.0f){
            float ratio = relativeHeight/0.2f;
            terrain.fill(lerpColor(water,dirt, ratio));
          }
          else {
            terrain.fill(water);
          }
        }
     }else {
       terrain.fill(255);
     }
     terrain.vertex(vertData.get(triangleData.get(i)).x*unit, vertData.get(triangleData.get(i)).y*unit*heightModifier.getValue(), vertData.get(triangleData.get(i)).z*unit);
   }
   terrain.endShape();
}

void controlEvent(ControlEvent theEvent) {
  if(theEvent.isFrom(cameraMovement)) {
    print("got an event from "+theEvent.getName()+"\t");
 }
}

void keyPressed(){
  if(keyCode == 10){
    generate();
  }
  println(keyCode);
}
