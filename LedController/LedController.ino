#include <Adafruit_NeoPixel.h>

//led stuff
#define PIN            6
#define NUMPIXELS      150 

#define EQSECTIONS     8

#define FADE           3
// two pixel strips connected in parallel
Adafruit_NeoPixel pixels = Adafruit_NeoPixel(NUMPIXELS, PIN, NEO_GRB + NEO_KHZ800);


void setup() {
  pixels.begin();
  Serial.begin(115200);

  randomSeed(analogRead(0));
}

byte wheel;
int wheel2;
byte add;
uint32_t color;
bool beat;

byte greq;

int rate = 7;

byte brightness = 255;

byte mode = 0;
bool enabled = true;
bool randm = false;
unsigned long rtimer;

byte greq2;

long cycles = 0;

void loop() {
  if (Serial.available()) { // handle serial from processing sketch
    char c = Serial.read();
    switch (c) {
      case 'M':
        c = Serial.read();
        if (c > 95 && c < 123) mode = c - 96;
        if (mode > 0) randm = false;
        color = Wheel(random(0xff));
        break;
      case 'O':
        enabled = !enabled;
        break;
      case 'S':
        rate = Serial.read();
        break;
      case 'B':
        brightness = Serial.read();
        pixels.setBrightness(brightness);
        break;
      case 'Z':
        beat = true;
        break;
      case 'E':
        greq = Serial.read();
        break;
    }
  }

  if (enabled) {
  // random sequence timer
  cycles++;
  if (randm && rtimer  < cycles) {
    rtimer = cycles + 200; 
    mode = random(1,14);
    color = Wheel(random(0xff));
  } 
  if (mode == 0) {
    randm = true;
  }

  //periodic update functions
  uint32_t sc;
  switch (mode) {
    case 7:
      //reverse rainbow
      wheel -=2;
    case 1:
      //rainbow
      wheel++;
      for(byte i=0; i< pixels.numPixels(); i++) {
        pixels.setPixelColor(i, Wheel(((i * 512 / NUMPIXELS) + wheel) & 255));
      }
      break;
    case 2:
      //random color blocks
      add++;
      if (add > 5) {
        add = 0;
        for (int t = 0; t < NUMPIXELS; t+=5) {
          sc = Wheel(random(0,255));
          for (int u = t; u<t+5; u++) {
            pixels.setPixelColor(u, sc);
          }
        }
      }
      //delay(rate*2);
      break;
    case 3:
      //pixel drip fade to white
      for (byte i = 0; i < NUMPIXELS; i++) {
        uint32_t pcolor = pixels.getPixelColor(i);
        uint8_t red,green,blue;
        blue = pcolor;
        green = pcolor>>8;
        red = pcolor>>16;
        if (red<255-FADE) {
          red+=FADE;
        } else {
          red = 255;
        }
        if (green<255-FADE) {
          green+=FADE;
        } else {
          green = 255;
        }
        if (blue<255-FADE) {
          blue+=FADE;
        } else {
          blue = 255;
        }
        pixels.setPixelColor(i,red,green,blue);
      }
      add++;
      if (add > 2) {
        add = 0;
        pixels.setPixelColor(random(NUMPIXELS),Wheel(random(0xff)));
      }
      break;
    case 4:
      //random wipe
      wheel2++;
      if (wheel2 > NUMPIXELS) {
        wheel2 = 0;
        color = Wheel(random(0xff));
      }
      pixels.setPixelColor(wheel2,color);
      break;
    case 5:
      //reverse random wipe
      wheel2--;
      if (wheel2 < 0) {
        wheel2 = NUMPIXELS;
        color = Wheel(random(0xff));
      }
      pixels.setPixelColor(wheel2,color);
      break;
    case 6:
      //pixel drip fade to black
      for (byte i = 0; i < NUMPIXELS; i++) {
        uint32_t pcolor = pixels.getPixelColor(i);
        uint8_t red,green,blue;
        blue = pcolor;
        green = pcolor>>8;
        red = pcolor>>16;
        if (red>FADE) {
          red-=FADE;
        } else {
          red = 0;
        }
        if (green>FADE) {
          green-=FADE;
        } else {
          green = 0;
        }
        if (blue>FADE) {
          blue-=FADE;
        } else {
          blue = 0;
        }
        pixels.setPixelColor(i,red,green,blue);
      }
    case 18:
      add++;
      if (add > 2) {
        add = 0;
        pixels.setPixelColor(random(NUMPIXELS),Wheel(random(0xff)));
      }
      break;
    case 8:
      //random colors...??
      wheel2++;
      if (wheel2>10) wheel2 = 0;
      sc = Wheel(random(0,255));
      for (int t = 0; t < NUMPIXELS; t+=10) {
        pixels.setPixelColor(t + wheel2, sc);
      }
      delay(rate*2);
      break;
    case 9:
      //strobe
      wheel2++;
      if (wheel2>19) {
        if (color) {
          color = 0;
          wheel2 = 0;
        } else {
          color = 0xffffff;
        }
      }
      for (int t = 0; t < NUMPIXELS; t++) {
        pixels.setPixelColor(t,color);
      }
      break;
    case 20:
    // multicolor strobe
      wheel2++;
      if (wheel2>19) {
        if (color) {
          color = 0;
          wheel2 = 0;
        } else {
          color = Wheel(random(0xff));
        }
      }
      
      for (int t = 0; t < NUMPIXELS; t++) {
        pixels.setPixelColor(t,color);
      }
      break;
    case 10:
      //random wipe inward
      wheel2++;
      if (wheel2 > NUMPIXELS/2) {
        wheel2 = 0;
        color = Wheel(random(0xff));
      }
      pixels.setPixelColor(wheel2,color);
      pixels.setPixelColor(NUMPIXELS-wheel2,color);
      break;
    case 11:
      //random wipe outward
      wheel2--;
      if (wheel2 < 0) {
        wheel2 = NUMPIXELS/2;
        color = Wheel(random(0xff));
      }
      pixels.setPixelColor(wheel2,color);
      pixels.setPixelColor(NUMPIXELS-wheel2,color);
      break;
    case 12:
      //double random wipe
      wheel2++;
      if (wheel2 > NUMPIXELS/2) {
        wheel2 = 0;
        color = Wheel(random(0xff));
      }
      pixels.setPixelColor(wheel2,color);
      pixels.setPixelColor(NUMPIXELS/2+wheel2,color);
      break;
    case 13:
      //inverse double random wipe
      wheel2--;
      if (wheel2 < 0) {
        wheel2 = NUMPIXELS/2;
        color = Wheel(random(0xff));
      }
      pixels.setPixelColor(wheel2,color);
      pixels.setPixelColor(NUMPIXELS/2+wheel2,color);
      break;
    case 15:
      // beat controlled lighting (fades to black...)
      if (add > 0) {
        add--;
      } else if (greq > 128) {
        color = Wheel(random(0xff));
        for (int t = 0; t < NUMPIXELS; t++) {
          pixels.setPixelColor(t,color);
        }
        add = greq/8;
      }
    case 14:
      // fade to black
      for (byte i = 0; i < NUMPIXELS; i++) {
        uint32_t pcolor = pixels.getPixelColor(i);
        uint8_t red,green,blue;
        blue = pcolor;
        green = pcolor>>8;
        red = pcolor>>16;
        if (red>FADE) {
          red-=FADE;
        } else {
          red = 0;
        }
        if (green>FADE) {
          green-=FADE;
        } else {
          green = 0;
        }
        if (blue>FADE) {
          blue-=FADE;
        } else {
          blue = 0;
        }
        pixels.setPixelColor(i,red,green,blue);
      }
      break;
    case 16:
      // beat pulse
      greq2 = 255-greq;
      //add++; if (add < 3) {add = 0;wheel++;}
      color = 0xffffff;  //Wheel(greq2+wheel);
      uint8_t red,green,blue;
      blue = color;
      green = color>>8;
      red = color>>16;
      if (red>=greq2) {
        red-=greq2;
      } else {
        red = 0;
      }
      if (green>=greq2) {
        green-=greq2;
      } else {
        green = 0;
      }
      if (blue>=greq2) {
        blue-=greq2;
      } else {
        blue = 0;
      }
      for (int t = 0; t < NUMPIXELS; t++) {
        pixels.setPixelColor(t,red,green,blue);
      }
      break;
    case 17:
      //double strobe
      wheel2++;
      if (wheel2<7) {
        color = 0;
      } else {
        color = 0xffffff;
      }
      if (wheel2>10) wheel2 = 0;
      for (int t = 0; t < NUMPIXELS/2; t++) {
        pixels.setPixelColor(t,color);
      }
      wheel++;
      if (wheel<10) {
        color = 0;
      } else {
        color = 0xffffff;
      }
      if (wheel>13) wheel = 0;
      for (int t = NUMPIXELS/2; t < NUMPIXELS; t++) {
        pixels.setPixelColor(t,color);
      }
      break;
    case 19:
      //sound level indicator
      wheel++;
      wheel2 = map(greq,0,255,0,60);
      color = Wheel(wheel);
      for (int t = 0; t < wheel2; t++) {
        pixels.setPixelColor(t,color);
      }
      for (int t = wheel2; t < NUMPIXELS; t++) {
        pixels.setPixelColor(t,0);
      }
  }
  
  pixels.show();
  }
  delay(rate);
}




uint32_t Wheel(byte WheelPos) {
  WheelPos = 255 - WheelPos;
  if(WheelPos < 85) {
   return pixels.Color(255 - WheelPos * 3, 0, WheelPos * 3);
  } else if(WheelPos < 170) {
    WheelPos -= 85;
   return pixels.Color(0, WheelPos * 3, 255 - WheelPos * 3);
  } else {
   WheelPos -= 170;
   return pixels.Color(WheelPos * 3, 255 - WheelPos * 3, 0);
  }
}
