import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:ombre/constants.dart';
import 'package:http/http.dart' as http;

class StreamScreen extends StatefulWidget {
  const StreamScreen({super.key});

  @override
  State<StreamScreen> createState() => _StreamScreenState();
}

class _StreamScreenState extends State<StreamScreen> {
  String appId = "2d865c0731b94980b4328297ff4db739";
  String token = "";
  int tokenRole = 1; // use 1 for Host/Broadcaster, 2 for Subscriber/Audience
  String serverUrl =
      "https://agora-token-service-production-cb2c.up.railway.app";
  String channelName = FirebaseAuth.instance.currentUser!.uid;
  int tokenExpireTime = 45; // Expire time in Seconds.
  bool isTokenExpiring = false;
  late RtcEngine agoraEngine;
  bool isMicOff = false;
  bool isCamOff = false;
  int viewers = 0;

  @override
  void initState() {
    super.initState();
    setupVideoSDKEngine();
  }

  @override
  void dispose() async {
    await agoraEngine.leaveChannel();
    agoraEngine.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          alignment: AlignmentDirectional.bottomEnd,
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.pink,
              child: videoPanel(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "$viewers watching",
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Builder(
                        builder: (context) {
                          if (isCamOff) {
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  isCamOff = false;
                                });
                                agoraEngine.enableVideo();
                              },
                              child: const Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                              ),
                            );
                          } else {
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  isCamOff = true;
                                });
                                agoraEngine.disableVideo();
                              },
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Builder(builder: (context) {
                        if (isMicOff) {
                          return InkWell(
                            onTap: () {
                              setState(() {
                                isMicOff = false;
                              });
                              agoraEngine.enableAudio();
                            },
                            child: const Icon(
                              Icons.mic_off,
                              color: Colors.white,
                            ),
                          );
                        } else {
                          return InkWell(
                            onTap: () {
                              setState(() {
                                isMicOff = true;
                              });
                              agoraEngine.disableAudio();
                            },
                            child: const Icon(
                              Icons.mic,
                              color: Colors.white,
                            ),
                          );
                        }
                      }),
                      const SizedBox(
                        width: 20,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.white,
                            ),
                          ),
                          child: const Text(
                            "End stream!",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget videoPanel() {
    if (isCamOff) {
      return Center(
        child: Text(
          "Video paused",
          style: Constants.heading2,
        ),
      );
    }
    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: agoraEngine,
        canvas: const VideoCanvas(uid: 0),
      ),
    );
  }

  Future<void> setupVideoSDKEngine() async {
    fetchToken(0, channelName, tokenRole);
    //create an instance of the Agora engine
    agoraEngine = createAgoraRtcEngine();
    await agoraEngine.initialize(RtcEngineContext(appId: appId));
    await agoraEngine.enableVideo();

    // Register the event handler
    agoraEngine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("success");
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          setState(() {
            viewers++;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          setState(() {
            viewers--;
          });
        },
      ),
    );

    ChannelMediaOptions options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    );
    await agoraEngine.startPreview();
    await agoraEngine.joinChannel(
      token: token,
      channelId: channelName,
      options: options,
      uid: 0,
    );
  }

  Future<void> fetchToken(int uid, String? channelName, int tokenRole) async {
    String url =
        '$serverUrl/rtc/$channelName/${tokenRole.toString()}/uid/${uid.toString()}/?expiry=${tokenExpireTime.toString()}';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);
      String newToken = json['rtcToken'];
      debugPrint('Token Received: $newToken');
      debugPrint('Token Received: $channelName');
      setToken(newToken);
    } else {
      throw Exception(
        'Failed to fetch a token. Make sure that your server URL is valid',
      );
    }
  }

  void setToken(String newToken) async {
    token = newToken;
    agoraEngine.renewToken(token);
  }
}
