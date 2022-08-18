///Written by Brendan Hinman github.com/bhinmantx
///No warranty implied!
///Use, reuse, modify. A lot of this code is from me "standing on the shoulders of giants" and I've credited them as best as possible


//Location options

//Centering Austin Berg
float    lamin; //= 30.128210965263797; //These example values are for Austin
float    lomin; //= -97.74423598998125;

float    lamax; //= 30.256970429727343;
float    lomax;// = -97.59555607637411;

float latcenter;
float loncenter;

JSONObject flight_data;
JSONArray states;

JSONObject flight_dataLive;
JSONArray statesLive;


JSONArray edge_flight_data_arrive, edge_flight_data_depart;

String time; //TODO Unix timestamps -> formatting like in Golang

JSONObject landmark_json;
JSONArray landmark_data;

Landmark[] landmarks; 

boolean useLive =false;
boolean useMap =true;
boolean useLiveMap = false; //Using the live map requires an API key and there is a cost or a limit to the number of requests you can make
boolean useSkyNetwork = true; //Using Sky Network requires an API key and there is a cost. But it has far more information and a larger database of flights
String openSkyAPIUrl = ""; //https://USERNAME:PASSWORD@opensky-network.org/api/states/all?lamin=LAMIN&lomin=-LOMIN&lamax=LAMAX&lomax=LOMAX

PFont Alertfont;
String AlertText;
int AlertX = 30;
int AlertY = height - 100; //A quick way to position your METARS and NOTAMs

int numPrinted = 0;
boolean alreadyPrinted = false;

String AVIATION_EDGE_KEY = ""; //TODO fail gracefully
SkyNetworkSkyData networksky;
EdgeSkyData edgesky;

void DrawScale() { ///If you're trying to figure out the coordinates of your map vs your displayed planes this is useful
  fill(0, 0, 0, 0);
  for (int x = 0; x < 1023; x+=250) {
    for (int y = 0; y < 1023; y+=150) {
      String label = "x: " + x + " y: " + y;
      text(label, x, y);
    }
  }
}



int numFrames = 6;  // The number of icons
int currentFrame = 0;
PImage[] icons = new PImage[numFrames];
PImage mapimg;
int moveX, moveY;
void setup() {
  // background(209, 244, 255);
  background(0, 0, 0);
  if (args != null && args.length > 0) { //if you pass any argument 
    useMap = true;
  }

  //Austin Berg as an example 
  latcenter = 30.1945272;
  loncenter = -97.6698761;
  lamin = latcenter - .3;
  lamax = latcenter + .3;
  lomin = loncenter - .3;
  lomax =  loncenter + .3;

  String mapbox_token = "MAPBOXTOKEN";
  int s = second();  // Values from 0 - 59
  int m = minute();  // Values from 0 - 59
  int h = hour();    // Values from 0 - 23
  time = str(s+m+h);
  float zoom = 11.3;
  if (useMap) {
    while (mapimg == null) {
      if (useLiveMap) {
        mapimg=loadImage("HTTPS://api.mapbox.com:443/styles/v1/mapbox/light-v10/static/" + loncenter +","+ latcenter +","+ zoom + ",0.00,0.00/" + 1024 + "x" + 768 + "?access_token=" + mapbox_token, "png");
        mapimg.save("data/map.png"); //If we're paying for a map we might as well save a copy for offline troubleshooting
      } else {
        mapimg=loadImage("data/map.png", "png"); //previously saved map
      }
      delay(500); //A quick pause for loading/rendering
    }
  }

  fullScreen(); //Since this was ported to be used on a raspberry pi 
  //Yes we're cheating here since the draw mode wasn't working correctly on the Pi
  icons[0] = loadImage("data/planeN.png"); 
  icons[1] = loadImage("data/planeNB.png"); 
  icons[2] = loadImage("data/planeS.png"); 
  icons[3] = loadImage("data/planeW.png"); 
  icons[4] = loadImage("data/airport.png");
  icons[5] = loadImage("data/dot.png");

  icons[0].resize(height/50, height/50); //Match them to the screen size
  icons[1].resize(height/50, height/50);

  if (useMap) {
    imageMode(CENTER);
    image(mapimg, height/2, width/2);
  }

  if (useSkyNetwork) {
    if (useLive) { 
      networksky  = new SkyNetworkSkyData(true, "");
    } else {
      networksky  = new SkyNetworkSkyData(false, "data/flightdata115.json"); //Again, we can load previous values BUT they will obviously not "refresh" more than the path prediction
    }
    networksky.Draw();
  }

  edgesky = new EdgeSkyData(useLive, "data/edge115.json"); //Only offline data for now. API cost too much!
  edgesky.Draw();
  GetReports(useLive); //METARs and NOTAMs
  frameRate(1); //slow it WAY down
}


void draw() { 

  background(0, 0, 0);

  if (useMap) {
    imageMode(CENTER);
    image(mapimg, width/2, height/2);
  }
  if (useLive) {
    edge_flight_data_arrive = loadJSONArray("https://aviation-edge.com/v2/public/flights?key=" + AVIATION_EDGE_KEY + "&arrIata=AUS"); //need to switch this to something besides AUS
    edge_flight_data_depart = loadJSONArray("https://aviation-edge.com/v2/public/flights?key=" + AVIATION_EDGE_KEY + "&depIata=AUS");
  }

  if (useSkyNetwork) { //will do live or offline
    networksky.Draw();
  }
  edgesky.Draw();
  GetReports(false);
  //DrawScale(); //for troubleshooting
 

  landmark_json = loadJSONObject("data/landmarkdata.json"); //we don't need to load this every time. Unless we're updating the landmarks?
  landmark_data =  landmark_json.getJSONArray("landmarks");
  int numLandmarks = landmark_data.size();
  landmarks = new Landmark[numLandmarks];
  for (int j = 0; j < numLandmarks; j++) {
    landmarks[j] = new Landmark(landmark_data.getJSONArray(j), icons);
    landmarks[j].DrawLandmark();
  }

  ShowReports(20, height - 50);
 
}
