import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

String _searchText = '';
List<dynamic> _filteredPosts = []; // Initialize with an empty list

class Post {
  final String email;
  final String password;

  Post({required this.email, required this.password});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      email: json['email'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'API Member',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/detail': (context) => DetailPage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class DetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Detail Page Content'),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomePageState extends State<HomePage> {
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    postData().then((_) {
      setState(() {
        _filteredPosts =
            List.from(_posts); // Initialize _filteredPosts with _posts
      });
    });
  }

  final List<dynamic> _posts = [];

  Future<void> postData() async {
    var url = Uri.parse('https://devapi.thefavored-one.com/admin/login');
    var headers = {'Content-Type': 'application/json'};
    var body = json.encode({'email': 'lviors@gmail.com', 'password': '123456'});

    var response = await http.post(url, headers: headers, body: body);
    var responseData = json.decode(response.body);
    var accessToken = responseData['result']['access_token'];

    var urlLogin = Uri.parse(
        'https://devapi.thefavored-one.com/admin/reports/member/rpt-members');
    var headersLogin = {'Authorization': 'Bearer $accessToken'};
    var responseLogin = await http.get(urlLogin, headers: headersLogin);
    var responseDataLogin = json.decode(responseLogin.body);
    var getId = responseDataLogin['result']['rows'];
    var rows = responseDataLogin['result']['rows'];
    print(getId);
    setState(() {
      _posts.addAll(rows);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('API Demo')),
      body: Column(
        children: [
          TextField(
            onChanged: (value) {
              setState(() {
                _searchText = value;
                _filteredPosts = _posts.where((post) {
                  final nama = post['nama'].toString().toLowerCase();
                  return nama.contains(_searchText.toLowerCase());
                }).toList();
              });
            },
            decoration: const InputDecoration(
              labelText: 'Search',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          Expanded(
            child: Builder(
              builder: (context) => ListView.builder(
                controller: _scrollController,
                itemCount: _filteredPosts.length + 1,
                itemBuilder: (context, index) {
                  if (index < _filteredPosts.length) {
                    var post = _filteredPosts[index];
                    String avatarUrl;
                    if (post['posisi'] == 'PLATINUM') {
                      avatarUrl =
                          'https://cdn.pixabay.com/photo/2016/09/01/08/25/smiley-1635456_1280.png';
                    } else if (post['posisi'] == 'SILVER') {
                      avatarUrl =
                          'https://cdn.pixabay.com/photo/2016/09/01/08/24/smiley-1635449_1280.png';
                    } else {
                      avatarUrl =
                          ''; // URL avatar default jika posisi tidak sesuai
                    }

                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/detail');
                      },
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(avatarUrl),
                        ),
                        title: Text(post['nama']),
                        subtitle: Text(post['posisi']),
                      ),
                    );
                  } else {
                    // Item loading
                    return const ListTile(
                      title: Center(child: CircularProgressIndicator()),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
