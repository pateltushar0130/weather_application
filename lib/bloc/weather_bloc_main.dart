

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather/weather.dart';
import 'package:weather_app/bloc/weather_bloc_event.dart';
import 'package:weather_app/bloc/weather_bloc_state.dart';

class WeatherBloc extends Bloc<WeatherBlocEvent,WeatherBlocState>{
  WeatherBloc():super(WeatherBlocInitial()){
    on<FetchWeather>((event, emit) async {
      emit(WeatherBlocLoading());
      try {
        WeatherFactory wf = WeatherFactory("0b9bbd8aa9475b0dce474768e91282f3", language: Language.ENGLISH);


        Weather weather = await wf.currentWeatherByLocation(
          event.position.latitude,
          event.position.longitude,
        );
        emit(WeatherBlocSuccess(weather));
      } catch (e) {
        emit(WeatherBlocFailure());
      }
    });
  }
}