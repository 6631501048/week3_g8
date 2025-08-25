import 'package:week3_g8/week3_g8.dart' as week3_g8;
import 'package:http/http.dart' as http;
import 'dart:io';

import 'dart:convert';
//============================================================

//================= Fea 1+2 ===============
void main() async {
  var url = Uri.parse('https://jsonplaceholder.typicode.com/posts');
  var response = await http.get(url);
  var jsonData = jsonDecode(response.body);

  // Print all titles
  for (var post in jsonData) {
    print('Title: ${post['title']}');
  }

  // Print body of post with id=10
  var postId10 = jsonData.firstWhere((post) => post['id'] == 10, orElse: () => null);
  if (postId10 != null) {
    print('\nBody of post with id=10:\n${postId10['body']}');
  } else {
    print('Post with id=10 not found.');
  }
}
//================= Fea 3 =================

//================= Fea 4 =================

//================= Fea 5+6 =================
