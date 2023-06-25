import 'dart:convert';

import 'package:feedback/feedback.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class FeedbackRepository {
  sendFeedback(UserFeedback feedback) async {
    final now = DateTime.now();
    final id = now.microsecondsSinceEpoch.toString();
    var content = feedback.text;
    await http.post(Uri.parse('http://feedback.aedmapa.pl:5000/feedback'),
        body: {'body': content, 'id': id.toString(), 'screenshot': base64Encode(feedback.screenshot)});
    if (kDebugMode) {
      print('Feedback sent!');
    }
  }
}
