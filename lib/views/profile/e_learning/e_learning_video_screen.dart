import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ELearningVideoScreen extends StatefulWidget {
  final String videoURL;
  final String videoThumbnail;
  final String videoTitle;
  final List<dynamic> videos;

  const ELearningVideoScreen({
    Key? key,
    required this.videoThumbnail,
    required this.videoURL,
    required this.videoTitle,
    required this.videos,
  }) : super(key: key);

  @override
  State<ELearningVideoScreen> createState() => _ELearningVideoScreenState();
}

class _ELearningVideoScreenState extends State<ELearningVideoScreen> {
  late YoutubePlayerController _controller;
  late TextEditingController _idController;
  late TextEditingController _seekToController;

  bool _isPlayerReady = false;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    String? videoId = YoutubePlayer.convertUrlToId(widget.videoURL);

    super.initState();

    _controller = YoutubePlayerController(
      initialVideoId: videoId!,
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
        disableDragSeek: false,
        hideThumbnail: true,
        loop: true,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    )..addListener(_listener);

    _idController = TextEditingController();
    _seekToController = TextEditingController();
  }

  void _listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      setState(() {});
    }
  }

  @override
  void deactivate() {
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    _idController.dispose();
    _seekToController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      onEnterFullScreen: () {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
        ]);
        _controller.play();
      },
      onExitFullScreen: () {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
      },
      player: YoutubePlayer(
        aspectRatio: 9 / 16,
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: context.theme.colorScheme.primary,
        thumbnail: Container(),
        onReady: () {
          _isPlayerReady = true;
        },
        onEnded: (data) {},
      ),
      builder: (context, player) => Scaffold(
        appBar: customAppBar(
          context,
          title: widget.videoTitle,
          subTitle: LocaleKeys.eLearning.tr(),
          titleColor: Colors.white,
          showSubtitle: true,
          showNewsAndPromo: false,
          showNotifications: false,
          showBackArrow: true,
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        backgroundColor: Colors.black,
        body: SingleChildScrollView(
          child: SizedBox(
            child: Center(
              child: player,
            ),
          ),
        ),
      ),
    );
  }
}
