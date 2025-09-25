import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/drawing_state.dart';
import '../utils/geometry_utils.dart';

class DrawingMap extends StatefulWidget {
  const DrawingMap({super.key});

  @override
  State<DrawingMap> createState() => _DrawingMapState();
}

class _DrawingMapState extends State<DrawingMap> {
  final MapController _mapController = MapController();
  DrawingState _drawingState = DrawingState.idle();
  
  // Loop closure threshold in meters
  // static const double _loopClosureThreshold = 150.0; // No longer needed - auto-close all loops
  
  // Track if user is actually dragging (not just tapping)
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: LatLng(51.509364, -0.128928),
          initialZoom: 9.2,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.none,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.map_gesture_loop',
          ),
          PolylineLayer(
            polylines: [
              if (_drawingState.hasPoints)
                Polyline(
                  points: _drawingState.isLoopClosed 
                    ? [..._drawingState.currentPath, _drawingState.currentPath.first] // Add closing line
                    : _drawingState.currentPath,
                  strokeWidth: 3.0,
                  color: Colors.blue,
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    _isDragging = false; // Reset dragging flag
    final latLng = GeometryUtils.screenToLatLng(details.localPosition, _mapController, context);
    if (latLng == null) return;
    
    print('PanStart - Screen: ${details.localPosition}, LatLng: ${latLng.latitude}, ${latLng.longitude}');
    setState(() {
      _drawingState = DrawingState(
        status: DrawingStatus.drawing,
        currentPath: [latLng],
        startTime: DateTime.now(),
      );
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _isDragging = true; // User is actually dragging
    if (_drawingState.isDrawing) {
      final latLng = GeometryUtils.screenToLatLng(details.localPosition, _mapController, context);
      if (latLng == null) return;
      
      print('PanUpdate - Screen: ${details.localPosition}, LatLng: ${latLng.latitude}, ${latLng.longitude}');
      
      // Check for loop closure if we have enough points
      // bool isLoopClosed = false;
      // if (_drawingState.currentPath.length > 2) {
      //   final startPoint = _drawingState.currentPath.first;
      //   final distanceToStart = GeometryUtils.calculateDistance(startPoint, latLng);
      //   isLoopClosed = distanceToStart < _loopClosureThreshold;
      //   
      //   if (isLoopClosed) {
      //     print('Loop closure detected! Distance to start: ${distanceToStart.toStringAsFixed(2)}m');
      //   }
      // }
      
      setState(() {
        _drawingState = _drawingState.copyWith(
          currentPath: [..._drawingState.currentPath, latLng],
          // isLoopClosed: isLoopClosed, // Will be set to true in _onPanEnd
        );
      });
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (_drawingState.isDrawing) {
      // If user didn't drag, treat it as a tap
      if (!_isDragging) {
        final latLng = _drawingState.currentPath.first;
        print('Tap detected at: ${latLng.latitude}, ${latLng.longitude}');
        // Reset drawing state since this was just a tap
        setState(() {
          _drawingState = DrawingState.idle();
        });
        return;
      }
      
      // Always close the loop when drawing finishes
      print('Drawing completed - auto-closing loop!');
      
      setState(() {
        _drawingState = _drawingState.copyWith(
          status: DrawingStatus.completed,
          isLoopClosed: true, // Always mark as closed
        );
      });
    }
  }
}