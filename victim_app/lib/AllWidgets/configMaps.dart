String mapKey = "AIzaSyCO1QoDF2cYJBLIezJ4XtiCOZuNU0UPCkE";
int driverRequestTimeOut = 30;
String serverToken =
    "key=AAAAh9pmPFU:APA91bHtYhmSlrtiev178hj5GmGyYHjiJG2wCRMURy0sn8csZfeyLJuR_LsdkwF2g69STVU6PBl4_EzxeUxUFCuXADSxVD-zAdpmcOM4xdTraYu7ldJK0WL5bhYHAfKVJ4w6tC_63jhp";
String getHospitalUrl =
    "https://api.foursquare.com/v2/venues/search?client_id=SLJZCERSJQQHQXHCGDYIJKXCLHBFTS1EBWH3ZSSOHIWV4CJ1&client_secret=GKJTSBDOXLEFBEZMAFLIQ2APLF4UNWUHMLKMOJITU1O0SSO5&v=20180323&limit=1&ll=18.4395203,73.8012855&radius=5000&query=hospital";

String statusRide = "";
String carDetailsDriver = "";
String carDrivername = "";
String driverPhone = "";
String rideStatus = "Driver is arriving";
var obj = {
  "meta": {"code": 200, "requestId": "60bf64bc49d56e7e7e64ee3b"},
  "notifications": [
    {
      "type": "notificationTray",
      "item": {"unreadCount": 0}
    }
  ],
  "response": {
    "venues": [
      {
        "id": "4df6d327b61c40d585eaf4a9",
        "name": "Smt. Kashibai Navale Medical College & General Hospital",
        "contact": {"phone": "02024106271", "formattedPhone": "020 2410 6271"},
        "location": {
          "address": "S.No. 49\/1, Westerly Bypass Road, Narhe (Ambegaon)",
          "lat": 18.456609297261593,
          "lng": 73.82009492944451,
          "labeledLatLngs": [
            {
              "label": "display",
              "lat": 18.456609297261593,
              "lng": 73.82009492944451
            }
          ],
          "distance": 2750,
          "postalCode": "411041",
          "cc": "IN",
          "city": "Pune",
          "state": "Mahārāshtra",
          "country": "India",
          "contextLine": "Pune, Mahārāshtra",
          "contextGeoId": -789433131,
          "formattedAddress": [
            "<span itemprop=\"streetAddress\">S.No. 49\/1, Westerly Bypass Road, Narhe (Ambegaon)<\/span>",
            "<span itemprop=\"addressLocality\">Pune<\/span> <span itemprop=\"postalCode\">411041<\/span>",
            "<span itemprop=\"addressRegion\">Mah&#257;r&#257;shtra<\/span>"
          ]
        },
        "canonicalUrl":
            "https:\/\/foursquare.com\/v\/smt-kashibai-navale-medical-college--general-hospital\/4df6d327b61c40d585eaf4a9",
        "canonicalPath":
            "\/v\/smt-kashibai-navale-medical-college--general-hospital\/4df6d327b61c40d585eaf4a9",
        "categories": [
          {
            "id": "4bf58dd8d48988d1b3941735",
            "name": "Medical School",
            "pluralName": "Medical Schools",
            "shortName": "Medical School",
            "icon": {
              "prefix":
                  "https:\/\/ss3.4sqi.net\/img\/categories_v2\/building\/medical_",
              "mapPrefix":
                  "https:\/\/ss3.4sqi.net\/img\/categories_map\/education\/medicalschool",
              "suffix": ".png"
            },
            "primary": true
          }
        ],
        "verified": false,
        "stats": {"tipCount": 3, "usersCount": 78, "checkinsCount": 542},
        "url": "http:\/\/www.sknmcgh.org",
        "urlSig": "xfqiPXDy3tLuBN8hR\/mVjSjMyGw=",
        "venueRatingBlacklisted": true,
        "allowMenuUrlEdit": true,
        "beenHere": {"lastCheckinExpiredAt": 0},
        "specials": {"count": 0, "items": []},
        "hereNow": {"count": 0, "summary": "Nobody here", "groups": []},
        "referralId": "v-1623155900",
        "venueChains": [],
        "hasPerk": false
      }
    ]
  }
};

var polylines = {
  "formatVersion": "0.0.12",
  "routes": [
    {
      "summary": {
        "lengthInMeters": 1147,
        "travelTimeInSeconds": 142,
        "trafficDelayInSeconds": 0,
        "trafficLengthInMeters": 0,
        "departureTime": "2021-06-08T20:21:39+02:00",
        "arrivalTime": "2021-06-08T20:24:00+02:00"
      },
      "legs": [
        {
          "summary": {
            "lengthInMeters": 1147,
            "travelTimeInSeconds": 142,
            "trafficDelayInSeconds": 0,
            "trafficLengthInMeters": 0,
            "departureTime": "2021-06-08T20:21:39+02:00",
            "arrivalTime": "2021-06-08T20:24:00+02:00"
          },
          "points": [
            {"latitude": 52.50930, "longitude": 13.42937},
            {"latitude": 52.50904, "longitude": 13.42913},
            {"latitude": 52.50895, "longitude": 13.42904},
            {"latitude": 52.50868, "longitude": 13.42880},
            {"latitude": 52.50840, "longitude": 13.42857},
            {"latitude": 52.50816, "longitude": 13.42839},
            {"latitude": 52.50791, "longitude": 13.42825},
            {"latitude": 52.50757, "longitude": 13.42772},
            {"latitude": 52.50752, "longitude": 13.42785},
            {"latitude": 52.50742, "longitude": 13.42809},
            {"latitude": 52.50735, "longitude": 13.42824},
            {"latitude": 52.50730, "longitude": 13.42837},
            {"latitude": 52.50696, "longitude": 13.42910},
            {"latitude": 52.50673, "longitude": 13.42961},
            {"latitude": 52.50619, "longitude": 13.43092},
            {"latitude": 52.50608, "longitude": 13.43116},
            {"latitude": 52.50574, "longitude": 13.43195},
            {"latitude": 52.50564, "longitude": 13.43218},
            {"latitude": 52.50528, "longitude": 13.43299},
            {"latitude": 52.50513, "longitude": 13.43336},
            {"latitude": 52.50500, "longitude": 13.43366},
            {"latitude": 52.50464, "longitude": 13.43451},
            {"latitude": 52.50451, "longitude": 13.43482},
            {"latitude": 52.50444, "longitude": 13.43499},
            {"latitude": 52.50418, "longitude": 13.43564},
            {"latitude": 52.50364, "longitude": 13.43690},
            {"latitude": 52.50343, "longitude": 13.43738},
            {"latitude": 52.50330, "longitude": 13.43767},
            {"latitude": 52.50275, "longitude": 13.43873}
          ]
        }
      ],
      "sections": [
        {
          "startPointIndex": 0,
          "endPointIndex": 28,
          "sectionType": "TRAVEL_MODE",
          "travelMode": "car"
        }
      ]
    }
  ]
};
