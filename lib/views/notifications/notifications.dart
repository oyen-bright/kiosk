import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/cubits/notifications/notification_cubit.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/models/news_feed.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'notification_news_feed.dart';

class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  @override
  void initState() {
    context.read<NotificationCubit>().resetNotificationCount();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs (notifications and news feeds)
      child: Scaffold(
        appBar: customAppBar(
          context,
          title: LocaleKeys.notificaitons.tr(),
          showBackArrow: true,
          showSubtitle: false,
          showNewsAndPromo: false,
          showNotifications: false,
        ),
        body: Builder(builder: (context) {
          final RefreshController _refreshController = RefreshController();

          return SmartRefresher(
            onRefresh: () async {
              try {
                await context.read<NotificationCubit>().getNewsFeeds();
                _refreshController.refreshCompleted();
              } catch (e) {
                context.snackBar(e.toString());
                _refreshController.refreshFailed();
              }
            },
            controller: _refreshController,
            child: BlocConsumer<NotificationCubit, NotificationState>(
              listener: (context, state) async {
                if (state.notificationStatus == NotificationStatus.error) {
                  context.snackBar(state.errorMessage);
                  context.read<NotificationCubit>().getNewsFeeds();
                }
              },
              builder: (context, state) {
                // Your existing notification content
                return Stack(
                  children: [
                    Builder(builder: (_) {
                      if (state.newsFeeds != null) {
                        List<NewsFeed> newsFeeds = state.newsFeeds!;

                        return ListView.builder(
                          // controller: _scrollController,
                          itemCount: newsFeeds.length,
                          itemBuilder: (context, int index) {
                            final data = newsFeeds[index];

                            return Padding(
                              padding: EdgeInsets.all(2.r),
                              child: GestureDetector(
                                onTap: () {
                                  pushNewScreen(context,
                                      screen: NewsFeedDetails(
                                        news: data,
                                      ),
                                      withNavBar: false);
                                },
                                child: Card(
                                  color: Colors.transparent,
                                  elevation: 0,
                                  child: ListTile(
                                    contentPadding: EdgeInsets.all(1.r),
                                    leading: SizedBox(
                                      width: 90.w,
                                      child: CachedNetworkImage(
                                          imageUrl: data.image,
                                          placeholder: (context, _) =>
                                              Image.asset(
                                                "assets/images/logo_app.png",
                                                fit: BoxFit.fitHeight,
                                              ),
                                          errorWidget: (context, url, error) =>
                                              Image.asset(
                                                "assets/images/logo_app.png",
                                                fit: BoxFit.cover,
                                              )),
                                    ),
                                    title: Text(
                                      data.title,
                                      style: context.theme.textTheme.bodyLarge!
                                          .copyWith(
                                              fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: AutoSizeText(
                                      data.content,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: context.theme.textTheme.bodySmall,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }
                      return Container();
                    }),
                    Visibility(
                      child: const LoadingWidget(),
                      visible: state.newsFeeds == null,
                    )
                  ],
                );
              },
            ),
          );
        }),

        // Content of the 'News Feed' tab
        // You can implement a similar SmartRefresher, BlocConsumer, and ListView for news feeds.
        // ...
      ),
    );
  }
}
