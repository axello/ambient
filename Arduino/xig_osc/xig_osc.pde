/*
 * *********XBee OSC with ConnectPort gateway example ********
 * version 0.2
 * Axel Roest http://phlux.us
 * 
 */
  
#include <NewSoftSerial.h>

#define NAME "XIG OSC Example"
#define VERSION "1.10"
#define LED_PIN 13
#define URL "http://192.168.8.105/~axel/xbee/getvalue.php"
#define URLDELAY 2000
#define XBEE_RXPIN 2
#define XBEE_TXPIN 3
#define XBEE_SLEEPPIN 7
// pulling the sleepbutton low, triggers the sleeppin to the xbee, making it seek for networks
#define SLEEPBUTTON 8
#define XAXIS  A0
#define YAXIS  A1
#define ZAXIS  A2


// the UDPBUTTON sends a signal on the UDP channel
#define UDPBUTTON 9
#define UDPURL "udp://192.168.8.105:5000/lientjeleerde/lotjelopen"
// number of milliseconds to wait between UDP requests
#define UDPDELAY  500

// OSC stuff
#define OSCDELAY  50
#define OSCURL  "osc:///xbee/x"
#define OSCSPECIAL "osc://192.168.8.105:6000

int outputLight = 12;
int lightState=1;      // we start with slow blinking
int blinkRate = 3000;
long nextURLCheck = 0;    // timer for URL checks
long nextLedBlink = 0;    // timer for main LED blinks
long nextLed2Blink = 0;    // timer for extra debug LED blinks
long udpwait = 0;        // timer to mask udp messages
long  nextOSCmessage = 0;

//NewSoftSerial mySerial(XBEE_TXPIN, XBEE_RXPIN);

void setup()
{
  pinMode(LED_PIN,OUTPUT);
  pinMode(outputLight,OUTPUT);
  pinMode(XBEE_SLEEPPIN,OUTPUT);
  digitalWrite(XBEE_SLEEPPIN, LOW);  // turn on xbee

  pinMode(SLEEPBUTTON,INPUT);
  digitalWrite(SLEEPBUTTON, HIGH);  // pull up high, pushdown low
  pinMode(UDPBUTTON,INPUT);
  digitalWrite(UDPBUTTON, HIGH);  // pull up high, pushdown low
  
  Serial.begin(115200); // faster is better for XIG
//  mySerial.begin(115200); // faster is better for XIG
  delay(3000);
  nextURLCheck = millis() + URLDELAY;
  nextOSCmessage = millis() + OSCDELAY;
}

void loop()
{
  if (millis() > nextOSCmessage) {  // send some analog values over OSC
    sendAccelleration(OSCURL);
    nextOSCmessage = millis() + OSCDELAY;
  }
 
  if (Serial.available() > 0) { // if there's a byte waiting
    lightState = Serial.read(); // read the ASCII numeral byte
    // turn on the light if the response is 1, or off if the response is zero
    if (lightState >= '0' && lightState<='9') {
      lightState=lightState-48; // transform ASCII into an integer
     // Serial.println(lightState);
      if (lightState > 0) {     // set blink rate
        blinkRate = 1000 / (lightState * 2);  // from once every second, to 8x a second
      } else {
        blinkRate = 0;
      }
    }
  }
  if (digitalRead(SLEEPBUTTON) == LOW) {
    digitalWrite(XBEE_SLEEPPIN, HIGH);  // turn xbee to sleep
  } else {
    digitalWrite(XBEE_SLEEPPIN, LOW);
  }    // testing purposes

  if (digitalRead(UDPBUTTON) == LOW && millis() > udpwait) {
    Serial.println(UDPURL);
    udpwait = millis() + UDPDELAY;
  }  // testing purposes

  // blink the thing, or not
  blinkLED(LED_PIN, &nextLedBlink, blinkRate);
  blinkLED(outputLight, &nextLed2Blink, 80);
}

////////////////// UTILITIES //////////////////

// this function blinks the an LED light as many times as requested, at the requested blinking rate
void blinkLED(byte targetPin, long *toggleTime, int blinkRate)
{
  if (blinkRate == 0) {
    digitalWrite(targetPin, LOW);                        // sets the LED off
  } else if (millis() > *toggleTime) {
    digitalWrite(targetPin, !digitalRead(targetPin));    // toggle the LED
    *toggleTime = millis() + blinkRate;                  // waits for blinkRate milliseconds
  }
}

// this function reads two analog values and sends them with the baseurl to the serial port (=xbee)
void sendAccelleration (String baseurl)
{
  int x,y;
  String url;
  x = map(analogRead(XAXIS),140,540,0,1023);
  url = baseurl + "?0&" + String(x);
  Serial.println(url);
  
  y = map(analogRead(YAXIS),140,540,0,1023);
  url = baseurl + "?1&" + String(y);
  Serial.println(url);
}
