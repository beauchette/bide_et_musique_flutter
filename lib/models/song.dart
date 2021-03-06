import '../utils.dart';
import 'account.dart';
import 'program.dart';

class SongLink {
  int id;
  String name;
  String artist;
  String info;
  bool isNew;
  String cover;
  int index;

  SongLink(
      {this.id,
      this.name,
      this.artist,
      this.cover,
      this.info,
      this.isNew = false});

  String get streamLink {
    return '$baseUri/stream_${this.id}.php';
  }

  String get link {
    return '$baseUri/song/${this.id}.html';
  }

  String get coverLink {
    String url = '$baseUri/images/pochettes/';
    if (this.cover == null || this.cover == '')
      url += '${this.id}.jpg';
    else
      url += this.cover;
    return url;
  }

  String get thumbLink {
    return '$baseUri/images/thumb100/${this.id}.jpg';
  }

  // 20 25 30 50 75 100 150 200
  String getThumbLink(int size) => '$baseUri/images/thumb$size/${this.id}.jpg';
}

class Song extends SongLink {
  int year;
  int artistId;
  String author;
  Duration duration;
  String durationPretty;
  String label;
  String reference;
  String lyrics;
  List<Comment> comments;
  bool canListen;
  bool canFavourite;
  bool isFavourite;
  bool hasVote;

  Song(
      {id,
      name,
      artist,
      cover,
      info,
      this.year,
      this.artistId,
      this.author,
      this.duration,
      this.durationPretty,
      this.label,
      this.reference,
      this.lyrics})
      : super(id: id, name: name, artist: artist, cover: cover, info: info);

  Song.fromJson(Map<String, dynamic> json)
      : year = json['year'],
        artistId = json['artists']['main']['id'],
        author = json['authors'],
        duration = Duration(seconds: json['length']['raw']),
        durationPretty = json['length']['pretty'],
        label = stripTags(json['label']),
        reference = stripTags(json['reference']),
        lyrics = json['lyrics'],
        super(
            id: json['id'],
            name: stripTags(json['name']),
            artist: stripTags(json['artists']['main']['alias']),
            cover: json['covers']['main']);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'artist': artist,
        'duration': duration.inSeconds
      };
}

class Comment {
  int id;
  AccountLink author;
  String body;
  String time;

  Comment();
}

class SongNowPlaying extends Song {
  final int elapsedPcent;
  final int nbListeners;
  final Program program;

  SongNowPlaying.fromJson(Map<String, dynamic> json)
      : elapsedPcent = json['now']['elapsed_pcent'],
        nbListeners = json['now']['nb_listeners'],
        program = Program(
            id: json['now']['program']['id'],
            name: stripTags(json['now']['program']['name'])),
        super.fromJson(json);
}
