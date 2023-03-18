/* autogenerated by Processing revision 1292 on 2023-03-16 */
import processing.core.*;
import processing.data.*;
import processing.event.*;
import processing.opengl.*;

import java.util.HashMap;
import java.util.ArrayList;
import java.io.File;
import java.io.BufferedReader;
import java.io.PrintWriter;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.IOException;

public class record_and_play_ball extends PApplet {

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
  int startTime;
  int playbackFrame;
  
  Sampler() {
    samples = new ArrayList<Sample>();
    startTime = 0;
  }
  public void beginRecording() {   
    samples = new ArrayList<Sample>();
    print (samples);
    playbackFrame = 0;
  }
  public void addSample( int x, int y ) {  // add sample when bRecording
    int now = millis();
    if( samples.size() == 0 ) startTime = now;
    samples.add( new Sample( now - startTime, x, y ) );
  }
  public int fullTime() {
    return ( samples.size() > 1 ) ? 
    samples.get( samples.size()-1 ).t : 0;
  }
  public void beginPlaying() {
    startTime = millis();
    playbackFrame = 0;
    println( samples.size(), "samples over", fullTime(), "milliseconds" );
  }
  
  
  public void draw() {
    stroke( 255 );
    
    //**RECORD
    beginShape(LINES);
    for( int i=1; i<samples.size(); i++) {
      vertex( samples.get(i-1).x, samples.get(i-1).y ); // replace vertex with Pvector
      vertex( samples.get(i).x, samples.get(i).y );
    }
    endShape();
    //**ENDRECORD
    
    //**REPEAT
    int now = (millis() - startTime) % fullTime();
    if( now < samples.get( playbackFrame ).t ) playbackFrame = 0;
    while( samples.get( playbackFrame+1).t < now )
      playbackFrame = (playbackFrame+1) % (samples.size()-1);
    Sample s0 = samples.get( playbackFrame );
    Sample s1 = samples.get( playbackFrame+1 );
    float t0 = s0.t;
    float t1 = s1.t;
    float dt = (now - t0) / (t1 - t0);
    float x = lerp( s0.x, s1.x, dt );
    float y = lerp( s0.y, s1.y, dt );
    circle( x, y, 10 );
    println (frameCount + " x " + x);
  }
  
}

Sampler sampler;

public void setup() {  
  /* size commented out by preprocessor */;
  frameRate( 30 );  
  sampler = new Sampler();
}

public void draw() {
 // text ( "bla" , 200, 200);
  background( 0 );
  activeSampling();
  stopSampling();
  
  if  (actualSec!=lastSec){
       lastSec=actualSec;
       measure++;
       textSize (100);
       text (measure, 100, 100 );
     }
       actualSec =(int) (millis()*0.001f);  // 
 
  if( bRecording) { // draw circle
  //  circle( mouseX, mouseY, 10 );
    sampler.addSample( mouseX, mouseY );
    
  }
  
  else {    
  if( sampler.fullTime() > 0 )
        sampler.draw();
        println (frameCount + " x " + x);
  }

 println (frameCount + " x "  + samples.get(i).x + samples.get(i).y );
  
}

public void mousePressed() {
  bRecording = true;   // draw circle
  mouseRecorded = true;
  measure=0;
}
  
public void activeSampling() { 
   if (measure<=1 && measure>=1 &&actualSec!=lastSec && mouseRecorded == true) {
  sampler.beginRecording();
  }
}

public void stopSampling() { 
   if (measure<=3 && measure>=3  && actualSec!=lastSec) {  
  mouseRecorded = false;
     //**REPEAT
  bRecording = false;
  sampler.beginPlaying();
  }
}


  public void settings() { size(800, 800, P3D); }

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--full-screen", "--bgcolor=#666666", "--stop-color=#cccccc", "record_and_play_ball" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
