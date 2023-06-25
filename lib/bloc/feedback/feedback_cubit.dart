import 'package:aed_map/bloc/feedback/feedback_state.dart';
import 'package:aed_map/repositories/feedback_repository.dart';
import 'package:feedback/feedback.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FeedbackCubit extends Cubit<FeedbackState> {
  FeedbackCubit({required this.feedbackRepository}) : super(const FeedbackReady());

  final FeedbackRepository feedbackRepository;

  send(UserFeedback feedback) async {
    emit(const FeedbackSending());
    await feedbackRepository.sendFeedback(feedback);
    emit(const FeedbackReady());
  }
}
