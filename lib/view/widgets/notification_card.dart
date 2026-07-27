import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

import '../../controller/const/colors.dart';
import '../../model/notification_model.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;

  const NotificationCard({
    Key? key,
    required this.notification,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    // Get additional FCM data
    final channelId = notification.data?['dChannel_ID']?.toString();
    final language = notification.data?['dLanguage']?.toString();
    final messageId = notification.data?['messageId']?.toString();

    // Optional car linkage carried by locally-generated notifications.
    // `carId` mirrors `notification.postCode` (also set for these) but is
    // read from `data` to keep the two independent — API-sourced notifications
    // may set `postCode` for other reasons.
    final carId = notification.data?['carId']?.toString();
    final carImageUrl = notification.data?['carImageUrl']?.toString();
    final bool hasCarThumbnail =
        carImageUrl != null && carImageUrl.trim().isNotEmpty;

    return Container(
      margin: EdgeInsets.symmetric(vertical: height * 0.01),
      decoration: BoxDecoration(
        color: AppColors.background(context),
        border: Border.all(
          color: AppColors.divider(context),
          width: 0.8.w,
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      padding: EdgeInsets.symmetric(
        vertical: height * 0.01,
        horizontal: width * 0.02,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  notification.title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.w,
                      color: AppColors.blackColor(context)
                  ),
                ),

                const SizedBox(height: 4),

                // Show channel and language if available
                if (channelId != null || language != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Row(
                      children: [
                        if (channelId != null) ...[
                          Text(
                            'Channel: $channelId',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (language != null) const SizedBox(width: 8),
                        ],
                        if (language != null)
                          Text(
                            'Language: $language',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],


                // Post details — only render when we actually have both a
                // non-empty postCode AND a real notification id. Prevents the
                // "Post Code: null" line for locally-generated entries that
                // don't have a backend notification id.
                if (notification.postCode != null &&
                    notification.postCode!.trim().isNotEmpty &&
                    notification.id != null &&
                    notification.id != 0) ...[
                  Text(
                    'Post Code: ${notification.id}',
                    style: TextStyle(fontSize: 15.w),
                  ),
                  const SizedBox(height: 4),
                ],

                // Car ID line for locally-generated notifications that link to a
                // specific ad (payment success on a car, ad-created summary).
                // Hide for API notifications and for locals without carId.
                if (carId != null &&
                    carId.trim().isNotEmpty &&
                    carId.trim().toLowerCase() != 'null') ...[
                  Text(
                    'Car ID: ${carId.trim()}',
                    style: TextStyle(fontSize: 13.w, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 4),
                ],

                // Status and reason
                if (notification.summaryPL != null) ...[
                  Text(
                      notification.summaryPL!,
                      style:  TextStyle(fontWeight: FontWeight.w500,fontSize: 15.w)
                  ),
                ],
                if (notification.summarySL != null) ...[
                  Text(
                    notification.summarySL!,
                    style:  TextStyle(fontWeight: FontWeight.w500,fontSize: 15.w),
                  ),
                ],
                if (notification.reason?.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Text(
                    notification.reason!,
                    style:  TextStyle(height: 1.4,fontSize: 15.w),
                  ),
                ],

                // Date row
                const SizedBox(height: 10),
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/images/calender.svg',
                      width: 16,
                      color: AppColors.gray,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatDate(notification.date,),
                      style: TextStyle(color: Colors.grey.shade700,fontSize: 15.w),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Trailing car thumbnail (only when a URL/path is attached to the
          // notification). Falls back to a placeholder icon if the load
          // fails, so a broken source never blocks reading the message.
          //
          // Two source kinds are supported:
          //   • Network URLs (`http`/`https`) — sent by the "Request 360"
          //     and "Request Feature" flows, which carry `ad.rectangleImageUrl`.
          //   • Local file paths — sent by the "Ad created" flow, which
          //     forwards the freshly-picked cover-image file (the server
          //     URL is not yet known at that moment).
          if (hasCarThumbnail) ...[
            SizedBox(width: 8.w),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: _buildCarThumbnail(context, carImageUrl),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    try {
      // Notifications are stored as UTC (`DateTime.now().toUtc()` when fired
      // and `.toUtc()` again after parsing from storage). Convert to the
      // user's local timezone before formatting — otherwise a notification
      // fired at 3:00 PM Doha would display as 12:00 PM (UTC).
      final localDate = date.isUtc ? date.toLocal() : date;
      return DateFormat('MMM d, y • h:mm a').format(localDate);
    } catch (e) {
      return date.toString();
    }
  }

  /// Renders the trailing car thumbnail. Uses `Image.network` for `http(s)`
  /// sources and `Image.file` for anything else (treated as a local path,
  /// which is what the "Ad created" flow forwards — a freshly-picked cover
  /// image that hasn't been assigned a server URL yet).
  Widget _buildCarThumbnail(BuildContext context, String source) {
    final bool isNetwork = source.startsWith('http://') ||
        source.startsWith('https://');

    if (isNetwork) {
      return Image.network(
        source,
        width: 70.w,
        height: 70.w,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _thumbnailPlaceholder(context),
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return _thumbnailLoading(context);
        },
      );
    }

    // Local file path — most likely the create-ad cover image before it
    // was uploaded to the server. File might have been evicted from cache
    // between sessions, so we always wrap in errorBuilder.
    return Image.file(
      File(source),
      width: 70.w,
      height: 70.w,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _thumbnailPlaceholder(context),
    );
  }

  Widget _thumbnailPlaceholder(BuildContext context) {
    return Container(
      width: 70.w,
      height: 70.w,
      color: AppColors.divider(context),
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: Colors.grey,
        size: 24,
      ),
    );
  }

  Widget _thumbnailLoading(BuildContext context) {
    return Container(
      width: 70.w,
      height: 70.w,
      color: AppColors.divider(context),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}