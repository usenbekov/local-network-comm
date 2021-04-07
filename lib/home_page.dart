import 'package:LocalNetworkComm/communication.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Communication comm;
  TextEditingController txtController = TextEditingController();

  @override
  void initState() {
    createComm();
    super.initState();
  }

  Future<void> createComm() async {
    comm = Communication(
      onUpdate: () {
        setState(() {});
      },
    );
    await comm.startServe();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Local network communication'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.separated(
              itemCount: comm.messages.length,
              separatorBuilder: (context, index) => Divider(),
              itemBuilder: (context, index) {
                final message = comm.messages[index];
                return ListTile(
                  visualDensity: VisualDensity.compact,
                  title: Text(message.msg),
                  subtitle: Text(message.ip),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    textCapitalization: TextCapitalization.sentences,
                    controller: txtController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter your message',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    comm.sendMessage(txtController.text);
                    txtController.clear();
                    FocusScope.of(context).unfocus();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
