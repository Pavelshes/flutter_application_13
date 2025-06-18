import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';

void main() => runApp(MarsRoverApp()); 

class MarsRoverApp extends StatelessWidget {
  const MarsRoverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
       title: 'Mars Rover Photos',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> photos = [];
  bool isLoading = true;
  Future<void> fetchPhotos() async {
    final apiKey = 'B8ycHJeOrQeTMrO5TnIfVl3VWnrMmntln7xGckBQ'; // Замените на свой ключ
    final url =
        'https://api.nasa.gov/mars-photos/api/v1/rovers/spirit/photos?sol=100&api_key=$apiKey B8ycHJeOrQeTMrO5TnIfVl3VWnrMmntln7xGckBQ';

final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        photos = data['photos'];
        isLoading = false;
      });
       } else {
      setState(() {
        isLoading = false;
        photos = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки данных')),
      );
    }
  }
     @override
  void initState() {
    super.initState();
    fetchPhotos();
  }
     @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Фото Spirit - Сол 100'),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : photos.isEmpty
              ? Center(child: Text('Нет фото', style: TextStyle(color: Colors.white)))
              : GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                  ),


                  itemCount: photos.length,
                  itemBuilder: (context, index) {
                    final photo = photos[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailScreen(photo: photo),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 4,
                        child: CachedNetworkImage(
                          imageUrl: photo['img_src'],
                          placeholder: (context, url) =>
                              Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
  

  );
  }
}
 
 class DetailScreen extends StatelessWidget {
  final Map<String, dynamic> photo;

 const DetailScreen({super.key, required this.photo});
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Детали фото'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Center(
              child: Hero(
                tag: photo['id'],
                child: CachedNetworkImage(
                  imageUrl: photo['img_src'],
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Камера: ${photo['camera']['name']}', style: TextStyle(color: Colors.white, fontSize: 16)),
                SizedBox(height: 8),
                Text('Дата: ${photo['earth_date']}', style: TextStyle(color: Colors.white, fontSize: 16)),
                SizedBox(height: 8),
                Text('Марсоход: ${photo['rover']['name']}', style: TextStyle(color: Colors.white, fontSize: 16)),
              ],
            ),
          )
        ],
      ),
    );
  }
}