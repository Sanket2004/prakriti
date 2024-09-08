import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weather/weather.dart';
import 'package:geolocator/geolocator.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  WeatherFactory wf = WeatherFactory("879534249ba8994e78dc54c905135a09");
  Weather? weather;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        setState(() {
          errorMessage = "Location services are disabled.";
        });
      }
      return;
    }

    // Check for location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        if (mounted) {
          setState(() {
            errorMessage = "Location permissions are denied.";
          });
        }
        return;
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      Weather? fetchedWeather = await wf.currentWeatherByLocation(
        position.latitude,
        position.longitude,
      );
      if (mounted) {
        setState(() {
          weather = fetchedWeather;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = "Failed to get location or weather data.";
        });
      }
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri _url = Uri.parse(url);
    try {
      if (await launchUrl(_url)) {
        throw Exception('Could not launch $_url');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: const Color.fromARGB(255, 255, 255, 255),
              border: Border.all(
                width: 2,
                color: Colors.grey.shade300,
              ),
            ),
            width: MediaQuery.of(context).size.width * 0.8,
            height: 130,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: weather == null
                    ? errorMessage != null
                        ? Text(errorMessage!)
                        : const SizedBox(
                            width: 50,
                            child: LinearProgressIndicator(
                              minHeight: 5,
                              color: Color(0xff399918),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                            ),
                          )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Use Flexible to prevent overflow
                          Flexible(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Display the area and country name
                                Text(
                                  "${weather!.areaName}, ${weather!.country}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    overflow: TextOverflow
                                        .ellipsis, // Handle long text with ellipsis
                                  ),
                                  maxLines: 1, // Limit the number of lines to 1
                                ),
                                const SizedBox(
                                    height: 4), // Add spacing between the texts
                                // Display weather description (e.g. clear sky, etc.)
                                Text(
                                  weather!.weatherDescription ?? "",
                                  style: const TextStyle(fontSize: 16),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                              width: 10), // Add space between the text and icon
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Add a SizedBox to control the image size
                              SizedBox(
                                height: 40,
                                width: 40,
                                child: Image.network(
                                  "http://openweathermap.org/img/wn/${weather!.weatherIcon}@4x.png",
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(
                                  height:
                                      4), // Add spacing between icon and temperature
                              Text(
                                "${weather?.temperature?.celsius?.toStringAsFixed(0)}°",
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: const Color.fromARGB(255, 255, 255, 255),
              border: Border.all(
                width: 2,
                color: Colors.grey.shade300,
              ),
            ),
            width: MediaQuery.of(context).size.width * 0.8,
            height: 130,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: weather == null
                    ? errorMessage != null
                        ? Text(errorMessage!)
                        : const SizedBox(
                            width: 50,
                            child: LinearProgressIndicator(
                              minHeight: 5,
                              color: Color(0xff399918),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                            ),
                          )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Use Flexible to prevent overflow
                          Flexible(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Display the area and country name
                                Text(
                                  "Cloudiness: ${weather!.cloudiness}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    overflow: TextOverflow
                                        .ellipsis, // Handle long text with ellipsis
                                  ),
                                  maxLines: 1, // Limit the number of lines to 1
                                ),
                                const SizedBox(
                                    height: 4), // Add spacing between the texts
                                // Display weather description (e.g. clear sky, etc.)
                                Text(
                                  weather!.weatherDescription ?? "",
                                  style: const TextStyle(fontSize: 16),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                              width: 10), // Add space between the text and icon
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                height: 40,
                                width: 40,
                                child: Icon(
                                  Icons.thermostat_outlined,
                                  size: 30,
                                ),
                              ),
                              Text(
                                "${weather?.tempMax}",
                                style: const TextStyle(fontSize: 16),
                              ),
                              // Add a SizedBox to control the image size
                              // SizedBox(
                              //   height: 40,
                              //   width: 40,
                              //   child: Image.network(
                              //     "http://openweathermap.org/img/wn/${weather!.weatherIcon}@4x.png",
                              //     fit: BoxFit.contain,
                              //   ),
                              // ),
                            ],
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
