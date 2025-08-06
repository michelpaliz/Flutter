import 'package:calendar_app_frontend/b-backend/api/config/api_rotues.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketManager {
  static final SocketManager _instance = SocketManager._internal();
  factory SocketManager() => _instance;

  late IO.Socket socket;

  // ✅ Type-safe listener registry
  final Map<String, void Function(dynamic)> _registeredHandlers = {};

  SocketManager._internal();

  // /// Connect to socket server with user token
  // void connect(String userToken) {
  //   socket = IO.io('http://192.168.1.16:3000', <String, dynamic>{
  //     'transports': ['websocket'],
  //     'autoConnect': true,
  //     'extraHeaders': {
  //       'Authorization': 'Bearer $userToken',
  //     }
  //   });

  //   socket.onConnect((_) {
  //     print("✅ Socket connected");

  //     // Optional: debug log all events
  //     socket.onAny((event, data) {
  //       print("📥 Received event: $event with data: $data");
  //     });
  //   });

  //   socket.onDisconnect((_) => print("🔌 Socket disconnected"));
  //   socket.onError((err) => print("❌ Socket error: $err"));
  // }

  void connect(String userToken) {
    final socketUrl = ApiConstants.baseUrl.replaceFirst('/api', '');

    socket = IO.io(socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'extraHeaders': {
        'Authorization': 'Bearer $userToken',
      }
    });

    socket.onConnect((_) {
      print("✅ Socket connected");

      // Optional: debug log all events
      socket.onAny((event, data) {
        print("📥 Received event: $event with data: $data");
      });
    });

    socket.onDisconnect((_) => print("🔌 Socket disconnected"));
    socket.onError((err) => print("❌ Socket error: $err"));
  }

  /// Register an event listener with deduplication
  void on(String event, void Function(dynamic) handler) {
    // Remove existing handler to avoid duplication
    if (_registeredHandlers.containsKey(event)) {
      socket.off(event, _registeredHandlers[event]);
    }

    _registeredHandlers[event] = handler;
    socket.on(event, handler);
  }

  /// Unregister a specific event listener
  void off(String event) {
    if (_registeredHandlers.containsKey(event)) {
      socket.off(event, _registeredHandlers[event]);
      _registeredHandlers.remove(event);
    }
  }

  /// Disconnect the socket
  void disconnect() {
    socket.disconnect();
  }

  /// Emit a user join event after login
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
