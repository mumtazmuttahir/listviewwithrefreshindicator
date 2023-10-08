import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'List View Demo with refresh indicator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final scrollController = ScrollController();
  List<String> items = [];
  int page = 1;
  bool hasMore = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchDataFromTheServer();

    scrollController.addListener(() {
      //To make sure the user is scrolling till the bottom of the screen
      if (scrollController.position.maxScrollExtent ==
          scrollController.offset) {
        fetchDataFromTheServer();
      }
    });
  }

  Future fetchDataFromTheServer() async {
    if (isLoading) return;
    isLoading = true;
    const limit = 25;
    final url = Uri.parse(
        'https://jsonplaceholder.typicode.com/posts?_limit=$limit&_page=$page');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List newItems = json.decode(response.body);
      setState(() {
        page++;
        isLoading = false;
        if (newItems.length < limit) {
          hasMore = false;
        }
        items.addAll(newItems.map<String>((item) {
          final id = item['id'];
          return 'Item $id';
        }).toList());
      });
    }
  }

  Future refresh() async {
    setState(() {
      page = 0;
      hasMore = true;
      isLoading = false;
      items.clear();
    });

    fetchDataFromTheServer();
  }

  //make sure to dispose the controller as it is a statful widget
  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        child: ListView.builder(
          padding: const EdgeInsets.all(8.0),
          //The scroll controller must be add here
          //Otherwise the scrolling will not update
          controller: scrollController,
          //Add 1 here so that the last element in the list view
          //is either a progress indicator or end of list text
          itemCount: items.length + 1,
          itemBuilder: (context, index) {
            if (index < items.length) {
              final item = items[index];
              return ListTile(
                title: Text(item),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(
                  child: hasMore == true
                      ? const CircularProgressIndicator()
                      : const Text('End of list'),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
