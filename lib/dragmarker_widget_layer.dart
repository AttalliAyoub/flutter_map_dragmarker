import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/plugin_api.dart';

import 'dragmarker.dart';

class DragMarkerPluginOptions extends LayerOptions {
  final List<DragMarker> markers;

  DragMarkerPluginOptions({this.markers = const [], rebuild})
      : super(rebuild: rebuild);
}

class DragMarkerPlugin implements MapPlugin {
  @override
  Widget createLayer(options, mapState, stream) {
    return StreamBuilder(
      stream: stream,
      builder: (context, snapshot) {
        if (options is DragMarkerPluginOptions) {
          var dragMarkers = <Widget>[];
          for (var marker in options.markers) {
            if (!_boundsContainsMarker(mapState, marker)) continue;
            dragMarkers.add(
              DragMarkerWidget(
                mapState: mapState,
                marker: marker,
                stream: stream,
                options: options,
              ),
            );
          }
          return Container(
            child: Stack(children: dragMarkers),
          );
        }

        throw Exception('Unknown options type for DragMarkerPlugin: $options');
      },
    );
  }

  @override
  bool supportsLayer(LayerOptions options) {
    return options is DragMarkerPluginOptions;
  }

  static bool _boundsContainsMarker(MapState map, DragMarker marker) {
    var pixelPoint = map.project(marker.point);

    final width = marker.width - marker.anchor.left;
    final height = marker.height - marker.anchor.top;

    var sw = CustomPoint(pixelPoint.x + width, pixelPoint.y - height);
    var ne = CustomPoint(pixelPoint.x - width, pixelPoint.y + height);

    return map.pixelBounds.containsPartialBounds(Bounds(sw, ne));
  }
}
