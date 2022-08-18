
//Sky contains a counter for how often we draw, the collections of existing planes, along with functions to call to draw, offsets for adjustments



public static class Sky {
  static  boolean UseLive;
  static  int LastUpdateSky;
  static  int LastUpdateEdge;
  static int CurrentTime;
  static int LiveThreshhold;
  static int  PredictThreshold;
  static int LastPredictionSky;
  static int LastPredictionEdge;
  String Path;
  Sky(boolean useLive, String path) {
    UseLive = useLive;
    Path = path;
    LiveThreshhold = 30000; //default. Only update "live" data every 1 minutes.
    PredictThreshold = 1000;
  }
}

class SkyNetworkSkyData extends Sky {
  public SkyNetworkPlane[] planes;
  void UpdateData() {
  }
  SkyNetworkSkyData(boolean useLive, String path) {
    super(useLive, path);
    JSONObject flightData;
    if (useLive) {
      flightData =  loadJSONObject("https://USERNAME:PASSWORD@opensky-network.org/api/states/all?lamin=" + lamin + "&lomin=" + lomin + "&lamax=" + lamax + "&lomax=" + lomax + "");
      saveJSONObject(flightData, "data/flightdata" + time + ".json");
    } else {
      //DISABLEprintln(path);
      flightData = loadJSONObject(path);
    }
    JSONArray flightArray = flightData.getJSONArray("states");



    planes = new SkyNetworkPlane[flightArray.size()];
    //if it's use live, then, we need to at least load initial data.
    for (int i = 0; i<flightArray.size(); i++) {
      ////do plane stuff

      planes [i] = new SkyNetworkPlane(flightArray.getJSONArray(i));
    }
  }
  void Draw() {

    Sky.CurrentTime = millis();
    if (Sky.CurrentTime - Sky.LastUpdateSky > Sky.LiveThreshhold) {
      //WE UPDATE! Get the data, or skip it, and draw everything.
      Sky.LastUpdateSky =  Sky.CurrentTime;
      Sky.CurrentTime = millis();

      if (Sky.UseLive) {
        JSONObject  flightData =  loadJSONObject("https://USERNAME:PASSWORD@opensky-network.org/api/states/all?lamin=" + lamin + "&lomin=" + lomin + "&lamax=" + lamax + "&lomax=" + lomax + "");

        JSONArray flightArray = flightData.getJSONArray("states");
        planes = new SkyNetworkPlane[flightArray.size()];
        //DISABLEprintln("updating from source");
        for (int i = 0; i<flightArray.size(); i++) {
          ////do plane stuff
          planes [i] = new SkyNetworkPlane(flightArray.getJSONArray(i));
        }
      }
    } else {
      float   predictionTime;
      if ((float) millis() - Sky.LastPredictionSky > Sky.PredictThreshold) {
        predictionTime = (float) millis() - (float) Sky.LastPredictionSky;
        Sky.LastPredictionSky = millis();
        for (int i = 0; i < planes.length; i++) {
          planes[i].Predict(predictionTime); //update position based on heading and speed
        }
      }
    }
    for (int i = 0; i < planes.length; i++) {
      planes[i].DrawPlane();
    }
  }
}



class EdgeSkyData extends Sky {
  public EdgePlane[] planes;
  void UpdateData() {
  }
  /*  SkyData(boolean useLive, String path){
   super.UseLive = useLive;
   }*/
  EdgeSkyData(boolean useLive, String path) {
    super(useLive, path);
    if (useLive) {
      edge_flight_data_arrive = loadJSONArray("https://aviation-edge.com/v2/public/flights?key=" + AVIATION_EDGE_KEY + "&arrIata=AUS");
      saveJSONArray(edge_flight_data_arrive, "data/edge" + time + ".json");
    } else {
      edge_flight_data_arrive = loadJSONArray(path);
    }
    int numEdgePlanesAr =  edge_flight_data_arrive.size();
    planes = new EdgePlane[numEdgePlanesAr];

    for (int i = 0; i<numEdgePlanesAr; i++) {
      ////do plane stuff
      planes[i] = new EdgePlane(edge_flight_data_arrive.getJSONObject(i));
    }
  }
  void Draw() {

    Sky.CurrentTime = millis();
    if (Sky.CurrentTime - Sky.LastUpdateEdge > Sky.LiveThreshhold) {
      //WE UPDATE! Get the data, or skip it, and draw everything.
      Sky.LastUpdateEdge =  Sky.CurrentTime;
      Sky.CurrentTime = millis();
      if (Sky.UseLive) {
        //DISABLEprintln("updating from source");
        edge_flight_data_arrive = loadJSONArray("https://aviation-edge.com/v2/public/flights?key=" + AVIATION_EDGE_KEY + "&arrIata=AUS");
      } else {
        edge_flight_data_arrive = loadJSONArray("data/edge.json");
      }
      int numEdgePlanesAr =  edge_flight_data_arrive.size();
      planes = new EdgePlane[numEdgePlanesAr];
      for (int i = 0; i<numEdgePlanesAr; i++) {
        ////do plane stuff
        planes[i] = new EdgePlane(edge_flight_data_arrive.getJSONObject(i));
      }
    } else {
      float   predictionTime;
      if ((float) millis() - Sky.LastPredictionEdge > Sky.PredictThreshold) {  //I'm proud of this! I'm making the planes less jittery
        predictionTime = (float) millis() - (float) Sky.LastPredictionEdge;
        Sky.LastPredictionEdge = millis();
        for (int i = 0; i < planes.length; i++) {
          planes[i].Predict(predictionTime); //update position based on heading and speed
        }
      }
    }
    for (int i = 0; i < planes.length; i++) {
      planes[i].DrawEdgePlane();
    }
  }
}


//JSONArray flight;
////Indexes on flight data for SkyNetwork Planes
final  int  Index_icao24  =  0; //  Unique ICAO 24-bit address of the transponder in hex string representation.
final  int  Index_callsign  =  1; //  Callsign of the vehicle (8 chars). Can be null if no callsign has been received.
final  int  Index_origin_country  =  2; //  Country name inferred from the ICAO 24-bit address.
final  int  Index_time_position  =  3; //  Unix timestamp (seconds) for the last position update. Can be null if no position report was received by OpenSky within the past 15s.
final  int  Index_last_contact  =  4; //  Unix timestamp (seconds) for the last update in general. This field is updated for any new, valid message received from the transponder.
final  int  Index_longitude  =  5; //  WGS-84 longitude in decimal degrees. Can be null.
final  int  Index_latitude  =  6; //  WGS-84 latitude in decimal degrees. Can be null.
final  int  Index_baro_altitude  =  7; //  Barometric altitude in meters. Can be null.
final  int  Index_on_ground  =  8; //  Boolean value which indicates if the position was retrieved from a surface position report.
final  int  Index_velocity  =  9; //  Velocity over ground in m/s. Can be null.
final  int  Index_true_track  =  10; //  True track in decimal degrees clockwise from north (north=0°). Can be null.
final  int  Index_vertical_rate  =  11; //  Vertical rate in m/s. A positive value indicates that the airplane is climbing, a negative value indicates that it descends. Can be null.
final  int  Index_sensors  =  12; //  IDs of the receivers which contributed to this state vector. Is null if no filtering for sensor was used in the request.
final  int  Index_geo_altitude  =  13; //  Geometric altitude in meters. Can be null.
final  int  Index_squawk  =  14; //  The transponder code aka Squawk. Can be null.
final  int  Index_spi  =  15; //  Whether flight status indicates special purpose indicator.
final  int  Index_position_source  =  16; //  Origin of this state’s position: 0 = ADS-B, 1 = ASTERIX, 2 = MLAT







class  SkyNetworkPlane {
  String icao24; // Unique ICAO 24-bit address of the transponder in hex string representation.
  String callsign; // Callsign of the vehicle (8 chars). Can be null if no callsign has been received.
  String origin_country; // Country name inferred from the ICAO 24-bit address.
  int time_position; // Unix timestamp (seconds) for the last position update. Can be null if no position report was received by OpenSky within the past 15s.
  int last_contact; // Unix timestamp (seconds) for the last update in general. This field is updated for any new, valid message received from the transponder.
  float longitude; // WGS-84 longitude in decimal degrees. Can be null.
  float latitude; // WGS-84 latitude in decimal degrees. Can be null.
  float baro_altitude; // Barometric altitude in meters. Can be null.
  boolean on_ground; // Boolean value which indicates if the position was retrieved from a surface position report.
  float velocity; // Velocity over ground in m/s. Can be null.
  float true_track; // TRUE track in decimal degrees clockwise from north (north=0°). Can be null.
  float vertical_rate; // Vertical rate in m/s. A positive value indicates that the airplane is climbing, a negative value indicates that it descends. Can be null.
  int[] sensors; // IDs of the receivers which contributed to this state vector. Is null if no filtering for sensor was used in the request.
  float geo_altitude; // Geometric altitude in meters. Can be null.
  String squawk; // The transponder code aka Squawk. Can be null.
  boolean spi; // Whether flight status indicates special purpose indicator.
  int position_source; // Origin of this state’s position: 0 #ERROR! ADS-B, 1 #ERROR! ASTERIX, 2 #ERROR! MLAT
  String name; //combo of data
  PImage icon;
  float drawLat;
  float drawLng;
  float track;
  SkyNetworkPlane(JSONArray flightInfo) {
    //DISABLEprintln(flightInfo);
    latitude = flightInfo.getFloat(Index_latitude);
    longitude = flightInfo.getFloat(Index_longitude);
    track = flightInfo.getFloat(Index_true_track);
    //name = flightInfo.getString(Index_callsign)  + flightInfo.getString(Index_icao24);
    name = flightInfo.getString(Index_callsign);
    true_track = flightInfo.getFloat(Index_true_track);
    velocity = flightInfo.getFloat(Index_velocity);
  }
  void Predict(float ElapsedMillis) {
    //The speed given is in km per hour
    //The time is typically a minute or so. predict

    float hoursPassed = ElapsedMillis/1000/60/60;
    //DISABLEprintln("hours " + hoursPassed);

    float d = hoursPassed * velocity;
    //DISABLEprintln("d " + d);
    float R = 6378.1; //radius of earth
    float rad = radians(true_track);

    float lat1 = radians(latitude);
    float lon1 = radians(longitude);

    float lat2 = asin(sin(lat1)*cos(d/R)+cos(lat1)*sin(d/R)*cos(rad));

    float lon2 = lon1 + atan2(sin(rad)*sin(d/R)*cos(lat1), cos(d/R)-sin(lat1)*sin(lat2));


    float latALT = degrees(lat2);
    float lonALT = degrees(lon2);
    latitude = latALT;
    longitude = lonALT;
  }


  void DrawPlane() {


    drawLng = map(longitude, lomin, lomax, 0, width);
    drawLat = map(latitude, lamin, lamax, 0, height );

    pushMatrix();
    fill(128, 0, 0, 128);


    drawLat = abs(drawLat-height);

    translate(drawLng, drawLat);
    //text(name, drawLng, drawLat );
    text(name, 5, 5 );
    float rotation = radians(true_track);
    rotate(rotation);

    icon = icons[1];


    icon.resize(10, 10);


    // rotate(radians(track));
    //image(icon, drawLng, drawLat);
    image(icon, 0, 0);
    popMatrix();
  }
}



class EdgePlane {
  String icao24; // Unique ICAO 24-bit address of the transponder in hex string representation.
  String   iataCode; //Another unique
  String   icaoCode; //Another unique
  String    regNumber;
  String callsign; // Callsign of the vehicle (8 chars). Can be null if no callsign has been received.
  String origin_country; // Country name inferred from the ICAO 24-bit address.
  int time_position; // Unix timestamp (seconds) for the last position update. Can be null if no position report was received by OpenSky within the past 15s.
  int last_contact; // Unix timestamp (seconds) for the last update in general. This field is updated for any new, valid message received from the transponder.
  float longitude; // WGS-84 longitude in decimal degrees. Can be null.
  float latitude; // WGS-84 latitude in decimal degrees. Can be null.
  float baro_altitude; // Barometric altitude in meters. Can be null.
  boolean on_ground; // Boolean value which indicates if the position was retrieved from a surface position report.
  float velocity; // Velocity over ground in m/s. Can be null.
  float true_track; // TRUE track in decimal degrees clockwise from north (north=0°). Can be null.
  float vertical_rate; // Vertical rate in m/s. A positive value indicates that the airplane is climbing, a negative value indicates that it descends. Can be null.
  int[] sensors; // IDs of the receivers which contributed to this state vector. Is null if no filtering for sensor was used in the request.
  float geo_altitude; // Geometric altitude in meters. Can be null.
  String squawk; // The transponder code aka Squawk. Can be null.
  boolean spi; // Whether flight status indicates special purpose indicator.
  int position_source; // Origin of this state’s position: 0 #ERROR! ADS-B, 1 #ERROR! ASTERIX, 2 #ERROR! MLAT
  String flightnumber;
  String arrival;
  String departure;
  String name; //combo of data
  PImage icon;
  float drawLat;
  float drawLng;
  float track;
  EdgePlane(JSONObject flightInfo) {

    iataCode = flightInfo.getJSONObject("aircraft").getString("iataCode");
    icaoCode = flightInfo.getJSONObject("aircraft").getString("icaoCode");
    regNumber = flightInfo.getJSONObject("aircraft").getString("regNumber");
    latitude = flightInfo.getJSONObject("geography").getFloat("latitude");
    longitude = flightInfo.getJSONObject("geography").getFloat("longitude");
    true_track = flightInfo.getJSONObject("geography").getFloat("direction");
    velocity = flightInfo.getJSONObject("speed").getFloat("horizontal");
    flightnumber = flightInfo.getJSONObject("flight").getString("number");
    arrival = flightInfo.getJSONObject("arrival").getString("icaoCode");
    departure = flightInfo.getJSONObject("departure").getString("icaoCode");
    //name = iataCode + " " + regNumber;
    name = flightnumber + " " + regNumber;
    //DISABLEprintln("name " + name + " lat " + latitude +  " lng " + longitude);
    /*  latitude = flightInfo.getFloat(Index_latitude);
     longitude = flightInfo.getFloat(Index_longitude);
     track = flightInfo.getFloat(Index_true_track);
     name = flightInfo.getString(Index_callsign)  + flightInfo.getString(Index_icao24);*/
  }


  void DrawEdgePlane() {

    drawLng = map(-longitude, -lomin, -lomax, 0, width);
    drawLat = map(latitude, lamin, lamax, 0, height );

    drawLat = abs(drawLat-height);



    pushMatrix();
    fill(128, 0, 0, 128);


    translate(drawLng, drawLat);
    //text(name, drawLng, drawLat );
    text(name, 5, 5 );
    float rotation = radians(true_track);
    rotate(rotation);

    icon = icons[0];

    icon.resize(10, 10);

    image(icon, 0, 0);
    popMatrix();
  }


  void Predict(float ElapsedMillis) {
    //The speed given is in km per hour
    //The time is typically a minute or so. predict

    float hoursPassed = ElapsedMillis/1000/60/60;
    float d = hoursPassed * velocity;
    float R = 6378.1; //radius of earth
    float rad = radians(true_track);

    float lat1 = radians(latitude);
    float lon1 = radians(longitude);

    float lat2 = asin(sin(lat1)*cos(d/R)+cos(lat1)*sin(d/R)*cos(rad));

    float lon2 = lon1 + atan2(sin(rad)*sin(d/R)*cos(lat1), cos(d/R)-sin(lat1)*sin(lat2));


    float latALT = degrees(lat2);
    float lonALT = degrees(lon2);
    latitude = latALT;
    longitude = lonALT;
  }
}
