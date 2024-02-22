import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kiosk/models/ads.dart';
import 'package:kiosk/repositories/.repositories.dart';
import 'package:kiosk/translations/locale_keys.g.dart';
import 'package:kiosk/widgets/.widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class PromosAds extends StatelessWidget {
  const PromosAds({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context,
          showBackArrow: true,
          title: LocaleKeys.newsPromos.tr(),
          showSubtitle: false,
          showNotifications: false,
          showNewsAndPromo: false),
      body: FutureBuilder<List<Ads>>(
          future: context.read<UserRepository>().getAds(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              Error(
                info: snapshot.error.toString(),
              );
            }
            if (snapshot.hasData) {
              final ads = snapshot.data!;
              return Scrollbar(
                  child: ListView.builder(
                      itemCount: ads.length,
                      itemBuilder: ((context, index) {
                        final content = ads[index];

                        return _buildAd(content, context);
                      })));
            }

            return const LoadingWidget();
          }),
    );
  }

  Container _buildAd(Ads content, BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(0),
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
                alignment: Alignment.center,
                child: Image.network(
                  content.adImage.trim(),
                  fit: BoxFit.fitHeight,
                )),
            ButtonTheme(
              child: ButtonBar(
                children: <Widget>[
                  TextButton(
                      child: const Text('More Info'),
                      onPressed: () async {
                        if (content.adUrl != null.toString()) {
                          await launchUrl(Uri.parse(content.adUrl),
                              mode: LaunchMode.inAppWebView);
                        }
                      }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
