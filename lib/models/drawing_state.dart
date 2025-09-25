import 'package:latlong2/latlong.dart';

enum DrawingStatus {
  idle,
  drawing,
  completed,
}

class DrawingState {
  final DrawingStatus status;
  final List<LatLng> currentPath;
  final DateTime? startTime;
  final bool isLoopClosed;
  
  const DrawingState({
    required this.status,
    required this.currentPath,
    this.startTime,
    this.isLoopClosed = false,
  });
  
  DrawingState.idle() : this(
    status: DrawingStatus.idle,
    currentPath: const [],
    startTime: null,
    isLoopClosed: false,
  );
  
  bool get isDrawing => status == DrawingStatus.drawing;
  
  bool get isIdle => status == DrawingStatus.idle;
  
  bool get hasPoints => currentPath.isNotEmpty;
  
  DrawingState copyWith({
    DrawingStatus? status,
    List<LatLng>? currentPath,
    DateTime? startTime,
    bool? isLoopClosed,
  }) {
    return DrawingState(
      status: status ?? this.status,
      currentPath: currentPath ?? this.currentPath,
      startTime: startTime ?? this.startTime,
      isLoopClosed: isLoopClosed ?? this.isLoopClosed,
    );
  }
}