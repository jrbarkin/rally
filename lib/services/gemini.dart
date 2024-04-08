import 'dart:io';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class GeminiResult {
  final String name;
  final String address;
  double? lat; // Nullable and non-final latitude
  double? lng; // Nullable and non-final longitude

  GeminiResult(this.name, this.address);

  GeminiResult.fromJson(Map<String, dynamic> json)
      : name = json['name'] as String,
        address = json['address'] as String;

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': address,
      };
}

Future<List<GeminiResult>> getQuery(String query) async {
  // Access your API key as an environment variable (see "Set up your API key" above)
  final apiKey = dotenv.env['API_KEY'];
  if (apiKey == null) {
    print('No \$API_KEY environment variable');
    exit(1);
  }
  // For text-only input, use the gemini-pro model
  final model = GenerativeModel(model: 'gemini-1.0-pro', apiKey: apiKey);
  // create const to ask for  JSON from gemini
  const jsonRequest = '. Respond via JSON, specifying the location name and street address in the form of a JSON object. For example, {"name": "Crazy Tacos", "address": "123 Main St., San Francisco, CA 94111"}';
  final content = [Content.text(query + jsonRequest)];
  final response = await model.generateContent(content);
  final responseText = response.text;
  print("Response: $responseText");

  RegExp exp = RegExp(r"```(.*?)```", dotAll: true);
  Iterable<RegExpMatch> matches = exp.allMatches(responseText!);

  // cast matches to string
  String originalString = matches.first.group(1).toString();
  print("Original String: $originalString");

  String formattedString = originalString.replaceFirst(RegExp('JSON|json'), '');
  print("Formatted String: $formattedString");

    // Parse the JSON string
  var jsonList = jsonDecode(formattedString) as List;

  // Create a list of GeminiResult objects
  List<GeminiResult> geminiResultsList = jsonList.map((item) => GeminiResult.fromJson(item)).toList();

  return geminiResultsList;

}
