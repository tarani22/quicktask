import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

Future<void> initBack4App() async {
  const keyApplicationId = 'TXbKShwrQLtNFt2SiIpDFx3EY1GbFZsjm5Jd0wJZ';
  const keyClientKey = 'WTjvkLcVvyBj8iYELgkSFeERPCTZZ0OxfhqYyB3J';
  const keyParseServerUrl = 'https://parseapi.back4app.com';

  await Parse().initialize(
    keyApplicationId,
    keyParseServerUrl,
    clientKey: keyClientKey,
    autoSendSessionId: true,
    debug: true,
  );
} 