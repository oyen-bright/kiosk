// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'notification_cubit.dart';

enum NotificationStatus { initial, loading, loaded, error }

class NotificationState extends Equatable {
  final int newNotificationCount;
  final NotificationStatus notificationStatus;
  final List<NewsFeed>? newsFeeds;
  final List<Map<String, dynamic>>? notification;
  final String errorMessage;
  const NotificationState(
      {this.newNotificationCount = 0,
      this.notificationStatus = NotificationStatus.initial,
      this.errorMessage = "",
      this.notification,
      this.newsFeeds});

  @override
  List<Object?> get props => [
        newNotificationCount,
        notificationStatus,
        notification,
        newsFeeds,
        errorMessage,
      ];

  NotificationState copyWith({
    int? newNotificationCount,
    List<Map<String, dynamic>>? notification,
    NotificationStatus? notificationStatus,
    List<NewsFeed>? newsFeeds,
    String? errorMessage,
  }) {
    return NotificationState(
      notification: notification ?? this.notification,
      newNotificationCount: newNotificationCount ?? this.newNotificationCount,
      notificationStatus: notificationStatus ?? this.notificationStatus,
      newsFeeds: newsFeeds ?? this.newsFeeds,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool get stringify => true;
}
