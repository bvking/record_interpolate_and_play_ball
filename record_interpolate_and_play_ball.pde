import processing.serial.*;
Serial encoderReceiveUSBport101; // serial port receiving datas of positions of 6 motors
Serial teensyport; // serial port sending positions to 6 motors

int actualSec,lastSec,measure,measureToStartRecording;;
boolean bRecording = false;
boolean mouseRecorded =  true;

class Sample {
  int t, x, y;
  Sample( int t, int x, int y ) {
    this.t = t;  this.x = x;  this.y = y;
  }
}

class Sampler {
  
  ArrayList<Sample> samples;
  ArrayList<Sample> samplesModified;
  int startTime;
  int playbackFrame;
  
  Sampler() {
    samples = new ArrayList<Sample>();
        samplesModified = new ArrayList<Sample>();
    startTime = 0;
  }
  void beginRecording() {   
    samples = new ArrayList<Sample>();
    samplesModified = new ArrayList<Sample>();
    playbackFrame = 0;
  }
  void addSample( int x, int y ) {  // add sample when bRecording
    int now = millis();
    if( samples.size() == 0 ) startTime = now;
    samples.add( new Sample( now - startTime, x, y ) );
  }
  int fullTime() {
    return ( samples.size() > 1 ) ? 
    samples.get( samples.size()-1 ).t : 0;
  }
  void beginPlaying() {
    startTime = millis();
    playbackFrame = 0;
    println( samples.size(), "samples over", fullTime(), "milliseconds" );
    if(samples.size() > 0){
      int deltax = samples.get(0).x - samples.get(samples.size()-1).x;
      int deltay = samples.get(0).y - samples.get(samples.size()-1).y;
      float sumdist = 0;
      
      for(int i = 0; i < samples.size() - 1; i++) {
        sumdist += sqrt((samples.get(i).x - samples.get(i +1 ).x)*(samples.get(i).x - samples.get(i +1 ).x) + (samples.get(i).y - samples.get(i +1 ).y)*(samples.get(i).y - samples.get(i +1 ).y));
      }
      
      samplesModified.add( new Sample(samples.get(0).t, samples.get(0).x , samples.get(0).y ) );
      float dist = 0;
      for(int i = 0; i < samples.size() - 1; i++) {
        dist += sqrt((samples.get(i).x - samples.get(i +1 ).x)*(samples.get(i).x - samples.get(i +1 ).x) + (samples.get(i).y - samples.get(i +1 ).y)*(samples.get(i).y - samples.get(i +1 ).y));
        samplesModified.add( new Sample(samples.get(i+1).t, (int) (samples.get(i +1).x + (dist * deltax) / sumdist), (int) (samples.get(i+1).y +( dist * deltay )/ sumdist)) );
        print(samples.get(i).x);
        print(",");
        print(samples.get(i).y);
        print(",");
        print(samplesModified.get(i).x);
        print(",");
        print(samplesModified.get(i).y);
        println("");      
      }
    }
  }
 }
   
   
Sampler sampler;

void setup() {  
  size( 800, 800, P3D );
  frameRate(30); // when size is set as P3D (3 dimension) we have 27 or 28 frame (loop) per seconde
  sampler = new Sampler();
  
  //********Sending and Receiving data with two different serialport
  String[] ports = Serial.list();
  printArray(Serial.list()); // display port in terminal
  //*************** TEENSY connected
   teensyport = new Serial(this, ports[0], 115200);// choose port matching to send data
  //*************** ENCODERD connected // comment below if port not connected
  //  encoderReceiveUSBport101 = new Serial(this, Serial.list()[1], 1000000);choose port matching to receive data
  //  Read bytes into a buffer until you get a linefeed (ASCII 10):
  //  encoderReceiveUSBport101.bufferUntil('\n');
}

void draw() {
  background( 0 );
  activeSampling();
  stopSampling();
  
  if  (actualSec!=lastSec){
       lastSec=actualSec;
       measure++;
       textSize (100);
       text (measure, 100, 100 );
     }
       actualSec =(int) (millis()*0.001);  // 
 
  if( bRecording) { // draw circle
    circle( mouseX, mouseY, 10 );
    sampler.addSample( mouseX, mouseY );
  }
  
  else {    
  if( sampler.fullTime() > 0 )
        sampler.draw();
  }
}

void mousePressed() {
  bRecording = true;   // draw circle
  mouseRecorded = true;
  measure=0;
}
  
void activeSampling() { 
   if (measure<=1 && measure>=1 &&actualSec!=lastSec && mouseRecorded == true) {
  sampler.beginRecording();
  }
}

void stopSampling() { 
   if (measure<=3 && measure>=3  && actualSec!=lastSec) {  
  mouseRecorded = false;
     //**REPEAT
  bRecording = false;
  sampler.beginPlaying();
  }
}

void serialEvent(Serial encoderReceiveUSBport101) { // receive 6 datas from serialport splited with , and a last is send with println

  // read the serial buffer:
  String myString = encoderReceiveUSBport101.readStringUntil('\n');

  // if you got any bytes other than the linefeed:
  myString = trim(myString);

  // split the string at the commas
  // and convert the sections into integers:
  int values[] = int(split(myString, ','));

  if (values.length > 0) {// v0 is value of the encodeur from 0 to 4000
  int v0; int v1; int v2; int v3; int v4; int v5;

    v0 = (int) map (values[0], 0, 4000, 0, 400);
    v1 = (int) map (values[0], 0, 4000, 0, 400);
    v2 = (int) map (values[0], 0, 4000, 0, 400);
    v3 = (int) map (values[0], 0, 4000, 0, 400);
    v4 = (int) map (values[0], 0, 4000, 0, 400);
    v5 = (int) map (values[0], 0, 4000, 0, 400);
           
    println (" v0 " + v0 ); println (" v1 " + v1 ); println (" v2 " + v2 ); println (" v3 " + v3 );
    println (" v4 " + v4 ); println (" v5 " + v5 );
}
}
