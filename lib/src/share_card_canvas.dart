import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

/// Renders any Flutter widget tree to a PNG byte buffer at a given
/// size, fully off-screen. Used by every game's share-card path.
class ShareCardCanvas {
  /// Capture [content] as a PNG of [size] logical pixels at
  /// [pixelRatio] device-pixel density. Lifts the widget into a
  /// synthetic pipeline owner so it doesn't appear on-screen.
  static Future<Uint8List> renderToPng({
    required Widget content,
    required Size size,
    double pixelRatio = 1.0,
    Color background = const Color(0xFF000000),
  }) async {
    final repaintBoundary = RenderRepaintBoundary();
    final view = WidgetsBinding.instance.platformDispatcher.views.first;

    final renderView = RenderView(
      view: view,
      child: RenderPositionedBox(
        alignment: Alignment.center,
        child: repaintBoundary,
      ),
      configuration: ViewConfiguration(
        physicalConstraints: BoxConstraints.tight(size * pixelRatio),
        logicalConstraints: BoxConstraints.tight(size),
        devicePixelRatio: pixelRatio,
      ),
    );

    final pipelineOwner = PipelineOwner();
    final buildOwner = BuildOwner(focusManager: FocusManager());
    pipelineOwner.rootNode = renderView;
    renderView.prepareInitialFrame();

    final rootElement = RenderObjectToWidgetAdapter<RenderBox>(
      container: repaintBoundary,
      child: ColoredBox(
        color: background,
        child: SizedBox.fromSize(
          size: size,
          child: MediaQuery(
            data: MediaQueryData(size: size, devicePixelRatio: pixelRatio),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: content,
            ),
          ),
        ),
      ),
    ).attachToRenderTree(buildOwner);

    buildOwner.buildScope(rootElement);
    buildOwner.finalizeTree();
    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();

    final image = await repaintBoundary.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();

    if (byteData == null) {
      throw StateError('ShareCardCanvas: toByteData returned null');
    }
    return byteData.buffer.asUint8List();
  }

  /// Convenience: schedule the capture on the next frame so inherited
  /// theme/text-style data is fully available.
  static Future<Uint8List> renderInNextFrame({
    required Widget content,
    required Size size,
    double pixelRatio = 1.0,
    Color background = const Color(0xFF000000),
  }) {
    final completer = Completer<Uint8List>();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      try {
        final bytes = await renderToPng(
          content: content,
          size: size,
          pixelRatio: pixelRatio,
          background: background,
        );
        completer.complete(bytes);
      } catch (e, st) {
        completer.completeError(e, st);
      }
    });
    return completer.future;
  }
}
