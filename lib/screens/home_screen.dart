// ignore_for_file: use_build_context_synchronously
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:ombre/constants.dart';
import 'package:ombre/screens/stream_screen.dart';
import 'package:ombre/screens/watch_stream_screen.dart';
import 'package:ombre/services/auth.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: Text(
          "ombre",
          style: Constants.logoStyle,
        ),
        actions: [
          InkWell(
            onTap: () async {
              showLoadingDialog(context);
              await authService.signOut();
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: Icon(
              Icons.logout,
              size: 20,
              color: Constants.primaryColor,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                            "assets/live_now.png",
                          ),
                        ),
                      ),
                    ),
                    const Text(
                      "streams",
                    ),
                  ],
                ),
                // show all live streams here
                FutureBuilder(
                  future: http.get(
                      Uri.parse(
                          "https://api.agora.io/dev/v1/channel/2d865c0731b94980b4328297ff4db739"),
                      headers: {
                        "Authorization":
                            "basic MTg1OTJiNGFiYTVjNGNiYWEyZTQ5NTJmZTVjYTRlMjU6NjY0YjFiNjJkODZkNDJmYmExNzVkNDE0NWM1ODY1OGQ=",
                      }),
                  builder:
                      (BuildContext context, AsyncSnapshot<http.Response> res) {
                    if (res.connectionState == ConnectionState.done) {
                      List<dynamic> channels =
                          jsonDecode(res.data!.body)["data"]["channels"];
                      if (channels.isEmpty) {
                        return const Text("No one is live right now :(");
                      } else {
                        return GridView.count(
                          shrinkWrap: true,
                          crossAxisCount: 2,
                          children: channels
                              .map<Widget>(
                                (channel) => liveUserCard(
                                  context,
                                  channel["channel_name"],
                                ),
                              )
                              .toList(),
                        );
                      }
                    }
                    return const Text(
                      "Loading...",
                      textAlign: TextAlign.center,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(5),
        height: 100,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: () async {
                await [Permission.microphone, Permission.camera].request();
                bool isCamDenied = await Permission.camera.isDenied;
                bool isMicDenied = await Permission.microphone.isDenied;
                if (isCamDenied || isMicDenied) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text(
                        "Permissions not granted",
                      ),
                      content: const Text(
                        "This feature requires camera and microphone permission to work.",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () async {
                            Navigator.of(context, rootNavigator: true).pop();
                          },
                          child: const Text(
                            "Ok",
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StreamScreen(),
                    ),
                  );
                }
              },
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                          "assets/go_live.png",
                        ),
                      ),
                    ),
                  ),
                  const Text(
                    "Go Live!",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget liveUserCard(BuildContext context, String channel) {
    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WatchStreamScreen(
              channelName: channel,
            ),
          ),
        );
        setState(() {});
      },
      child: Card(
        shadowColor: Constants.primaryColor,
        elevation: 2,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Watch live by user $channel",
            ),
          ],
        ),
      ),
    );
  }
}
