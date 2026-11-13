import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Server connection status representation.
enum ServerHealthStatus { online, offline, pinging, idle }

class RenderKeepAliveState {
  final String backendUrl;
  final ServerHealthStatus status;
  final DateTime? lastPingTime;
  final int? lastPingLatencyMs;
  final int successfulPings;
  final String? lastError;

  const RenderKeepAliveState({
    required this.backendUrl,
    this.status = ServerHealthStatus.idle,
    this.lastPingTime,
    this.lastPingLatencyMs,
    this.successfulPings = 0,
    this.lastError,
  });

  RenderKeepAliveState copyWith({
    String? backendUrl,
    ServerHealthStatus? status,
    DateTime? lastPingTime,
    int? lastPingLatencyMs,
    int? successfulPings,
    String? lastError,
  }) {
    return RenderKeepAliveState(
      backendUrl: backendUrl ?? this.backendUrl,
      status: status ?? this.status,
      lastPingTime: lastPingTime ?? this.lastPingTime,
      lastPingLatencyMs: lastPingLatencyMs ?? this.lastPingLatencyMs,
      successfulPings: successfulPings ?? this.successfulPings,
      lastError: lastError,
    );
  }
}

/// Service dedicated to pinging the Render backend every 5 minutes so the
/// free-tier instance never spins down (which occurs after 10 mins of idle time).
class RenderKeepAliveService extends StateNotifier<RenderKeepAliveState> {
  static const String defaultRenderUrl =
      'https://together-backend.onrender.com';
  static const String _prefKey = 'together_render_backend_url';

  Timer? _periodicTimer;
  final http.Client _client = http.Client();

  RenderKeepAliveService()
      : super(const RenderKeepAliveState(backendUrl: defaultRenderUrl)) {
    _init();
  }

  Future<void> _init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUrl = prefs.getString(_prefKey);
      if (savedUrl != null && savedUrl.isNotEmpty) {
        state = state.copyWith(backendUrl: savedUrl);
      }
    } catch (_) {}

    // Start 5-minute keepalive loop immediately
    startKeepAlive();
    // Fire first ping right away
    pingNow();
  }

  /// Start the 5-minute periodic ping loop
  void startKeepAlive() {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return;
    }
    _periodicTimer?.cancel();
    // 5 minutes = 300 seconds (prevents Render 10-minute container spin-down)
    _periodicTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      pingNow();
    });
  }

  /// Manually trigger a ping to the Render server
  Future<bool> pingNow() async {
    // Skip real HTTP network calls during automated widget test runs
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      state = state.copyWith(status: ServerHealthStatus.online);
      return true;
    }

    state = state.copyWith(status: ServerHealthStatus.pinging);
    final stopwatch = Stopwatch()..start();

    try {
      final url = Uri.parse('${state.backendUrl}/ping');
      final response = await _client.get(url).timeout(
            const Duration(seconds: 12),
          );
      stopwatch.stop();

      if (response.statusCode == 200) {
        final now = DateTime.now();
        state = state.copyWith(
          status: ServerHealthStatus.online,
          lastPingTime: now,
          lastPingLatencyMs: stopwatch.elapsedMilliseconds,
          successfulPings: state.successfulPings + 1,
          lastError: null,
        );
        debugPrint(
          '💚 [RenderKeepAlive] Ping ok (${stopwatch.elapsedMilliseconds}ms) at $now',
        );
        return true;
      } else {
        throw Exception('HTTP status ${response.statusCode}');
      }
    } catch (e) {
      stopwatch.stop();
      state = state.copyWith(
        status: ServerHealthStatus.offline,
        lastError: e.toString(),
      );
      debugPrint('⚠️ [RenderKeepAlive] Ping failed: $e');
      return false;
    }
  }

  /// Update the backend URL (e.g. for user deployment)
  Future<void> setBackendUrl(String url) async {
    final sanitized = url.trim().replaceAll(RegExp(r'/+$'), '');
    state = state.copyWith(backendUrl: sanitized);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, sanitized);
    } catch (_) {}
    pingNow();
  }

  @override
  void dispose() {
    _periodicTimer?.cancel();
    _client.close();
    super.dispose();
  }
}

final renderKeepAliveProvider =
    StateNotifierProvider<RenderKeepAliveService, RenderKeepAliveState>((ref) {
  return RenderKeepAliveService();
});
