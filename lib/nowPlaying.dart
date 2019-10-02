import 'dart:async';

import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;

import 'session.dart';
import 'song.dart';
import 'utils.dart';

Future<SongLink> fetchNowPlaying() async {
  var songLink = SongLink();
  final url = '$baseUri/now-top.php';
  final response = await Session.get(url);

  if (response.statusCode == 200) {
    var body = response.body;
    dom.Document document = parser.parse(body);

    var titreSong = document.getElementsByClassName('titre-song')[0];
    String href = titreSong.children[0].attributes['href'];
    songLink.id = extractSongId(href);
    songLink.title = stripTags(titreSong.children[0].innerHtml);

    var titreSong2 = document.getElementsByClassName('titre-song2')[0];
    songLink.artist = stripTags(titreSong2.children[0].innerHtml);

    var requete = document.getElementById('requete');
    songLink.program = stripTags(requete.innerHtml);
    return songLink;
  } else {
    throw Exception('Failed to load top');
  }
}

class NowPlayingWidget extends StatefulWidget {
  NowPlayingWidget({Key key}) : super(key: key);

  @override
  _NowPlayingWidgetState createState() => _NowPlayingWidgetState();
}

class _NowPlayingWidgetState extends State<NowPlayingWidget> {
  Future<SongLink> _songLink;
  Timer _timer;

  _NowPlayingWidgetState();

  @override
  void initState() {
    super.initState();
    _songLink = fetchNowPlaying();
    _timer = Timer.periodic(Duration(seconds: 45), (Timer timer) async {
      setState(() { _songLink = fetchNowPlaying();});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<SongLink>(
        future: _songLink,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return SongCardWidget(songLink: snapshot.data);
          } else if (snapshot.hasError) {
            return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  errorDisplay(snapshot.error),
                  RaisedButton.icon(
                    icon: Icon(Icons.refresh),
                    onPressed: () =>
                        setState(() { _songLink = fetchNowPlaying();}),
                    label: Text('Ré-essayer maintenant'),
                  )
                ]);
          }

          // By default, show a loading spinner
          return CircularProgressIndicator();
        },
      ),
    );
  }
}
