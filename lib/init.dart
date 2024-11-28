import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

Future<void> initBack4App() async {
  const keyApplicationId = '2GF8FbDJPtKbvoQT1N62VmyjY8zC8li7gyxDHKYE';
  const keyClientKey = 'G222HaYbcT8BgLaRcUmHfTqykCYxnbdZ0GMN1QlY';
  const keyParseServerUrl = 'https://parseapi.back4app.com';

  await Parse().initialize(
    keyApplicationId,
    keyParseServerUrl,
    clientKey: keyClientKey,
    autoSendSessionId: true,
    debug: true,
  );

  // Register the Task subclass
  //Parse().registerSubclass<Task>(Task());
} 