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
                target: LatLng(37.7749, -122.4194), // Initial position (San Francisco)
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
      List<String> addresses = await getQuery(query);
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
      double lat = 37.7749;
      double lng = -122.4194;

      Marker marker = Marker(
        markerId: MarkerId(address),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(title: address),
      );

      markers.add(marker);
    }

    // Update the UI to display the markers
    setState(() {});
  }
}