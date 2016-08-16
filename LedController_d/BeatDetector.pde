/*int beatChannels = 10;
int avgItems = 15;

class BeatDetector {
  float averages[];
  int avgIndex;
  boolean happened;
  
  BeatDetector() {
    averages = new float[avgItems];
    avgIndex = 0;
    happened = false;
  }
  
  void run(FFT fft) {
    float bands[] = new float[beatChannels];
    int scl = fft.specSize()/2/beatChannels;   //top half doesn't really matter
    for (int i = 0; i < fft.specSize()/2; i++) {
      bands[constrain(i/scl,0,beatChannels-1)] += fft.getBand(i);
    }
    float maxl = 10;
    int bands2[] = new int[beatChannels];
    for (int i = 0; i < beatChannels; i++) {
      bands2[i] = (int)map(bands[i],0,maxl,0,255);
    }
    float total = 0;
    for (int i = 0; i < beatChannels; i++) {
      total += bands2[i];
    }
    total /= (float)beatChannels;
    avgIndex++;
    if (avgIndex < avgItems) avgIndex = 0;
    averages[avgIndex] = total;
  }
  
  boolean beat() {
    float current = averages[avgIndex];
    float taverage = 0;
    for (int i = 0; i < beatChannels; i++) {
      taverage += averages[i];
    }
    if (current > taverage && !happened) {
      happened = true;
      return true;
    } else if  (current <= taverage && happened) {
      happened = false;
    }
    fill(255);
    text(taverage,500,500);
    return false;
  }
}*/
