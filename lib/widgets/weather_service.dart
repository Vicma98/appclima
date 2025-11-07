import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  // Retorna temperatura en Celsius como double
  Future<double> fetchTemperature(double lat, double lon) async {
    final url = Uri.parse('https://api.open-meteo.com/v1/forecast?latitude=6.2447&longitude=-75.5748&current=temperature'
        '?latitude=$lat&longitude=$lon&current=temperature');
        final response = await http.get(Uri.parse('https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature'
        ));

    print('Status code: ${response.statusCode}');
    print('Body: ${response.body}');
    


if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      if (json.containsKey('current') && json['current'] != null) {
        // La API devuelve current.temperature
        final current = json['current'] as Map<String, dynamic>;
        if (current.containsKey('temperature')) {
          return (current['temperature'] as num).toDouble();
        } else {
          throw Exception('No hay temperatura en la respuesta.');
        }
      } else {
        throw Exception('Respuesta sin campo current.');
      }
    } else {
      throw Exception('Error en la petición: ${response.statusCode}');
    }
  }
}
