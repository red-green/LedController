import processing.serial.*;
import ddf.minim.analysis.*;
import ddf.minim.*;

Minim       minim;
AudioInput  input;
FFT         fft;
//BeatDetector beat;

// dict definitions for random & modes
HashMap<Integer, String> rand_names = new HashMap<Integer, String>();
HashMap<Integer, Integer[]> rand_choices = new HashMap<Integer, Integer[]>();
HashMap<Integer, String> mode_names = new HashMap<Integer, String>();

int windowscale = 180;
int textsize = 21;
float threashold = 3;
float sndscl = 500; // sound scale

int audioChannels = 8; // number of different bands for the eq

Serial port;  // Create object from Serial class

boolean compRandom = false; // computer-side random sequencing
int randMode = 0;
int randTimer = 0;
int compSpeed = 1000;
boolean soundSwitch = false;
int beatTimer = 0;

int ledMode = 0;

float mx=-1,my=-1;


void setup() {
  // hashmap setup
  rand_choices.put(-1,new Integer[]{14,15,16,17,19}); // avoid these in normal random
  rand_names.put(1,"computer-side random");   //rand_choices.put(0,new Integer[]{});
  rand_names.put(2,"all random wipes");       rand_choices.put(2,new Integer[]{4,5,10,11,12,13});
  rand_names.put(3,"full random wipes");      rand_choices.put(3,new Integer[]{4,5});
  rand_names.put(4,"sectional random wipes"); rand_choices.put(4,new Integer[]{10,11,12,13});
  rand_names.put(5,"rainbow");                rand_choices.put(5,new Integer[]{1,7});
  rand_names.put(6,"pixel drip");             rand_choices.put(6,new Integer[]{3,6,18});
  rand_names.put(7,"sound reactive");         rand_choices.put(7,new Integer[]{15,16,19});
  rand_names.put(8,"trippy (run full speed)");rand_choices.put(8,new Integer[]{2,9,10,11,12,13,17});
  //rand_names.put(9,"");                       rand_choices.put(9,new Integer[]{});
  
  mode_names.put(0,"arduino-side random");
  mode_names.put(7,"reverse rainbow");
  mode_names.put(1,"normal rainbow");
  mode_names.put(2,"random color blocks");
  mode_names.put(3,"pixel drip to white");
  mode_names.put(4,"color wipe");
  mode_names.put(5,"reverse color wipe");
  mode_names.put(6,"pixel drip to black");
  mode_names.put(8,"random color moving bars");
  mode_names.put(9,"strobe");
  mode_names.put(10,"random wipe inward");
  mode_names.put(11,"random wipe outward");
  mode_names.put(12,"double random wipe");
  mode_names.put(13,"inverse double random wipe");
  mode_names.put(14,"fade to black");
  mode_names.put(15,"beat pulse");  // neither of these work well
  mode_names.put(16,"beat pulse 2");
  mode_names.put(17,"double strobe");
  mode_names.put(18,"random pixels");
  mode_names.put(19,"sound level");
  mode_names.put(20,"multicolor strobe");
  //mode_names.put(17,"");
  
  // audio processing stuff
  /*minim = new Minim(this);
  input = minim.getLineIn();
  fft = new FFT(input.bufferSize(),input.sampleRate());*/
  //beat = new BeatDetector();
  
  // size & serial
  size(displayWidth,displayHeight);
  String[] ports = Serial.list();
  String portName = ports[ports.length-1];
  port = new Serial(this, portName, 115200);
  
  frameRate(15);
}

char brightness=0, rate=0;
int sscl = 0;
float totalsnd = 0;

void draw() {
  /*
  fft.forward(input.mix);
  
  totalsnd = 0;
  for (int i = 0; i < fft.specSize(); i++) { 
    totalsnd += fft.getBand(i);
  }
  int out = (int)constrain(map(totalsnd,0,sndscl,0,255),0,255);
  
  if (ledMode == 15 || ledMode == 16 || ledMode == 19) {
    port.write("E" + (char)out);
  }
  
  
  beat.run(fft);

  if (ledMode == 15) {
    boolean on = beat.beat();
    if (on) port.write('z');
    beatTimer = 40; // 2/3 second
  }
  if (beatTimer > 0) {
    beatTimer--;
    fill(255);stroke(128);
    ellipse(width-200,height-200,beatTimer,beatTimer);
  }
  
  if (ledMode == 16) { //whyyyyyyyyy does it not work
    float bands[] = new float[audioChannels];
    int scl = fft.specSize()/2/audioChannels;   //top half doesn't really matter
    for (int i = 0; i < fft.specSize()/2; i++) {
      bands[constrain(i/scl,0,audioChannels-1)] += fft.getBand(i);
    }
    float maxl = 20;
    for (int i = 0; i < audioChannels; i++) {
      //if (bands[i] > maxl) maxl = bands[i];
    }
    int bands2[] = new int[audioChannels];
    for (int i = 0; i < audioChannels; i++) {
      bands2[i] = (int)map(bands[i],0,maxl,0,255);
    }
    byte out = 0;
    for (int i = 0; i < audioChannels; i++) {
      out = (byte)(out << 1);
      if (bands2[i] > threashold) {
        out &= 1;
      }
    }
    port.write("E" + (char)out);
  }
  */
  
  if (compRandom && randTimer + compSpeed < millis()) {
    soundSwitch = false;
    randTimer = millis();
    int next = 0;
    if (randMode == 0) {
      next = 0;
      compRandom = false;
    } else if (randMode == 1) {
      boolean r = false;
      do {
        r = false;
        next = (int)random(1,mode_names.size());
        for (int i = 0; i < rand_choices.get(-1).length; i++) {
          if (rand_choices.get(-1)[i] == next)
            r = true;
        }
      } while (r);
    } else if (rand_choices.containsKey(randMode)) {
      Integer[] choices = rand_choices.get(randMode);
      int choice = choices[(int)random(choices.length)];
      next = choice;
    } else {
      compRandom = false;
    }
    if (next == 9 && random(1) > 0.3) next = 6; // avoid strobe
    ledMode = next;
    port.write("M" + ((char)(next + 'a' - 1)));
  }
  
  brightness = (char)min(max(map(mouseX,windowscale,width-windowscale,0,255),0),255);
  rate       = (char)map(mouseY,0,height,0,80);
  sscl       = (int)(width-mouseX);
  
  background(0);
  stroke(0,255,0);
  textSize(textsize-1);
  line(windowscale,0,windowscale,height);
  line(width-windowscale,0,width-windowscale,height);
  
  fill(255);
  text("Calculated speed:      " + (int)map((int)rate,0,80,100,0) + "%",10,textsize);
  text("Calculated brightness: " + (int)brightness,10,textsize*2);
  text("Calculated soundScale: " + sscl,10,textsize*3);
  
  //somehow, use sets do display all possibilities of modes, current modes, random stuff
  for (int i = 0; i < mode_names.size(); i++) {
    char c = (char)(i + (int)'a' -1);
    if (i == ledMode) {
      fill(255,0,0);
    } else {
      fill(128);
    }
    text(c + ": " + mode_names.get(i),10+windowscale,85+textsize*i);
  }
  
  for (int i = 1; i <= rand_names.size(); i++) {
    if (i == randMode) {
      fill(0,255,0);
    } else {
      fill(128);
    }
    text(i + ": " + rand_names.get(i),width/2,85+textsize*i);
  }
  
  
  fill(255);
  text("Left click to set rate",10,height-textsize);
  text("Right click to set brightness",10,height-textsize*2);
  text("Enter to set it back to random mode",10,height-textsize*3);
  text("Space to pause",10,height-textsize*4);
  text("Comma to set soundscale with mouseX",10,height-textsize*5);
  text("Lowercase letters to set mode",10,height-textsize*6);
  text(totalsnd,700,700);
  
  stroke(255,0,255);
  line(0,my,width,my);
  line(mx,0,mx,height);
  
  //display fft
  /*stroke(200,200,255);
  for(int i = 0; i < fft.specSize(); i++) {
    line(i + width-fft.specSize(), height, i + width-fft.specSize(), height - fft.getBand(i)*12);
  }*/
}

void mousePressed() {
  if (mouseButton == LEFT) {
    port.write("S" + (char)rate);
    //compSpeed = (int)rate * 20;
    my = mouseY;
  }
  if (mouseButton == RIGHT) {
    port.write("B" + (char)brightness);
    mx = mouseX;
  }
}

void keyPressed() {
  if (key >= '`' && key <= 'z') {
    port.write("M" + (char)key);
    ledMode = (int)key - (int)'a' + 1;
    randMode = 0;
    compRandom = false;
  }
  if (key == ' ') port.write("O");
  if (key == ENTER || key == RETURN){
    port.write("M`");
    randMode = 0;
    compRandom = false;
    ledMode = 0;
  }
  if (key >= '1' && key <= '9') {
    compRandom = true;
    randMode = (int)(key-'1') + 1 ;
  }
  if (key == ',') {
    sndscl = sscl;
  }
}

boolean sketchFullScreen() { return true; }
