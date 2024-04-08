import 'package:flutter/material.dart';
import '../services/gemini.dart';
import '../services/places.dart';

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
  Widget build(BuildContext   ) {
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
                hintText: 'Explore with Gemini...',
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
      _updateMarkers(results);
      _showBottomSheet(results); // Show bottom sheet with results
    } catch (e) {
      // Handle errors
      print('Error: $e');
    }
  }

  Future<void> _updateMarkers(List<GeminiResult> results) async {
    // Clear existing markers
    markers.clear();

    // Add new markers for the addresses
    for (GeminiResult result in results) {
      try {
        // Get coordinates from the address
        Map<String, double?> coordinates =
            await getCoordinatesFromAddress(result.address);

        double? lat = coordinates['latitude'];
        double? lng = coordinates['longitude'];

        if (lat != null && lng != null) {
          // Set lat and lng for the result
          result.lat = lat;
          result.lng = lng;

          Marker marker = Marker(
            markerId: MarkerId(result.address),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(
              title: result
                  .name, // You can replace this with a more meaningful title
              snippet: result.address, // Address as snippet
            ),
            onTap: () {
              // Handle marker tap if needed
              // For example, you can open a bottom sheet with more details
              // _showLocationDetails(address);
            },
          );

          markers.add(marker);
        } else {
          // Handle the case where latitude or longitude is null
          // For example, log an error or show a message to the user
          print('Coordinates not found for address: $result.address');
        }
      } catch (e, stacktrace) {
        print('Error occurred while fetching coordinates: $e, $stacktrace');
        // Optionally handle the error, e.g., show a message to the user
      }
    }

    // Update the UI to display the markers
    setState(() {});
  }

  void _showBottomSheet(List<GeminiResult> results) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize:
              0.3, // The initial size of the sheet while minimized
          minChildSize: 0.1, // The minimum size of the sheet (when minimized)
          maxChildSize:
              1.0, // The maximum size of the sheet (when fully expanded)
          expand: false,
          builder: (BuildContext context, ScrollController scrollController) {
            return ListView.builder(
              controller: scrollController,
              itemCount: results.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(results[index].name),
                  onTap: () {
                    if (results[index].lat != null &&
                        results[index].lng != null) {
                      mapController.animateCamera(
                        CameraUpdate.newLatLngZoom(
                          LatLng(results[index].lat!, results[index].lng!),
                          15,
                        ),
                      );
                      Navigator.pop(context); // Close the bottom sheet
                    }
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
