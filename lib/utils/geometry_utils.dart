import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class GeometryUtils {
  static LatLng? screenToLatLng(
    Offset screenPosition,
    MapController mapController,
    BuildContext context,
  ) {
    final mapState = mapController.camera;
    // if (mapState == null) return null;
    
    return mapState.offsetToCrs(screenPosition);
  }
  
  static List<LatLng> screenPointsToLatLngs(
    List<Offset> screenPoints,
    MapController mapController,
    BuildContext context,
  ) {
    return screenPoints
        .map((point) => screenToLatLng(point, mapController, context))
        .where((latLng) => latLng != null)
        .cast<LatLng>()
        .toList();
  }
  
  static Offset? latLngToScreen(
    LatLng latLng,
    MapController mapController,
    BuildContext context,
  ) {
    final mapState = mapController.camera;
    
    return mapState.project(latLng).toOffset();
  }
  
  static double calculateDistance(LatLng point1, LatLng point2) {
    const distance = Distance();
    return distance.as(LengthUnit.Meter, point1, point2);
  }
  
  static bool isPointInPolygon(LatLng point, List<LatLng> polygon) {
    if (polygon.length < 3) return false;
    
    int intersections = 0;
    for (int i = 0; i < polygon.length; i++) {
      final j = (i + 1) % polygon.length;
      
      if (_rayIntersectsSegment(point, polygon[i], polygon[j])) {
        intersections++;
      }
    }
    
    return intersections % 2 == 1;
  }
  
  static bool _rayIntersectsSegment(LatLng point, LatLng segStart, LatLng segEnd) {
    if (segStart.latitude > point.latitude == segEnd.latitude > point.latitude) {
      return false;
    }
    
    final intersectionLng = (segEnd.longitude - segStart.longitude) *
            (point.latitude - segStart.latitude) /
            (segEnd.latitude - segStart.latitude) +
        segStart.longitude;
    
    return point.longitude < intersectionLng;
  }
  
  static LatLng getCenterPoint(List<LatLng> points) {
    if (points.isEmpty) {
      throw ArgumentError('Points list cannot be empty');
    }
    
    double latSum = 0;
    double lngSum = 0;
    
    for (final point in points) {
      latSum += point.latitude;
      lngSum += point.longitude;
    }
    
    return LatLng(latSum / points.length, lngSum / points.length);
  }
  
  static bool isValidLoop(List<LatLng> points, {double minPointDistance = 10.0}) {
    if (points.length < 3) return false;
    
    for (int i = 0; i < points.length - 1; i++) {
      final distance = calculateDistance(points[i], points[i + 1]);
      if (distance < minPointDistance) {
        return false;
      }
    }
    
    final startEndDistance = calculateDistance(points.first, points.last);
    return startEndDistance < minPointDistance * 2;
  }
}