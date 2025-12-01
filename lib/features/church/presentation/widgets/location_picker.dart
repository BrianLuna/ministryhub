import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:ministryhub/ministryhub.dart';

/// Widget for picking a location using Google Places autocomplete and map
class LocationPicker extends StatefulWidget {
  const LocationPicker({
    required this.initialLocation,
    required this.onLocationSelected,
    super.key,
  });

  final Location? initialLocation;
  final ValueChanged<Location> onLocationSelected;

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  final _searchController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 500);
  final _mapControllerCompleter = Completer<GoogleMapController>();

  List<PlacePrediction> _predictions = [];
  bool _isLoadingPredictions = false;
  Location? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
    if (_selectedLocation != null) {
      _searchController.text = _selectedLocation!.address;
    }
  }

  String get _apiKey => GoogleMapsConfig.apiKey;

  @override
  void dispose() {
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  Future<void> _searchPlaces(String query) async {
    if (query.isEmpty || query.length < 3) {
      setState(() {
        _predictions = [];
      });
      return;
    }

    setState(() {
      _isLoadingPredictions = true;
    });

    try {
      final apiKey = _apiKey;
      if (apiKey.isEmpty) {
        setState(() {
          _predictions = [];
          _isLoadingPredictions = false;
        });
        return;
      }

      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json'
        '?input=$query'
        '&key=$apiKey'
        '&types=establishment|geocode',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final predictions = (data['predictions'] as List)
              .map((p) => PlacePrediction.fromJson(p))
              .toList();
          setState(() {
            _predictions = predictions;
            _isLoadingPredictions = false;
          });
        } else {
          setState(() {
            _predictions = [];
            _isLoadingPredictions = false;
          });
        }
      } else {
        setState(() {
          _predictions = [];
          _isLoadingPredictions = false;
        });
      }
    } catch (e) {
      setState(() {
        _predictions = [];
        _isLoadingPredictions = false;
      });
    }
  }

  Future<void> _selectPlace(PlacePrediction prediction) async {
    setState(() {
      _isLoadingPredictions = true;
      _predictions = [];
    });

    try {
      final apiKey = _apiKey;
      if (apiKey.isEmpty) {
        return;
      }

      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json'
        '?place_id=${prediction.placeId}'
        '&key=$apiKey'
        '&fields=geometry,formatted_address,place_id',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final result = data['result'];
          final geometry = result['geometry'];
          final location = geometry['location'];
          final lat = location['lat'] as double;
          final lng = location['lng'] as double;
          final address = result['formatted_address'] as String;
          final placeId = result['place_id'] as String;

          final selectedLocation = Location(
            address: address,
            latitude: lat,
            longitude: lng,
            placeId: placeId,
          );

          setState(() {
            _selectedLocation = selectedLocation;
            _searchController.text = address;
            _isLoadingPredictions = false;
          });

          // Move map to selected location
          final controller = await _mapControllerCompleter.future;
          await controller.animateCamera(
            CameraUpdate.newLatLng(LatLng(lat, lng)),
          );

          widget.onLocationSelected(selectedLocation);
        }
      }
    } catch (e) {
      setState(() {
        _isLoadingPredictions = false;
      });
    }
  }

  Future<void> _onMapTap(LatLng position) async {
    try {
      final apiKey = _apiKey;
      if (apiKey.isEmpty) {
        return;
      }

      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json'
        '?latlng=${position.latitude},${position.longitude}'
        '&key=$apiKey',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final result = data['results'][0];
          final address = result['formatted_address'] as String;
          final placeId = result['place_id'] as String?;

          final selectedLocation = Location(
            address: address,
            latitude: position.latitude,
            longitude: position.longitude,
            placeId: placeId,
          );

          setState(() {
            _selectedLocation = selectedLocation;
            _searchController.text = address;
          });

          widget.onLocationSelected(selectedLocation);
        }
      }
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Search field
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            labelText: l10n.churchLocationSearchLabel,
            hintText: l10n.churchLocationSearchHint,
            suffixIcon: _isLoadingPredictions
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : const Icon(Icons.search),
          ),
          onChanged: (value) {
            _debouncer.run(() => _searchPlaces(value));
          },
        ),
        // Predictions list
        if (_predictions.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withAlpha(26),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _predictions.length,
              itemBuilder: (context, index) {
                final prediction = _predictions[index];
                return ListTile(
                  leading: const Icon(Icons.location_on),
                  title: Text(prediction.mainText),
                  subtitle: Text(prediction.secondaryText),
                  onTap: () => _selectPlace(prediction),
                );
              },
            ),
          ),
        const SizedBox(height: 16),
        // Map
        SizedBox(
          height: 300,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _selectedLocation != null
                    ? LatLng(
                        _selectedLocation!.latitude,
                        _selectedLocation!.longitude,
                      )
                    : const LatLng(0, 0), // Default location
                zoom: _selectedLocation != null ? 15 : 2,
              ),
              onMapCreated: (controller) {
                _mapControllerCompleter.complete(controller);
              },
              onTap: _onMapTap,
              markers: _selectedLocation != null
                  ? {
                      Marker(
                        markerId: const MarkerId('selected_location'),
                        position: LatLng(
                          _selectedLocation!.latitude,
                          _selectedLocation!.longitude,
                        ),
                        draggable: true,
                        onDragEnd: (position) => _onMapTap(position),
                      ),
                    }
                  : {},
              myLocationButtonEnabled: true,
              mapType: MapType.normal,
            ),
          ),
        ),
      ],
    );
  }
}

/// Helper class for debouncing
class Debouncer {
  Debouncer({required this.milliseconds});

  final int milliseconds;
  Timer? _timer;

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}

/// Place prediction from Google Places API
class PlacePrediction {
  PlacePrediction({
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
  });

  final String placeId;
  final String mainText;
  final String secondaryText;

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    final structuredFormatting =
        json['structured_formatting'] as Map<String, dynamic>;
    return PlacePrediction(
      placeId: json['place_id'] as String,
      mainText: structuredFormatting['main_text'] as String,
      secondaryText: structuredFormatting['secondary_text'] as String? ?? '',
    );
  }
}
