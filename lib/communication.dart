import 'dart:io';

class Message {
  final String ip;
  final String msg;
  Message(this.ip, this.msg);
  @override
  String toString() => '{$ip, $msg}';
}

class Communication {
  Communication({this.port = 8080, this.onUpdate});
  final int port;
  final messages = List<Message>();
  final Function() onUpdate;

  // Hard coded, needs improvement
  Future<String> myLocalIp() async {
    final interfaces =
        await NetworkInterface.list(type: InternetAddressType.IPv4, includeLinkLocal: true);
    return interfaces
        .where((e) => e.addresses.first.address.indexOf('192.') == 0)
        ?.first
        ?.addresses
        ?.first
        ?.address;
  }

  // start serving on given port
  Future<void> startServe() async {
    final ip = await myLocalIp();
    var server = await HttpServer.bind(ip, port);
    print('Listening on $ip:${server.port}');

    await for (HttpRequest request in server) {
      _handleRequest(request);
      request.response.write('Ok');
      await request.response.close();
    }
  }

  // Handle the request
  void _handleRequest(HttpRequest request) {
    // if query has a message then add to list
    final msg = request.uri.queryParameters['msg'];
    final from = request.uri.queryParameters['ip'];
    if (msg != null) {
      messages.insert(0, Message(from ?? '', msg ?? ''));
      onUpdate();
    }
  }

  // Send message all
  void sendMessage(String msg) async {
    final ip = await myLocalIp();
    final threeOctet = ip.substring(0, ip.lastIndexOf('.'));
    for (var i = 1; i < 200; i++) {
      _sendRequest('$threeOctet.$i', "?ip=$ip&msg=$msg");
    }
  }

  void _sendRequest(String to, String path) async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 2);
    try {
      final resp = await client.get(to, port, path);
      resp.close();
    } catch (e) {
      // print(e);
    }
  }
}
