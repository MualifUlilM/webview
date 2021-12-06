import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  if (args.isNotEmpty) {
    if (args[0].split("=")[0] == '--url') {
      String url = args[0].split("=")[1];
      if (url.startsWith("http")) {
        final file = File('assets/assets.json').writeAsString("{\"url\":\"$url\"}");
        // print("start with http");
        // print(url);
      } else {
        final file = File('assets/assets.json')
            .writeAsString("{\"url\":\"${'https://' + url}\"}");
        // print('https://' + url);
      }
      print("url is set");
    }
  }
}
