import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gif',
      theme: ThemeData(primarySwatch: Colors.deepOrange),
      home: const GifSearch(),
    );
  }
}

class Gif {
  final String url;

  Gif({required this.url});

  factory Gif.fromJson(Map<String, dynamic> json) {
    //print('The URL is: ${json['images']['mp4_size']}');
    return Gif(
      url: json['images']['original']['url'],
    );
  }
}

class GifSearch extends StatefulWidget {
  const GifSearch({super.key});

  @override
  createState() => _GifSearchState();
}

const int _limit = 12;
const String _apiKey = 'ubpiBBPouVOIppfiPbG9MQz4C2xi5EK2';

class _GifSearchState extends State<GifSearch> {
  final TextEditingController _searchController = TextEditingController();

  String _searchTerm = '';
  Future<List<Gif>> _gifsFuture = Future.value([]);

  Future<List<Gif>> fletchGif(String searchTerm) async {
    final responce = await http.get(Uri.parse(
        'https://api.giphy.com/v1/gifs/search?api_key=$_apiKey&q=$_searchTerm&limit=$_limit&offset=0&rating=g&lang=en'));

    if (responce.statusCode == 200) {
      List gifData = json.decode(responce.body)['data'];
      List<Gif> gifs = gifData.map((gifData) => Gif.fromJson(gifData)).toList();
      return gifs;
    } else {
      throw Exception('Failed to search for gifs');
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find your GIF'),
        centerTitle: true,
      ),
      body: Container(
        color: const Color.fromARGB(255, 249, 227, 221),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                controller: _searchController,
                onSubmitted: (value) {
                  setState(() {
                    _searchTerm = value;
                    _gifsFuture = fletchGif(_searchTerm);
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Enter GIF name',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      setState(() {
                        _gifsFuture = fletchGif(_searchController.text);
                      });
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: FutureBuilder<List<Gif>>(
                  future: _gifsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<Gif> gifs = snapshot.data as List<Gif>;
                      return GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 200,
                          childAspectRatio: 3 / 2.5,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: gifs.length,
                        itemBuilder: (context, index) {
                          return Image.network(
                            gifs[index].url,
                            fit: BoxFit.cover,
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Text('${snapshot.error}');
                    }
                    return const CircularProgressIndicator();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
