import 'dart:typed_data';

import 'package:aed_map/bloc/feedback/feedback_cubit.dart';
import 'package:aed_map/bloc/feedback/feedback_state.dart';
import 'package:aed_map/repositories/feedback_repository.dart';
import 'package:feedback/feedback.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('FeedbackCubit', () {
    late FeedbackCubit feedbackCubit;

    setUp(() {
      feedbackCubit = FeedbackCubit(feedbackRepository: FeedbackRepository());
    });

    test('initial state is FeedbackReady', () {
      expect(feedbackCubit.state, const FeedbackReady());
    });

    test('send', () async {
      expect(feedbackCubit.state, const FeedbackReady());
      feedbackCubit.send(UserFeedback(text: 'test', screenshot: Uint8List(0)));
      expect(feedbackCubit.state, const FeedbackSending());
      await Future.delayed(const Duration(seconds: 1));
      expect(feedbackCubit.state, const FeedbackReady());
    });
  });
}
