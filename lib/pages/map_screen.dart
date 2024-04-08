import 'package:flutter/material.dart';
import '../services/gemini.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  Set<Marker> markers = Set();
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Where would you like to go?',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _searchAddresses(searchController.text);
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                    37.7749, -122.4194), // Initial position (San Francisco)
                zoom: 12,
              ),
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
              markers: markers,
            ),
          ),
        ],
      ),
    );
  }

Future<void> _searchAddresses(String query) async {
  try {
    // Call getQuery function to fetch location information
    List<GeminiResult> results = await getQuery(query);

    List<String> addresses = results.map((result) => result.address).toList();
    print("Addresses: $addresses");

    // Update markers with the fetched addresses
    _updateMarkers(addresses);
  } catch (e) {
    // Handle errors
    print('Error: $e');
  }
}

void _updateMarkers(List<String> addresses) {
  // Clear existing markers
  markers.clear();

  // Add new markers for the addresses
  for (String address in addresses) {
    // Perform geocoding or use mock coordinates
    // generate random lat and lng

    double lat = 37.7749;
    double lng = -122.4194;

    Marker marker = Marker(
      markerId: MarkerId(address),
      position: LatLng(lat, lng),
      infoWindow: InfoWindow(
        title: 'ADDRESS IS:',//geminiResult.name, // Use the name from Gemini result
        snippet: address, // Address as snippet
      ),
      onTap: () {
        // Handle marker tap if needed
        // For example, you can open a bottom sheet with more details
        // _showLocationDetails(address);
      },
    );

    markers.add(marker);
  }

  // Update the UI to display the markers
  setState(() {});
}
}
