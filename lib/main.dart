import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/bloc/weather_bloc_event.dart';
import 'package:weather_app/bloc/weather_bloc_main.dart';

import 'Screens/homeScreen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: FutureBuilder(
            future: _determinePosition(),
            builder: (context, snap) {
              if(snap.hasData) {
                return BlocProvider<WeatherBloc>(
                  create: (context) => WeatherBloc()..add(
                      FetchWeather(snap.data as Position)
                  ),
                  child: const HomeScreen(),
                );
              }
              else {
                return  Scaffold(
                  body: Center(
                    child:Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        CircularProgressIndicator(),
                        SizedBox(height: 3,),
                        Text("Loading....",style: TextStyle(fontSize: 18,color: Colors.black),),
                        SizedBox(height: 5,),
                        ElevatedButton(onPressed: (){
                          _determinePosition();
                          },
                          child:Text("Refresh"),),
                      ],
                    ),
                  ),
                );
              }
            }
        )
    );
  }
}


Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }
  return await Geolocator.getCurrentPosition();
}