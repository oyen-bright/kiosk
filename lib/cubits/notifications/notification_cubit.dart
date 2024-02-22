import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kiosk/models/news_feed.dart';
import 'package:kiosk/repositories/.repositories.dart';
import 'package:kiosk/service/local_storage/local_storage.dart';

part 'notification_state.dart';

/// Cubit for managing notifications and news feeds.
class NotificationCubit extends Cubit<NotificationState> {
  final LocalStorage localStorage;
  final UserRepository userRepository;
  late final Timer timer;

  /// Creates an instance of [NotificationCubit].
  ///
  /// This cubit manages notifications and news feeds, fetching updates at regular intervals.
  ///
  /// [localStorage] is responsible for reading and writing local data.
  ///
  /// [userRepository] is used to fetch new news feeds.
  NotificationCubit({
    required this.localStorage,
    required this.userRepository,
  }) : super(const NotificationState()) {
    // Read stored user news feeds and initialize the state.
    final data = localStorage.readUserNewsFeeds();
    if (data != null) {
      final notifications =
          List<NewsFeed>.from(data.map((e) => NewsFeed.fromJson(e)));
      emit(
          NotificationState(newNotificationCount: 0, newsFeeds: notifications));
    }
    // Fetch news feeds and initialize notifications.
    getNewsFeeds();
    initializeNotification();
  }

  /// Initialize periodic notifications.
  ///
  /// This method sets up a timer to periodically fetch new news feeds.
  initializeNotification() {
    timer = Timer.periodic(const Duration(minutes: 5), ((_) async {
      try {
        getNewsFeeds(catchError: false);
      } catch (_) {
        return;
      }
    }));
  }

  /// Fetch news feeds and update the state.
  ///
  /// [catchError] determines whether to catch and handle errors.
  ///
  /// This method fetches new news feeds from the [userRepository], calculates the
  /// change in the number of new notifications, and updates the state accordingly.
  Future<void> getNewsFeeds({bool catchError = true}) async {
    try {
      emit(state.copyWith(notificationStatus: NotificationStatus.loading));
      final newNewsFeed = await userRepository.getNotification();
      final currentNewsFeed = state.newsFeeds;

      int newsFeedCount = 0;

      if (currentNewsFeed != null) {
        newsFeedCount = newNewsFeed.length - currentNewsFeed.length;
      } else {
        newsFeedCount = newNewsFeed.length;
      }

      emit(state.copyWith(
          newNotificationCount: newsFeedCount,
          notificationStatus: NotificationStatus.loaded,
          newsFeeds: newNewsFeed));
    } catch (e) {
      if (catchError) {
        emit(state.copyWith(
            notificationStatus: NotificationStatus.error,
            errorMessage: e.toString()));
      } else {
        return;
      }
    }
  }

  /// Reset the notification count to zero.
  ///
  /// This method sets the new notification count in the state to zero.
  void resetNotificationCount() {
    emit(state.copyWith(
      newNotificationCount: 0,
    ));
  }

  @override
  Future<void> close() {
    // Cancel the periodic timer when the cubit is closed.
    timer.cancel();
    return super.close();
  }
}
