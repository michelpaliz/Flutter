// socket_manager.dart
import 'package:hexora/b-backend/config/api_constants.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketManager {
  static final SocketManager _instance = SocketManager._internal();
  factory SocketManager() => _instance;
  SocketManager._internal();

  IO.Socket? _socket; // ✅ no 'late'
  bool get isConnected => _socket?.connected == true;

  // Deduped listener registry
  final Map<String, void Function(dynamic)> _registeredHandlers = {};

  /// Connect only once; safe to call multiple times.
  void connect(String userToken) {
    if (_socket != null) {
      // Already created; nothing else to do here.
      return;
    }

    final socketUrl = ApiConstants.baseUrl.replaceFirst('/api', '');
    _socket = IO.io(socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'extraHeaders': {
        'Authorization': 'Bearer $userToken',
      },
      // Optional reconnection strategies
      // 'reconnection': true,
      // 'reconnectionAttempts': 5,
      // 'reconnectionDelay': 1000,
    });

    _socket!.onConnect((_) {
      print("✅ Socket connected");
      _rebindAllHandlers(); // attach any handlers registered "early"
    });

    _socket!.onDisconnect((_) => print("🔌 Socket disconnected"));
    _socket!.onError((err) => print("❌ Socket error: $err"));
    _socket!.onConnectError((err) => print("❌ Socket connect error: $err"));
  }

  /// Register an event listener with deduplication.
  /// Safe to call before connect(); it will bind on first connect.
  void on(String event, void Function(dynamic) handler) {
    // Store/replace handler in registry
    if (_registeredHandlers.containsKey(event) && _socket != null) {
      _socket!.off(event, _registeredHandlers[event]);
    }
    _registeredHandlers[event] = handler;

    // If socket exists now, bind immediately
    if (_socket != null) {
      _socket!.on(event, handler);
    } else {
      // print('ℹ️ Queued handler for "$event" until socket connects.');
    }
  }

  /// Unregister a specific event listener
  void off(String event) {
    if (_registeredHandlers.containsKey(event)) {
      if (_socket != null) {
        _socket!.off(event, _registeredHandlers[event]);
      }
      _registeredHandlers.remove(event);
    }
  }

  /// Emit helpers
  void emit(String event, dynamic data) {
    if (_socket == null) {
      print('⚠️ emit("$event") called before connect; ignoring.');
      return;
    }
    _socket!.emit(event, data);
  }

  void emitUserJoin({
    required String userId,
    required String userName,
    required String groupId,
    required String? photoUrl,
  }) {
    emit("user:join", {
      "userId": userId,
      "userName": userName,
      "groupId": groupId,
      "photoUrl": photoUrl,
    });
    print("📡 Emitted user:join for $userName ($userId)");
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  // --- internal ---
  void _rebindAllHandlers() {
    if (_socket == null) return;
    _registeredHandlers.forEach((event, handler) {
      // Make sure we don't double-attach
      _socket!.off(event, handler);
      _socket!.on(event, handler);
    });
  }
}
