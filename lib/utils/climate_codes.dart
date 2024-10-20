const Map<String, Map<String, String>> weatherCodes = {
  "0": {
    "description": "Unknown",
    "icon":
        "https://raw.githubusercontent.com/Tomorrow-IO-API/tomorrow-weather-codes/51b9588fa598d7a8fcf26798854e0d74708abcc4/V1_icons/color/unknown.svg",
  },
  "1000": {
    "description": "Clear, Sunny",
    "icon":
        "https://raw.githubusercontent.com/Tomorrow-IO-API/tomorrow-weather-codes/51b9588fa598d7a8fcf26798854e0d74708abcc4/V1_icons/color/clear_day.svg",
  },
  "1100": {
    "description": "Mostly Clear",
    "icon":
        "https://raw.githubusercontent.com/Tomorrow-IO-API/tomorrow-weather-codes/51b9588fa598d7a8fcf26798854e0d74708abcc4/V1_icons/color/mostly_clear_day.svg",
  },
  "1101": {
    "description": "Partly Cloudy",
    "icon":
        "https://raw.githubusercontent.com/Tomorrow-IO-API/tomorrow-weather-codes/51b9588fa598d7a8fcf26798854e0d74708abcc4/V1_icons/color/partly_cloudy_day.svg",
  },
  "1102": {
    "description": "Mostly Cloudy",
    "icon":
        "https://raw.githubusercontent.com/Tomorrow-IO-API/tomorrow-weather-codes/51b9588fa598d7a8fcf26798854e0d74708abcc4/V1_icons/color/mostly_cloudy_day.svg",
  },
  "1001": {
    "description": "Cloudy",
    "icon":
        "https://raw.githubusercontent.com/Tomorrow-IO-API/tomorrow-weather-codes/51b9588fa598d7a8fcf26798854e0d74708abcc4/V1_icons/color/cloudy.svg",
  },
  "2000": {
    "description": "Fog",
    "icon":
        "https://raw.githubusercontent.com/Tomorrow-IO-API/tomorrow-weather-codes/51b9588fa598d7a8fcf26798854e0d74708abcc4/V1_icons/color/fog.svg",
  },
  "2100": {
    "description": "Light Fog",
    "icon":
        "https://raw.githubusercontent.com/Tomorrow-IO-API/tomorrow-weather-codes/51b9588fa598d7a8fcf26798854e0d74708abcc4/V1_icons/color/light_fog.svg",
  },
  "4000": {
    "description": "Drizzle",
    "icon":
        "https://raw.githubusercontent.com/Tomorrow-IO-API/tomorrow-weather-codes/51b9588fa598d7a8fcf26798854e0d74708abcc4/V1_icons/color/drizzle.svg",
  },
  "4001": {
    "description": "Rain",
    "icon":
        "https://raw.githubusercontent.com/Tomorrow-IO-API/tomorrow-weather-codes/51b9588fa598d7a8fcf26798854e0d74708abcc4/V1_icons/color/rain.svg",
  },
  "4200": {
    "description": "Light Rain",
    "icon":
        "https://raw.githubusercontent.com/Tomorrow-IO-API/tomorrow-weather-codes/refs/heads/master/V2_icons/large/png/42000_rain_light_large%402x.png",
  },
  "4201": {
    "description": "Heavy Rain",
    "icon":
        "https://raw.githubusercontent.com/Tomorrow-IO-API/tomorrow-weather-codes/51b9588fa598d7a8fcf26798854e0d74708abcc4/V1_icons/color/heavy_rain.svg",
  },
  "5000": {
    "description": "Snow",
    "icon":
        "https://raw.githubusercontent.com/Tomorrow-IO-API/tomorrow-weather-codes/51b9588fa598d7a8fcf26798854e0d74708abcc4/V1_icons/color/snow.svg",
  },
  "5001": {
    "description": "Flurries",
    "icon":
        "https://raw.githubusercontent.com/Tomorrow-IO-API/tomorrow-weather-codes/51b9588fa598d7a8fcf26798854e0d74708abcc4/V1_icons/color/flurries.svg",
  },
  "5100": {
    "description": "Light Snow",
    "icon":
        "https://raw.githubusercontent.com/Tomorrow-IO-API/tomorrow-weather-codes/51b9588fa598d7a8fcf26798854e0d74708abcc4/V1_icons/color/light_snow.svg",
  },
  "5101": {
    "description": "Heavy Snow",
    "icon":
        "https://raw.githubusercontent.com/Tomorrow-IO-API/tomorrow-weather-codes/51b9588fa598d7a8fcf26798854e0d74708abcc4/V1_icons/color/heavy_snow.svg",
  },
  "6000": {
    "description": "Freezing Drizzle",
    "icon":
        "https://raw.githubusercontent.com/Tomorrow-IO-API/tomorrow-weather-codes/51b9588fa598d7a8fcf26798854e0d74708abcc4/V1_icons/color/freezing_drizzle.svg",
  },
  "6001": {
    "description": "Freezing Rain",
    "icon":
        "https://raw.githubusercontent.com/Tomorrow-IO-API/tomorrow-weather-codes/51b9588fa598d7a8fcf26798854e0d74708abcc4/V1_icons/color/freezing_rain.svg",
  },
  "6200": {
    "description": "Light Freezing Rain",
    "icon":
        "https://raw.githubusercontent.com/Tomorrow-IO-API/tomorrow-weather-codes/51b9588fa598d7a8fcf26798854e0d74708abcc4/V1_icons/color/light_freezing_rain.svg",
  },
  "6201": {
    "description": "Heavy Freezing Rain",
    "icon":
        "https://raw.githubusercontent.com/Tomorrow-IO-API/tomorrow-weather-codes/51b9588fa598d7a8fcf26798854e0d74708abcc4/V1_icons/color/heavy_freezing_rain.svg",
  },
  "7000": {
    "description": "Ice Pellets",
    "icon":
        "https://raw.githubusercontent.com/Tomorrow-IO-API/tomorrow-weather-codes/51b9588fa598d7a8fcf26798854e0d74708abcc4/V1_icons/color/ice_pellets.svg",
  },
  "7101": {
    "description": "Heavy Ice Pellets",
    "icon":
        "https://raw.githubusercontent.com/Tomorrow-IO-API/tomorrow-weather-codes/51b9588fa598d7a8fcf26798854e0d74708abcc4/V1_icons/color/heavy_ice_pellets.svg",
  },
  "7102": {
    "description": "Light Ice Pellets",
    "icon":
        "https://raw.githubusercontent.com/Tomorrow-IO-API/tomorrow-weather-codes/51b9588fa598d7a8fcf26798854e0d74708abcc4/V1_icons/color/light_ice_pellets.svg",
  },
  "8000": {
    "description": "Thunderstorm",
    "icon":
        "https://raw.githubusercontent.com/Tomorrow-IO-API/tomorrow-weather-codes/51b9588fa598d7a8fcf26798854e0d74708abcc4/V1_icons/color/thunderstorm.svg",
  },
};
