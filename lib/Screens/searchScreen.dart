// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:weather_app/model/response.dart';
// import 'package:weather_app/model/weather_Model.dart';
//
// class SearchScreen extends StatefulWidget {
//   const SearchScreen({Key? key}) : super(key: key);
//
//   @override
//   State<SearchScreen> createState() => _SearchScreenState();
// }
//
// class _SearchScreenState extends State<SearchScreen> {
//   TextEditingController searchController = TextEditingController();
//   WeatherModel? weatherModel;
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         systemOverlayStyle: SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
//         iconTheme: IconThemeData(color: Colors.white),
//       ),
//       body: Padding(
//         padding: EdgeInsets.fromLTRB(20, 1.5 * kToolbarHeight, 40, 20),
//         child: SizedBox(
//           height: MediaQuery.of(context).size.height,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "Weather",
//                 style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30),
//               ),
//               SizedBox(height: 20),
//               Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: searchController,
//                       decoration: InputDecoration(
//                         hintText: 'Search for a city',
//                         hintStyle: TextStyle(color: Colors.white),
//                         prefixIcon: Icon(Icons.search, color: Colors.white),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10),
//                           borderSide: BorderSide(color: Colors.white),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10),
//                           borderSide: BorderSide(color: Colors.white),
//                         ),
//                         contentPadding: EdgeInsets.symmetric(vertical: 7),
//                         fillColor: Colors.grey[700],
//                         filled: true,
//                       ),
//                       style: TextStyle(color: Colors.white),
//                       cursorColor: Colors.white,
//                     ),
//                   ),
//                   SizedBox(width: 5,),
//                   Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(10),
//                       border: Border.all(color: Colors.black),
//                       color: Colors.grey[700],
//                     ),
//                     child: IconButton(
//                       onPressed: () async{
//                         weatherModel = await Repo().getWeather(searchController.text);
//                         print(weatherModel?.main?.temp);
//                         setState(() {
//
//                         });
//
//                       },
//                       icon: Icon(Icons.search, color: Colors.white),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';
import '../database/weatherData.dart';
import 'package:path/path.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController();
  List<WeatherCard> weatherCards = [];

  WeatherFactory wf = WeatherFactory("0b9bbd8aa9475b0dce474768e91282f3", language: Language.ENGLISH);
  Weather? _weather;

  @override
  void initState() {
    super.initState();
    _getWeatherCardsFromDB();
  }

  void _showWeatherBottomSheet(BuildContext context) async {
    final weather = await wf.currentWeatherByCityName(searchController.text);
    setState(() {
      _weather = weather;
    });
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
            child: Container(
              color: Colors.lightBlueAccent,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text("Cancle",style: TextStyle(color:Colors.white,fontSize: 18),),
                        ),
                        TextButton(
                          onPressed: () {
                            _addWeatherCard();
                            Navigator.of(context).pop();
                          },
                          child: Text("Add",style: TextStyle(color: Colors.white,fontSize: 18),),
                        ),
                      ],
                    ),

                      Text(
                        "📍 ${_weather?.country}",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${_weather?.areaName}",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),

                      SizedBox(
                        height: 8,
                      ),
                      getWeatherIcon(
                          _weather!.weatherConditionCode!),

                      Center(
                        child: Text(
                          "${_weather?.temperature!.celsius!.round()}°C",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 55,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Center(
                        child: Text(
                          _weather!.weatherMain!.toUpperCase(),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "H:${_weather?.tempMax!.celsius!.round().toString()}°C",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700),
                            ),
                            SizedBox(width: 10,),
                            Text(
                              "L:${_weather?.tempMin!.celsius!.round().toString()}°C",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text("Additional Information",style: TextStyle(fontSize: 18,color: Colors.white,fontWeight: FontWeight.bold),),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 5.0),
                        child: Divider(
                          color: Colors.orange,
                        ),
                      ),
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                'assets/13.png',
                                scale: 8,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Temp Max',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w300),
                                  ),
                                  Text(
                                    "${_weather?.tempMax!.celsius!.round().toString()}°C",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Image.asset(
                                'assets/14.png',
                                scale: 8,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Temp min',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w300),
                                  ),
                                  Text(
                                    "${_weather?.tempMin!.celsius!.round().toString()}°C",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                'assets/9.png',
                                scale: 8,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Wind Speed',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w300),
                                  ),
                                  Text(
                                    "${_weather?.windSpeed} KPH",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          Row(
                            children: [
                              Image.asset(
                                'assets/9.png',
                                scale: 8,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Direction',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w300),
                                  ),
                                  Text(
                                    "${_weather?.windDegree}",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ],
                          ),

                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                'assets/7.png',
                                scale: 8,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Humidity level',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w300),
                                  ),
                                  Text(
                                    "${_weather?.humidity} %",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(20, 1.5 * kToolbarHeight, 40, 20),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Weather",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search for a city',
                        hintStyle: TextStyle(color: Colors.white),
                        prefixIcon: Icon(Icons.search, color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 7),
                        fillColor: Colors.grey[700],
                        filled: true,
                      ),
                      style: TextStyle(color: Colors.white),
                      cursorColor: Colors.white,
                    ),
                  ),
                  SizedBox(width: 5),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black),
                      color: Colors.grey[700],
                    ),
                    child: IconButton(
                      onPressed: ()  {
                        _showWeatherBottomSheet(context);
                        print("temp :${_weather?.temperature!.celsius?.round()}");
                      },
                      icon: Icon(Icons.search, color: Colors.white),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: weatherCards.length,
                  itemBuilder: (context, index) {
                    return weatherCards[index];
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getWeatherIcon(int code) {
    switch (code) {
      case >= 200 && < 300:
        return Image.asset('assets/1.png');
      case >= 300 && < 400:
        return Image.asset('assets/2.png');
      case >= 500 && < 600:
        return Image.asset('assets/3.png');
      case >= 600 && < 700:
        return Image.asset('assets/4.png');
      case >= 700 && < 800:
        return Image.asset('assets/5.png');
      case == 800:
        return Image.asset('assets/6.png');
      case > 800 && <= 804:
        return Image.asset('assets/7.png');
      default:
        return Image.asset('assets/7.png');
    }
  }
  void _addWeatherCard() async {
    if (_weather != null) {
      final newCard = {
        'city_name': _weather!.areaName,
        'temperature': _weather!.temperature!.celsius!.round(),
        'description': _weather!.weatherMain!.toUpperCase(),
      };
      await WeatherDatabase.instance.insertWeatherCard(newCard);
      _getWeatherCardsFromDB();
    }
  }

  void _getWeatherCardsFromDB() async {
    final cards = await WeatherDatabase.instance.getWeatherCards();
    setState(() {
      weatherCards = cards
          .map((card) => WeatherCard(
        id: card['id'],
        cityName: card['city_name'],
        temperature: card['temperature'],
        description: card['description'],
        onDelete: _deleteWeatherCard,
      ))
          .toList();
    });
  }

  void _deleteWeatherCard(int id) async {
    await WeatherDatabase.instance.deleteWeatherCard(id);
    _getWeatherCardsFromDB();
  }
}





class WeatherCard extends StatelessWidget {
  final int id;
  final String cityName;
  final int temperature;
  final String description;
  final Function(int) onDelete;

  const WeatherCard({
    required this.id,
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.onDelete,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.lightBlueAccent,
      elevation: 1,
      child: ListTile(
        title: Text(cityName),
        subtitle: Text('$temperature°C, $description'),
        trailing: ElevatedButton(
          onPressed: () {
            onDelete(id);
            },
          child: Icon(Icons.delete, color: Colors.red),
        ),
      ),
    );
  }
}