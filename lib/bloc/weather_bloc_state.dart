import 'package:equatable/equatable.dart';
import 'package:weather/weather.dart';

class WeatherBlocState extends Equatable {
const WeatherBlocState();

@override
List<Object> get props => [];
}

final class WeatherBlocInitial extends WeatherBlocState {}

final class WeatherBlocLoading extends WeatherBlocState {}
final class WeatherBlocFailure extends WeatherBlocState {}
final class WeatherBlocSuccess extends WeatherBlocState {
  final Weather weather;

  const WeatherBlocSuccess(this.weather);

  @override
  List<Object> get props => [weather];
}
// class FiveDayForecastSuccess extends WeatherBlocState {
//   final List<Weather> forecast;
//
//   FiveDayForecastSuccess(this.forecast);
//
//   @override
//   List<Object> get props => [forecast];
// }