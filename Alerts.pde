//These are weather alerts, notices to airmen, and are drawn at the bottom.


XML xml_tafs, xml_aircraft_reports;



void GetReports(boolean shouldUseLive) {
  if (shouldUseLive) {
    xml_tafs = loadXML("https://aviationweather.gov/adds/dataserver_current/httpparam?dataSource=tafs&requestType=retrieve&format=xml&stationString=KAUS&hoursBeforeNow=4");
    xml_aircraft_reports = loadXML("https://aviationweather.gov/adds/dataserver_current/httpparam?dataSource=aircraftreports&requestType=retrieve&format=xml&minLat=" + lamin + "&minLon=" + lomin + "&maxLat=" + lamax + "&maxLon=" + lomax + "&hoursBeforeNow=96");
  } else {
    xml_tafs = loadXML("data/tafs43.xml");
    xml_aircraft_reports = loadXML("data/aircraft_reports43.xml");
  }
}


void ShowReports(int drawX, int drawY) {

  XML[] children = xml_tafs.getChildren("data");


  XML[] TAF = children[0].getChildren("TAF");

  XML[] pilotReportsData = xml_aircraft_reports.getChildren("data");


  XML[] pilotReports = pilotReportsData[0].getChildren("AircraftReport");

  fill(255, 30);
  rect(drawX, drawY - 20, 980, 40);

  for (int i = 0; i < 1; i++) {
    String raw_text = TAF[i].getChildren("raw_text")[0].getContent();

    fill(204, 102, 0);
    text(raw_text, drawX, drawY + i *20);
  }

  if (pilotReports[0].getChildren("raw_text").length > 0 ) {
    for (int i = 0; i < 1; i++) {

      String raw_report_text = pilotReports[i].getChildren("raw_text")[0].getContent();

      fill(255, 0, 0);
      Alertfont = createFont("Arial", 10, true);

      textFont(Alertfont);

      if (AlertX < 0) {
        text(raw_report_text, AlertX + textWidth(raw_report_text) + 10, AlertY);
      }
      if (AlertX <= -textWidth(raw_report_text)) {
        AlertX = AlertX + (int)textWidth(raw_report_text) + 10;
      }
      AlertX-=10;
      text(raw_report_text, AlertX, AlertY);
    }
  }
}
