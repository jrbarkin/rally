import 'dart:io';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future getQuery(String query) async {
  // Access your API key as an environment variable (see "Set up your API key" above)
  final apiKey = dotenv.env['API_KEY'];
  if (apiKey == null) {
    print('No \$API_KEY environment variable');
    exit(1);
  }
  // For text-only input, use the gemini-pro model
  final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
  final location = 'New York';
  final content = [Content.text(query + 'Get me events in $location this weekend. Respond textually, then include raw JSON specifying the event name, time, and street address.')];
  final response = await model.generateContent(content);
  print(response.text);

  // find json in response.text and convert it to JSON variable

  return response.text;

}
