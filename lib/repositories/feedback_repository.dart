import 'package:aed_map/constants.dart';
import 'package:feedback/feedback.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class FeedbackRepository {
  sendFeedback(UserFeedback feedback) async {
    if (feedback.screenshot.isEmpty) {
      await Future.delayed(const Duration(seconds: 1));
      return;
    }
    final attachment =
        SentryAttachment.fromUint8List(feedback.screenshot, 'captured.png');
    var sentryId =
        await Sentry.captureMessage(feedbackEvent, withScope: (scope) {
      scope.addAttachment(attachment);
    });
    final userFeedback = SentryFeedback(
      associatedEventId: sentryId,
      message: feedback.text,
    );
    await Sentry.captureFeedback(userFeedback);
  }
}
