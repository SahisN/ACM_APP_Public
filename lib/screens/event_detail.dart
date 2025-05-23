import 'package:acm_app/provider/favorite_event_provider.dart';
import 'package:acm_app/util/set_reminder.dart';
import "package:flutter/material.dart";
import 'package:acm_app/model/event_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:like_button/like_button.dart';

class DetailPage extends ConsumerWidget {
  const DetailPage({super.key, required this.event, d});
  final EventItem event;

  ImageProvider _provideImage() {
    if (event.imageURL == '') {
      return const AssetImage("assets/images/3d_acm_logo.png");
    }
    return NetworkImage(event
        .imageURL); //'https://picsum.photos/id/${getRandomInteger()}/200/300'
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteEvent = ref.watch(favoriteEventProvider);
    final bool isFavorite = favoriteEvent.contains(event);
    final DateTime now = DateTime.now();
    // print(favoriteEvent[0].uid);
    // print(favoriteEvent[0].name);
    // print(favoriteEvent[0].location);
    // print(favoriteEvent[0].imageURL);
    // print(favoriteEvent[0].description);
    // print(favoriteEvent[0].dateTime);
    // print('event: ' + event.uid);
    // print('event: ' + event.name);
    // print('event: ' + event.location);
    // print('event: ' + event.imageURL);
    // print('event: ' + event.description);
    // print(event.dateTime);
    Future<bool?> onLikedButtonTap(bool isLiked) {
      // return Future.value(true);
      final wasAdded =
          ref.read(favoriteEventProvider.notifier).toggleFavoriteStatus(event);

      if (wasAdded) {
        setNotification(event, context);
      } else {
        cancelNotification(event, context);
      }

      // ignore: prefer_const_constructors
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: wasAdded
                ? const Text('Added to Favorite')
                : const Text('Removed from Favorites'),
            duration: const Duration(seconds: 1),
            backgroundColor: wasAdded ? Colors.green : Colors.red),
      );

      return Future.value(wasAdded);
    }

    return Scaffold(
      //The appBar allows the page to return to the calendar page
      //The  Text is just a placeholder, ------ MUST CHANGE THIS -----

      appBar: AppBar(
        title: const Text(""),
        actions: [
          isFavorite ||
                  (now.month <= event.dateTime.month &&
                      now.year <= event.dateTime.year &&
                      now.day < event.dateTime.day)
              ? LikeButton(
                  size: 30,
                  isLiked: isFavorite,
                  onTap: onLikedButtonTap,
                  likeBuilder: (isLiked) {
                    return Icon(
                      Icons.favorite,
                      color: isLiked ? Colors.red : Colors.grey,
                      size: 30,
                    );
                  },
                )
              : const SizedBox(
                  width: 30,
                ),
        ],
      ),
      body: SizedBox(
        width: double.maxFinite,
        height: double.maxFinite,
        child: Stack(
          children: [
            //Positioned holds the image and controls apperance
            Positioned(
              left: 0,
              right: 0,
              child: Container(
                width: double.maxFinite,
                height: 300,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: _provideImage(),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            //controls functionality
            /* 
            need to review over this
             */

            //This positioned holds the content that is found under the image
            Positioned(
                top: 260,
                child: Container(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 30),

                  width: MediaQuery.of(context).size.width,
                  height: 500,
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30))),
                  //Column will be used to organized the content
                  child: Column(
                    children: [
                      //this row will hold title
                      Text(
                        event.name,
                        style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            // display time if the it is NOT 12:00am
                            event.dateTime.hour == 0
                                ? DateFormat('MMMM dd')
                                    .format(event.dateTime.toLocal())
                                : DateFormat('MMMM dd, h:mm a')
                                    .format(event.dateTime.toLocal()),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      event.location == "somewhere"
                          ? const Row()
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.blue,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Flexible(
                                  child: Text(
                                    event.location,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.lightBlue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )

                                //maybe put the time
                              ],
                            ),

                      const SizedBox(
                        height: 30,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Description:",
                          style: TextStyle(
                            fontSize: 20,
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        event.description,
                        style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
