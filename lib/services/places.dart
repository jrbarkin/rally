import 'dart:convert';
import 'package:http/http.dart' as http;


Future<Map<String, double>> getCoordinatesFromAddress(String address, String apiKey) async {
  final url = Uri.parse('https://maps.googleapis.com/maps/api/geocode/json?address=$address&key=$apiKey');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);

    if (jsonResponse['results'] == null || jsonResponse['results'].length == 0) {
      throw Exception('Address not found');
    }

    final location = jsonResponse['results'][0]['geometry']['location'];
    return {
      'latitude': location['lat'],
      'longitude': location['lng'],
    };
  } else {
    throw Exception('Failed to load coordinates');
  }
}
