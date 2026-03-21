import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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
  final ValueChanged<Location?> onLocationSelected;

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  final _searchController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 500);
  GoogleMapController? _mapController;

  List<PlacePrediction> _predictions = [];
  bool _isLoadingPredictions = false;
  Location? _selectedLocation;
  String? _selectedPlaceName;
  Position? _currentPosition;
  bool _isRequestingLocation = false;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
    if (_selectedLocation != null) {
      _searchController.text = _selectedLocation!.address;
    }
    _initCurrentLocation();
  }

  /// Places API (New) key, independent from platform-specific Maps SDK keys
  String get _apiKey => GoogleMapsConfig.placesKey;

  @override
  void dispose() {
    // Clear map controller reference - the framework will handle cleanup
    _mapController = null;
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  Future<void> _initCurrentLocation() async {
    if (_isRequestingLocation) {
      return;
    }
    _isRequestingLocation = true;
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
    } catch (_) {
      // If location is not available we simply don't bias the results
    } finally {
      _isRequestingLocation = false;
    }
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

      // Use Places API (New) autocomplete endpoint
      final url = Uri.parse(
        'https://places.googleapis.com/v1/places:autocomplete',
      );

      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          // API key must be sent via header for Places API (New)
          'X-Goog-Api-Key': apiKey,
          // Request suggestions with full placePrediction payload
          // (we luego filtramos lo que necesitamos en el cliente)
          'X-Goog-FieldMask': 'suggestions.placePrediction',
        },
        body: json.encode(<String, dynamic>{
          'input': query,
          if (_currentPosition != null)
            'locationBias': {
              'circle': {
                'center': {
                  'latitude': _currentPosition!.latitude,
                  'longitude': _currentPosition!.longitude,
                },
                // 5km radius bias around current location
                'radius': 5000,
              },
            },
        }),
      );

      if (kDebugMode) {
        debugPrint(
          'Places autocomplete response: '
          '${response.statusCode} ${response.body}',
        );
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final rawSuggestions = data['suggestions'] as List<dynamic>? ?? [];
        final predictions = rawSuggestions
            .map(
              (s) => PlacePrediction.fromPlacesAutocomplete(
                s as Map<String, dynamic>,
              ),
            )
            .where((p) => p.placeId.isNotEmpty)
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

      // Ensure placeId has the 'places/' prefix for the API call
      final resourceName = prediction.placeId.startsWith('places/')
          ? prediction.placeId
          : 'places/${prediction.placeId}';

      // Use Places API (New) place details endpoint
      final url = Uri.parse('https://places.googleapis.com/v1/$resourceName');

      final response = await http.get(
        url,
        headers: <String, String>{
          // API key must be sent via header for Places API (New)
          'X-Goog-Api-Key': apiKey,
          // We only need formattedAddress and location
          'X-Goog-FieldMask': 'formattedAddress,location',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final address = data['formattedAddress'] as String?;
        final location = data['location'] as Map<String, dynamic>?;
        final lat = location?['latitude'] as double?;
        final lng = location?['longitude'] as double?;

        if (address != null && lat != null && lng != null) {
          final selectedLocation = Location(
            address: address,
            latitude: lat,
            longitude: lng,
            placeId: prediction.placeId,
          );

          setState(() {
            _selectedLocation = selectedLocation;
            _searchController.text = address;
            _isLoadingPredictions = false;
          });

          // Notify parent so the dialog can capture the selected location
          widget.onLocationSelected(selectedLocation);

          // Move map to selected location after it's created
          if (mounted && _mapController != null) {
            try {
              _mapController!.animateCamera(
                CameraUpdate.newLatLng(LatLng(lat, lng)),
              );
            } catch (e) {
              // Map controller may have been disposed
              debugPrint('LocationPicker: Error animating camera: $e');
            }
          }
        } else {
          debugPrint('LocationPicker: Invalid details data: $data');
          setState(() {
            _isLoadingPredictions = false;
          });
        }
      } else {
        debugPrint(
          'LocationPicker: Place details error: ${response.statusCode} ${response.body}',
        );
        setState(() {
          _isLoadingPredictions = false;
        });
      }
    } catch (e) {
      debugPrint('LocationPicker: Error selecting place: $e');
      setState(() {
        _isLoadingPredictions = false;
      });
    }
  }

  @override
  void didUpdateWidget(LocationPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialLocation != oldWidget.initialLocation) {
      setState(() {
        _selectedLocation = widget.initialLocation;
        if (_selectedLocation != null) {
          _searchController.text = _selectedLocation!.address;
          // Only animate camera if widget is still mounted and controller exists
          if (mounted && _mapController != null) {
            try {
              _mapController!.animateCamera(
                CameraUpdate.newLatLng(
                  LatLng(
                    _selectedLocation!.latitude,
                    _selectedLocation!.longitude,
                  ),
                ),
              );
            } catch (e) {
              // Map controller may have been disposed
              debugPrint(
                'LocationPicker: Error animating camera in didUpdateWidget: $e',
              );
            }
          }
        }
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

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search field
          TextField(
            controller: _searchController,
            keyboardType: TextInputType.streetAddress,
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
                  : _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _predictions = [];
                          _selectedLocation = null;
                          _selectedPlaceName = null;
                        });
                        // Notify parent that location was cleared
                        widget.onLocationSelected(null);
                      },
                    )
                  : const Icon(Icons.search),
            ),
            onChanged: (value) {
              setState(() {});
              _debouncer.run(() => _searchPlaces(value));
            },
          ),
          // Predictions list
          if (_predictions.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
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
              child: SingleChildScrollView(
                child: Column(
                  children: _predictions
                      .map(
                        (prediction) => ListTile(
                          leading: const Icon(Icons.location_on),
                          title: Text(prediction.mainText),
                          subtitle: Text(prediction.secondaryText),
                          onTap: () => _selectPlace(prediction),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          const SizedBox(height: 16),
          // Map (only visible after a location is selected)
          if (_selectedLocation != null)
            SizedBox(
              height: 300,
              width: double.infinity,
              child: GoogleMap(
                key: ValueKey(
                  'map_${_selectedLocation!.latitude}_${_selectedLocation!.longitude}',
                ),
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    _selectedLocation!.latitude,
                    _selectedLocation!.longitude,
                  ),
                  zoom: 15,
                ),
                onMapCreated: (controller) {
                  if (!mounted) {
                    return;
                  }
                  _mapController = controller;
                  // Force map to update after creation
                  Future.delayed(const Duration(milliseconds: 300), () {
                    if (mounted && _mapController != null) {
                      try {
                        _mapController!.animateCamera(
                          CameraUpdate.newLatLngZoom(
                            LatLng(
                              _selectedLocation!.latitude,
                              _selectedLocation!.longitude,
                            ),
                            15,
                          ),
                        );
                      } catch (e) {
                        // Map controller may have been disposed
                        debugPrint(
                          'LocationPicker: Error animating camera in onMapCreated: $e',
                        );
                      }
                    }
                  });
                },
                onTap: _onMapTap,
                markers: {
                  Marker(
                    markerId: const MarkerId('selected_location'),
                    position: LatLng(
                      _selectedLocation!.latitude,
                      _selectedLocation!.longitude,
                    ),
                    infoWindow: InfoWindow(
                      title: _selectedPlaceName ?? _selectedLocation!.address,
                      snippet: _selectedLocation!.address,
                    ),
                    draggable: true,
                    onDragEnd: (position) => _onMapTap(position),
                  ),
                },
                myLocationButtonEnabled: false,
                mapType: MapType.normal,
                zoomControlsEnabled: true,
                zoomGesturesEnabled: true,
                scrollGesturesEnabled: true,
                tiltGesturesEnabled: true,
                rotateGesturesEnabled: true,
                compassEnabled: true,
                mapToolbarEnabled: false,
              ),
            ),
        ],
      ),
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

  /// Resource name of the place in Places API (New), e.g. `places/ChIJ...`
  final String placeId;

  /// Main text to display in the autocomplete list
  final String mainText;

  /// Secondary text (usually formatted address)
  final String secondaryText;

  /// Build a prediction from Places API (New) autocomplete response
  factory PlacePrediction.fromPlacesAutocomplete(Map<String, dynamic> json) {
    final placePrediction =
        json['placePrediction'] as Map<String, dynamic>? ?? <String, dynamic>{};

    // Resource name and ID for Places API (New)
    final placeResourceName = placePrediction['place'] as String? ?? '';
    final placeId = placePrediction['placeId'] as String? ?? placeResourceName;

    // Structured text for display
    final structuredFormat =
        placePrediction['structuredFormat'] as Map<String, dynamic>? ??
        <String, dynamic>{};
    final mainTextMap =
        structuredFormat['mainText'] as Map<String, dynamic>? ??
        <String, dynamic>{};
    final secondaryTextMap =
        structuredFormat['secondaryText'] as Map<String, dynamic>? ??
        <String, dynamic>{};

    final mainText = mainTextMap['text'] as String? ?? '';
    final secondaryText = secondaryTextMap['text'] as String? ?? '';

    return PlacePrediction(
      placeId: placeId,
      mainText: mainText,
      secondaryText: secondaryText,
    );
  }
}
