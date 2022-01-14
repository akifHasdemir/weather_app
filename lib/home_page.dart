import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hava_durumu/search_page.dart';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

import 'daily_weather_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String sehir = 'Ankara';
  int? sicaklik;
  var locationData;
  var woeid;
  String abbr = 'c';
  Position? position;

  List temps = List.filled(5, 0);

  List<String> abbrs = List.filled(5, "");
  List<String> dates = List.filled(5, "");

  Future<void> getDevicePosition() async {
    try {
      position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low);
    } catch (error) {
      print('Şu hata oluştu: $error');
    } finally {
      //her ne olursa olsun buradaki kod çalışsın...
    }
  }

  Future<void> getLocationTemperature() async {
    var response =
        await http.get('https://www.metaweather.com/api/location/$woeid/');
    var temperatureDataParsed = jsonDecode(response.body);
    //sicaklik = temperatureDataParsed['consolidated_weather'][0]['the_temp'];

    setState(
      () {
        sicaklik = temperatureDataParsed['consolidated_weather'][0]['the_temp']
            .round();

        for (int i = 0; i < temps.length; i++) {
          temps[i] = temperatureDataParsed['consolidated_weather'][i + 1]
                  ['the_temp']
              .round();

          abbrs[i] = temperatureDataParsed['consolidated_weather'][i + 1]
              ['weather_state_abbr'];

          dates[i] = temperatureDataParsed['consolidated_weather'][i + 1]
              ['applicable_date'];
        }

        abbr = temperatureDataParsed['consolidated_weather'][0]
            ['weather_state_abbr'];
      },
    );
  }

  Future<void> getLocationData() async {
    locationData = await http
        .get('https://www.metaweather.com/api/location/search/?query=$sehir');
    var locationDataParsed = jsonDecode(locationData.body);
    woeid = locationDataParsed[0]['woeid'];
  }

  Future<void> getLocationDataLatLong() async {
    locationData = await http.get(
        'https://www.metaweather.com/api/location/search/?lattlong=${position?.latitude},${position?.longitude}');
    var locationDataParsed = jsonDecode(utf8.decode(locationData.bodyBytes));
    woeid = locationDataParsed[0]['woeid'];
    sehir = locationDataParsed[0]['title'];
  }

  void getDataFromAPI() async {
    await getDevicePosition(); //cihazdan konum bilgisi çekiyoruz
    await getLocationData(); // lat ve long ile woeid bilgisini çekiyouz API'dan
    getLocationTemperature(); // woeid bilgisi ile sıcaklık verisi çekiliyor.
  }

  void getDataFromAPIbyCity() async {
    await getLocationData();
    getLocationTemperature();
  }

  @override
  void initState() {
    getDataFromAPI();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage('assets/$abbr.jpg'),
        ),
      ),
      child: sicaklik == null
          ? Center(child: CircularProgressIndicator())
          : Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 60,
                      width: 60,
                      child: Image.network(
                          'https://www.metaweather.com/static/img/weather/png/$abbr.png'),
                    ),
                    Text(
                      '$sicaklik° C',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 70,
                        shadows: <Shadow>[
                          Shadow(
                            color: Colors.black38,
                            blurRadius: 7,
                            offset: Offset(-3, 3),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$sehir',
                          style: TextStyle(
                            fontSize: 30,
                            shadows: <Shadow>[
                              Shadow(
                                color: Colors.black38,
                                blurRadius: 7,
                                offset: Offset(-3, 3),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () async {
                            sehir = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SearchPage()));
                            getDataFromAPIbyCity();
                            setState(
                              () {
                                sehir = sehir;
                              },
                            );
                          },
                        )
                      ],
                    ),
                    SizedBox(
                      height: 120,
                    ),
                    buildDailyWeatherCard(context),
                  ],
                ),
              ),
            ),
    );
  }

  Container buildDailyWeatherCard(BuildContext context) {
    return Container(
        height: 120,
        width: MediaQuery.of(context).size.width * 0.9,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            DailyWeather(
              date: dates[0],
              temp: temps[0].toString(),
              image: abbrs[0],
            ),
            DailyWeather(
              date: dates[1],
              temp: temps[1].toString(),
              image: abbrs[1],
            ),
            DailyWeather(
              date: dates[2],
              temp: temps[2].toString(),
              image: abbrs[2],
            ),
            DailyWeather(
              date: dates[3],
              temp: temps[3].toString(),
              image: abbrs[3],
            ),
            DailyWeather(
              date: dates[4],
              temp: temps[4].toString(),
              image: abbrs[4],
            ),
          ],
        )
        // ListView.builder(
        //   scrollDirection: Axis.horizontal,
        //   itemCount: 5,
        //   itemBuilder: (_, __) {
        //     return DailyWeather();
        //   },
        // ),
        );
  }
}
