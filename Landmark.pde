///Indexes on landmark data

final int Index_LandmarkName = 0;
final int Index_LandmarkAbbr = 1;
final int Index_LandmarkIsAirport = 2;
final int Index_LandmarkLat = 3;
final int Index_LandmarkLng = 4;
final int IconIndexAirport = 4;
final int IconIndexDot = 5;


class Landmark {
  float longitude;
  float latitude;
  String name; //combo of data
  PImage icon;
  float drawLat;
  float drawLng;
  boolean isAirport;
  Landmark(JSONArray landmarkInfo, PImage[] icons) {
    latitude = landmarkInfo.getFloat(Index_LandmarkLat);
    longitude = landmarkInfo.getFloat(Index_LandmarkLng);
    name = landmarkInfo.getString(Index_LandmarkName);
    isAirport = landmarkInfo.getBoolean(Index_LandmarkIsAirport);
    if (isAirport) {
      icon = icons[IconIndexAirport];
    } else {
      icon = icons[IconIndexDot];
    }
  }


  void DrawLandmark() {

    fill(0, 128, 0, 128);
    float drawLat, drawLng;

    drawLng = map(-longitude, -lomin, -lomax, 0, height);
    drawLat = map(latitude, lamin, lamax, 0, width);

    float tdrawlat, tdrawlng;

    tdrawlng = drawLng;
    tdrawlat = abs(drawLat - width);
    //tdrawlat = drawLat;

    if (!alreadyPrinted) {
      if (numPrinted < 6) {
        numPrinted++;
      } else {
        alreadyPrinted = true;
      }
    }

    text(name, tdrawlat, tdrawlng);

    icon.resize(20, 20);
    image(icon, tdrawlat, tdrawlng);
  }
}
