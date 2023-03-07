import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';

String get appId {
  return const String.fromEnvironment('TEST_APP_ID',
      defaultValue: '<TEST_APP_ID>');
}

String channelId = 'test_shrink';

class JoinChannelVideo extends StatefulWidget {
  const JoinChannelVideo({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<JoinChannelVideo> {
  late final RtcEngine _engine;

  bool isJoined = false, switchCamera = true, switchRender = true;
  Set<int> remoteUid = {};
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: channelId);

    _initEngine();
  }

  @override
  void dispose() {
    super.dispose();
    _dispose();
  }

  Future<void> _dispose() async {
    await _engine.leaveChannel();
    await _engine.release();
  }

  Future<void> _initEngine() async {
    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(
      appId: appId,
    ));

    _engine.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        setState(() {
          isJoined = true;
        });
      },
      onUserJoined: (RtcConnection connection, int rUid, int elapsed) {
        setState(() {
          remoteUid.add(rUid);
        });
      },
      onUserOffline:
          (RtcConnection connection, int rUid, UserOfflineReasonType reason) {
        setState(() {
          remoteUid.removeWhere((element) => element == rUid);
        });
      },
      onLeaveChannel: (RtcConnection connection, RtcStats stats) {
        setState(() {
          isJoined = false;
          remoteUid.clear();
        });
      },
    ));

    await _engine.enableVideo();

    await _engine.setVideoEncoderConfiguration(
      const VideoEncoderConfiguration(
        dimensions: VideoDimensions(width: 640, height: 360),
        frameRate: 15,
        bitrate: 0,
      ),
    );

    await _engine.startPreview();

    await _joinChannel();
  }

  Future<void> _joinChannel() async {
    await _engine.joinChannel(
      token: '',
      channelId: _controller.text,
      uid: 0,
      options: const ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AgoraVideoView(
          controller: VideoViewController(
            rtcEngine: _engine,
            canvas: const VideoCanvas(uid: 0),
          ),
        ),
        Align(
          alignment: Alignment.topLeft,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.of(remoteUid.map(
                (e) => SizedBox(
                  width: 120,
                  height: 120,
                  child: AgoraVideoView(
                    controller: VideoViewController.remote(
                      rtcEngine: _engine,
                      canvas: VideoCanvas(uid: e),
                      connection: RtcConnection(channelId: _controller.text),
                    ),
                  ),
                ),
              )),
            ),
          ),
        )
      ],
    );
  }
}
