abstract class ServerManager {
  Future<void> startServer();
  Future<void> stopServer();
  bool get isRunning;
}

class ServerManagerStub implements ServerManager {
  @override
  Future<void> startServer() async {
    // No-op no Web
  }

  @override
  Future<void> stopServer() async {
    // No-op no Web
  }

  @override
  bool get isRunning => false;
}

ServerManager getServerManager() => ServerManagerStub();
