import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cemungut_app/app/models/bank_sampah.dart';
import 'package:cemungut_app/app/services/firestore_service.dart';
import 'package:cemungut_app/app/services/geolocation_service.dart';

import '../../../app/services/geocoding_service.dart';

class BankSampahScreen extends StatefulWidget {
  const BankSampahScreen({super.key});

  @override
  State<BankSampahScreen> createState() => _BankSampahScreenState();
}

class _BankSampahScreenState extends State<BankSampahScreen> {
  LatLng? _initialCenter;
  final List<Marker> _markers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    // 2. Call the new service to get the user's position
    final Position userPosition = await GeolocationService.getCurrentPosition();

    _initialCenter = LatLng(userPosition.latitude, userPosition.longitude);

    await _loadWasteBankMarkers();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadWasteBankMarkers() async {
    // ... (This method remains the same)
    final List<BankSampah> wasteBanks = await FirestoreService.getWasteBanks();

    for (final bank in wasteBanks) {
      _markers.add(
        Marker(
          width: 50.0,
          height: 50.0,
          point: LatLng(bank.location.latitude, bank.location.longitude),
          child: GestureDetector(
            onTap: () => _showMarkerDetailsDialog(bank),
            child: Icon(
              Icons.location_on,
              color: Theme.of(context).colorScheme.primary,
              size: 40,
            ),
          ),
        ),
      );
    }
  }

  void _showMarkerDetailsDialog(BankSampah bank) {
    // ... (This method remains the same)
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
    // ... (This method remains the same)
    final Uri mapsUrl = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&daddr=');

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
    // ... (This method remains the same)
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset('assets/CemBank.png', height: 32),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
        options: MapOptions(
          initialCenter: _initialCenter!,
          initialZoom: 14.0,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c', 'd'],
            userAgentPackageName: 'com.cemungut.app',
          ),
          MarkerLayer(
            markers: _markers,
          ),
          RichAttributionWidget(
            showFlutterMapAttribution: false,
            attributions: [
              TextSourceAttribution(
                'CARTO',
                onTap: () =>
                    launchUrl(Uri.parse('https://carto.com/attributions')),
              ),
              TextSourceAttribution(
                'OpenStreetMap',
                onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}