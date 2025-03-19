import 'dart:convert';
import 'dart:typed_data';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

class YOLOService {
  static WebSocketChannel connect() {
    // Replace with your WebSocket server URL
    final url = 'ws://your-backend-url/socket';
    return IOWebSocketChannel.connect(url);
  }

  static void listen(
    WebSocketChannel channel, {
    required Function(dynamic) onData,
    required Function(dynamic) onError,
    required Function() onDone,
  }) {
    channel.stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
    );
  }

  static void sendImage(WebSocketChannel channel, Uint8List image) {
    try {
      // Convert the image to base64 for sending over WebSocket
      final base64Image = base64Encode(image);
      channel.sink.add(base64Image);
      print('Image sent to backend.');
    } catch (e) {
      print('Error sending image: $e');
    }
  }

  static void close(WebSocketChannel channel) {
    channel.sink.close();
  }
}
