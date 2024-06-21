import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_amazon_clone_bloc/src/presentation/widgets/common_widgets/custom_app_bar.dart';
import 'package:http/http.dart' as http;

class AvatarScreen extends StatefulWidget {
  final String url;
  AvatarScreen({required this.url});
  @override
  _AvatarScreenState createState() => _AvatarScreenState();
}

class _AvatarScreenState extends State<AvatarScreen> {
  late VideoPlayerController _controller;
  late stt.SpeechToText _speech;
  final fillerUrl =
      "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4";
  bool _isListening = false;
  String _text = "Press the button and start speaking";
  double _confidence = 1.0;
  late ScrollController _scrollController;
  bool _showConfirmationButtons = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        setState(() {
          _controller.play();
        });
      });
    _speech = stt.SpeechToText();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _listen() async {
    if (_isListening) {
      setState(() {
        _isListening = false;
        _showConfirmationButtons = true;
      });
      _speech.stop();
    } else {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
            if (val.hasConfidenceRating && val.confidence > 0) {
              _confidence = val.confidence;
            }
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }),
        );
      } else {
        setState(() => _isListening = false);
        _speech.stop();
      }
    }
  }

  void _reset() {
    setState(() {
      _text = "Press the button and start speaking";
      _showConfirmationButtons = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        content: Scaffold(
      body: Column(
        children: <Widget>[
          if (_controller.value.isInitialized)
            AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: Container(
                margin: EdgeInsets.fromLTRB(10, 30, 10, 30),
                child: VideoPlayer(_controller),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: _scrollController,
              child: Row(
                children: [
                  Text(
                    _text,
                    style: TextStyle(fontSize: 24.0),
                  ),
                ],
              ),
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                children: [
                  FloatingActionButton(
                    onPressed: _listen,
                    child: Icon(_isListening ? Icons.mic : Icons.mic_none),
                  ),
                  if (_showConfirmationButtons) ...[
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            _controller = VideoPlayerController.networkUrl(
                                Uri.parse(fillerUrl))
                              ..initialize().then((_) {
                                setState(() {
                                  _controller.play();
                                });
                              });
                            _showConfirmationButtons = false;
                            await Future.delayed(Duration(seconds: 1));
                            _controller.play();
                            Navigator.of(context).pop(_text);
                          },
                          child: Icon(Icons.check),
                        ),
                        SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _reset,
                          child: Icon(Icons.close),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
