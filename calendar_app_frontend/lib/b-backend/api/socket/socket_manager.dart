// lib/d-socket/socket_manager.dart
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketManager {
  static final SocketManager _instance = SocketManager._internal();
  factory SocketManager() => _instance;
  late IO.Socket socket;

  SocketManager._internal();

  void connect(String userToken) {
    socket = IO.io('http://192.168.1.16:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'extraHeaders': {
        'Authorization': 'Bearer $userToken',
      }
    });

    socket.onConnect((_) {
      print("✅ Socket connected");

      // Optional: Listen for all events (for debugging)
      socket.onAny((event, data) {
        print("📥 Received event: $event with data: $data");
      });
    });

    socket.onDisconnect((_) => print("🔌 Socket disconnected"));
    socket.onError((err) => print("❌ Socket error: $err"));
  }

  void on(String event, Function(dynamic) handler) {
    socket.on(event, handler);
  }

  void disconnect() {
    socket.disconnect();
  }

  /// ✅ Call this after socket connection and after user + group are available
  void emitUserJoin({
    required String userId,
    required String userName,
    required String groupId,
    required String? photoUrl,
  }) {
    socket.emit("user:join", {
      "userId": userId,
      "userName": userName,
      "groupId": groupId,
      "photoUrl": photoUrl,
    });

    print("📡 Emitted user:join for $userName ($userId)");
  }
}
