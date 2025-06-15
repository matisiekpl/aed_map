import 'dart:io';

import 'package:aed_map/bloc/feedback/feedback_state.dart';
import 'package:aed_map/constants.dart';
import 'package:aed_map/main.dart';
import 'package:aed_map/repositories/feedback_repository.dart';
import 'package:feedback/feedback.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FeedbackCubit extends Cubit<FeedbackState> {
  FeedbackCubit({required this.feedbackRepository})
      : super(const FeedbackReady());

  final FeedbackRepository feedbackRepository;

  Future<void> send(UserFeedback feedback) async {
    analytics.event(name: feedbackEvent);
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      mixpanel.track(feedbackEvent);
    }
    emit(const FeedbackSending());
    await feedbackRepository.sendFeedback(feedback);
    emit(const FeedbackReady());
  }
}
