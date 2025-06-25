import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cemungut_app/app/models/bank_sampah.dart';
import 'package:cemungut_app/app/services/firestore_service.dart';

class BankSampahScreen extends StatefulWidget {
  const BankSampahScreen({super.key});

  @override
  State<BankSampahScreen> createState() => _BankSampahScreenState();
}

class _BankSampahScreenState extends State<BankSampahScreen> {
  // Map and Loading State
  LatLng? _initialCenter;
  bool _isLoading = true;
  final MapController _mapController = MapController();

  // Search and Filtering State
  final SearchController _searchController = SearchController();
  List<BankSampah> _allWasteBanks = [];
  List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _initializeMap() async {
    final Position userPosition = await _determinePosition();
    _initialCenter = LatLng(userPosition.latitude, userPosition.longitude);

    // Fetch all banks and store them in our master list
    _allWasteBanks = await FirestoreService.getWasteBanks();
    _buildMarkersFromList(_allWasteBanks);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // This method builds the markers that are visible on the map
  void _buildMarkersFromList(List<BankSampah> banks) {
    _markers.clear();
    for (final bank in banks) {
      _markers.add(
        Marker(
          width: 50.0,
          height: 50.0,
          point: LatLng(bank.location.latitude, bank.location.longitude),
          child: GestureDetector(
            onTap: () => _onMarkerTapped(bank),
            child: Icon(
              Icons.location_on,
              color: Theme.of(context).primaryColor,
              size: 40,
            ),
          ),
        ),
      );
    }
  }

  // This helper function is called when a marker or a search result is tapped
  void _onMarkerTapped(BankSampah bank) {
    // Move the map to the selected location
    _mapController.move(
        LatLng(bank.location.latitude, bank.location.longitude), 15.0);
    // Show the details dialog
    _showMarkerDetailsDialog(bank);
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Position(
          latitude: -7.2575, longitude: 112.7521, timestamp: DateTime.now(),
          accuracy: 0, altitude: 0, altitudeAccuracy: 0, heading: 0, headingAccuracy: 0, speed: 0, speedAccuracy: 0);
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Position(
            latitude: -7.2575, longitude: 112.7521, timestamp: DateTime.now(),
            accuracy: 0, altitude: 0, altitudeAccuracy: 0, heading: 0, headingAccuracy: 0, speed: 0, speedAccuracy: 0);
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Position(
          latitude: -7.2575, longitude: 112.7521, timestamp: DateTime.now(),
          accuracy: 0, altitude: 0, altitudeAccuracy: 0, heading: 0, headingAccuracy: 0, speed: 0, speedAccuracy: 0);
    }

    return await Geolocator.getCurrentPosition();
  }

  void _showMarkerDetailsDialog(BankSampah bank) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(bank.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                if (bank.description.isNotEmpty) Text(bank.description),
                if (bank.description.isNotEmpty) const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Colors.black54),
                    const SizedBox(width: 8),
                    Text('Hari: ${bank.operationalDay}'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.black54),
                    const SizedBox(width: 8),
                    Text('Jam: ${bank.operationalTime}'),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Tutup'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Petunjuk Arah'),
              onPressed: () {
                Navigator.of(context).pop();
                _launchMapsUrl(bank.location.latitude, bank.location.longitude);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _launchMapsUrl(double latitude, double longitude) async {
    final Uri mapsUrl = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=...$latitude,$longitude'
    );

    if (await canLaunchUrl(mapsUrl)) {
      await launchUrl(mapsUrl);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka aplikasi peta.')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset('assets/CemBank.png', height: 32),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
      // The body is now a Column with the SearchAnchor on top
      // and the map filling the rest of the space.
          : Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialCenter!,
              initialZoom: 14.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
              ),
              MarkerLayer(markers: _markers),
              RichAttributionWidget(
                  showFlutterMapAttribution: false,
                  attributions: [
                    TextSourceAttribution('CARTO', onTap: () => launchUrl(Uri.parse('https://carto.com/attributions'))),
                    TextSourceAttribution('OpenStreetMap', onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright'))),
                  ]),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: SearchAnchor(
              shrinkWrap: true,
              isFullScreen: false,
              searchController: _searchController,
              // This builds the search bar you see initially
              builder: (BuildContext context, SearchController controller) {
                return SearchBar(
                  controller: controller,
                  hintText: 'Cari bank sampah...',
                  elevation: const WidgetStatePropertyAll(2.0),
                  onTap: () {
                    controller.openView();
                  },
                  // Open the view as soon as the user starts typing
                  onChanged: (_) {
                    if (!controller.isOpen) {
                      controller.openView();
                    }
                  },
                  leading: const Icon(Icons.search),
                );
              },
              // This builds the list of results when the search view is open
              suggestionsBuilder:
                  (BuildContext context, SearchController controller) {
                final query = controller.text.toLowerCase();
                final filteredList = _allWasteBanks.where((bank) {
                  return bank.name.toLowerCase().contains(query);
                }).toList();

                if (query.isNotEmpty && filteredList.isEmpty) {
                  return [const ListTile(title: Text('Tidak ada hasil ditemukan.'))];
                }

                return List<Widget>.generate(filteredList.length,
                        (int index) {
                      final bank = filteredList[index];
                      return ListTile(
                        title: Text(bank.name),
                        subtitle: Text(bank.operationalDay),
                        onTap: () {
                          setState(() {
                            // 1. Close the search view
                            controller.closeView(bank.name);
                            // 2. Unfocus the keyboard
                            FocusScope.of(context).unfocus();
                            // 3. Move map and show details
                            _onMarkerTapped(bank);
                          });
                        },
                      );
                    });
              },
            ),
          ),
        ],
      ),
    );
  }
}