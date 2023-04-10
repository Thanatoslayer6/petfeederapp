import 'dart:convert' as convert;
import 'dart:developer';
import 'package:http/http.dart' as http;

class Quotes {
  static bool hasQuote = false;
  static bool isAlreadyAnimated = false;
  static late String message;
  static late String author;

  // Test#1 remove parameter.. just call setState in hoempage
  static getRandom() async {
    try {
      var response = await http.get(Uri.parse(
          "https://api.quotable.io/random?minLength=100&maxLength=140"));
      if (response.statusCode == 200) {
        var jsonResponse =
            convert.jsonDecode(response.body) as Map<String, dynamic>;
        // setState(() {
        message = jsonResponse['content'];
        author = jsonResponse['author'];
        hasQuote = true;
        // });
        return "$message - $author";
      } else {
        return "Request failed with status: ${response.statusCode}";
      }
    } catch (e) {
      log("Cannot get random quote - $e");
    }
  }
}
