import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:kiosk/extensions/.extensions.dart';
import 'package:kiosk/models/news_feed.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:sizedbox_extention/sizedbox_extention.dart';

class NewsFeedDetails extends StatelessWidget {
  final NewsFeed news;
  const NewsFeedDetails({Key? key, required this.news}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // context
    //     .read<AnalyticsService>()
    //     .logNewsFeedClicked({"Id": news.id, "Title": news.title});

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.loose,
                children: [
                  CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: news.image,
                    placeholder: (context, url) => Center(
                      child: SpinKitFoldingCube(
                        color: context.theme.colorScheme.primary,
                        size: 15,
                      ),
                    ),
                    errorWidget: (context, url, error) => const SizedBox(),
                  ),
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                    child: Container(
                      decoration:
                          BoxDecoration(color: Colors.white.withOpacity(0.0)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
              child: Column(
                children: [
                  CachedNetworkImage(
                    imageUrl: news.image,
                    placeholder: (context, url) => Center(
                      child: SpinKitFoldingCube(
                        color: context.theme.colorScheme.primary,
                        size: 15,
                      ),
                    ),
                    errorWidget: (context, url, error) => const SizedBox(),
                  ),
                  CustomContainer(
                    margin:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        10.h.height,
                        Text(
                          news.title,
                          textAlign: TextAlign.left,
                          style: context.theme.textTheme.titleLarge!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 5.r),
                          child: Text(
                            news.content,
                            textAlign: TextAlign.justify,
                            style: context.theme.textTheme.bodyMedium,
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
