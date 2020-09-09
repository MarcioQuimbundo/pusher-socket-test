import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pusher_websocket_flutter/pusher.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Channel _channel;
  int _saldo = 0;
  List _history = [];
  @override
  void initState() {
    super.initState();
    initPusher();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    radius: 35,
                    child: Icon(
                      Icons.camera,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text("Márcio Quimbundo"),
                  SizedBox(
                    height: 20,
                  ),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Text("Saldo na conta"),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: <Widget>[
                                Baseline(
                                  baseline: 5,
                                  baselineType: TextBaseline.alphabetic,
                                  child: Text(
                                    "AOA",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  _saldo.toString(),
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            )
                          ]),
                    ),
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 20),
              child: Text("History"),
            ),
            Expanded(
              flex: 2,
              child: Container(
                child: ListView.builder(
                    itemCount: _history.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text("AOA ${_history[index]['nominal']}"),
                        subtitle: Text("Sender: ${_history[index]['sender']}"),
                        trailing: Text("${_history[index]['time']}"),
                      );
                    }),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> initPusher() async {
    try {
      await Pusher.init("2d8973cb869667e8d0cf",
          PusherOptions(cluster: "eu", encrypted: true));
    } catch (e) {
      print(e);
    }

    //connect
    Pusher.connect(onConnectionStateChange: (val) {
      print(val.currentState);
    }, onError: (err) {
      print(err);
    });

    //subscribe
    _channel = await Pusher.subscribe('marcio_channel');

    //bind
    _channel.bind("marcio_event", (onEvent) {
      if (mounted) {
        final data = json.decode(onEvent.data);
        setState(() {
          _saldo += int.parse(data['nominal']);
        });
        _history.add({
          'nominal': int.parse(data['nominal']),
          'sender': data["sender"],
          'time': data["time"]
        });
        print(_history);
      }
    });
  }
}
