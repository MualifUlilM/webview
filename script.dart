import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  Map<String, String> keyProperties = {};
  if (args.isNotEmpty) {
    for (var arg in args) {
      String command = arg.split("=")[0];
      if (command == "--url") {
        String url = arg.split("=")[1];
        createAssetJsonFile(url);
      } else if (command == "--key-password") {
        String keyPassword = arg.split("=")[1];
        createKeyPropFile("keyPassword", keyPassword);
      } else if (command == "--key-alias") {
        String keyAlias = arg.split("=")[1];
        createKeyPropFile("keyAlias", keyAlias);
      } else if (command == "--key-store-password") {
        String keyStorePassword = arg.split("=")[1];
        createKeyPropFile("storePassword", keyStorePassword);
      } else if (command == "--key-store-alias") {
        String keyStoreAlias = arg.split("=")[1];
        createKeyPropFile("storeAlias", keyStoreAlias);
      } else if (command == "--key-store-path") {
        String directory = Directory.current.path;
        String keyStorePath = directory + "/upload.jks";
        createKeyPropFile("storeFile", keyStorePath);
      } else if (command == "--key-store") {
        String keyStore = arg.replaceAll("--key-store=", '');
        print(keyStore);
        createKeyStoreFile(keyStore);
      } else if (command == "--help") {
        print(
            "Usage: dart build.dart [--url=<url>] [--key-password=<key-password>] [--key-alias=<key-alias>] [--key-store-password=<key-store-password>] [--key-store-alias=<key-store-alias>] [--key-store-path=<key-store-path>]");
      }
    }
  } else {
    // no argument passes please see all command with --help
    print(
        "Usage: dart script.dart [--url=<url>] [--key-password=<key-password>] [--key-alias=<key-alias>] [--key-store-password=<key-store-password>] [--key-store-alias=<key-store-alias>] [--key-store-path=<key-store-path>]");
  }
}

void createAssetJsonFile(String url) {
  if (url.startsWith("http")) {
    final file = File('assets.json').writeAsString("{\"url\":\"$url\"}");
  } else {
    final file =
        File('assets.json').writeAsString("{\"url\":\"${'https://' + url}\"}");
  }
  print("url is set");
}

void createKeyPropFile(String argument, String value) {
  // check if file exists
  if (File('android/key.properties').existsSync()) {
    String data = "$argument=$value\n";
    File('android/key.properties').writeAsStringSync(data, mode: FileMode.append);
  } else {
    // create file and then write
    File('android/key.properties').writeAsStringSync("$argument=$value\n");
  }
}

void createKeyStoreFile(String keyStore) {
  // create file and then insert text with decoding base64
  // print(keyStore);
  var data = base64.decode(base64.normalize(keyStore));
  // print(data);
  File('upload.jks').writeAsBytesSync(data);
  // File('key.jks').writeAsStringSync(data);
  print("keystore is set");
}
