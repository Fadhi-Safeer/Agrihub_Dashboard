import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class YOLOService {
  static Map<String, WebSocketChannel> _channels = {};

  static WebSocketChannel connect(String url) {
    if (!_channels.containsKey(url)) {
      _channels[url] = WebSocketChannel.connect(
        Uri.parse('ws://127.0.0.1:8000'),
      );
    }
    return _channels[url]!;
  }

  static void listen(
    WebSocketChannel channel, {
    required Function(String) onData,
    required Function(dynamic) onError,
    required Function() onDone,
  }) {
    channel.stream.listen(
      (event) {
        final message = event as String;
        onData(message);
      },
      onError: onError,
      onDone: onDone,
    );
  }

  static void sendURL(WebSocketChannel channel, String url) {
    print('Sending URL to backend...');
    final jsonMessage = jsonEncode({'url': url});
    channel.sink.add(jsonMessage);
  }

  static void close(String url) {
    if (_channels.containsKey(url)) {
      _channels[url]!.sink.close(status.goingAway);
      _channels.remove(url);
    }
  }
}
