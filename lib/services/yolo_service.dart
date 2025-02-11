import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class YOLOService {
  static WebSocketChannel connect() {
    return WebSocketChannel.connect(
      Uri.parse('ws://127.0.0.1:8000/ws/detect'),
    );
  }

  static void listen(
    WebSocketChannel channel, {
    required Function(String) onData,
    required Function(dynamic) onError,
    required Function() onDone,
  }) {
    channel.stream.listen(
      (event) => onData(event as String),
      onError: onError,
      onDone: onDone,
    );
  }

  static void sendImage(WebSocketChannel channel, List<int> bytes) {
    channel.sink.add(bytes);
  }

  static void close(WebSocketChannel channel) {
    channel.sink.close(status.goingAway);
  }
}
