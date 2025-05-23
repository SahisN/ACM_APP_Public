import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:acm_app/model/event_item.dart';
import 'package:acm_app/widget/event_card.dart';
import 'package:acm_app/services/firebase.dart';

bool isInitialized = false;
bool isExpanded = false;
//Map<DateTime, List<EventItem>> eventMap = {};

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime now = DateTime.now();
  final firstDate = DateTime(DateTime.now().year, DateTime.now().month - 6,
      1); //DateTime(now.year - 1, now.month);
  final lastDay = DateTime.utc(
      DateTime.now().year + 5, 1, 1); //DateTime(now.year + 5, now.month);

  void _onDaySelected(DateTime day, DateTime focusedDay) {
    setState(() {
      now = day;
    });
  }

  // ignore: unused_element
  void _onExpand() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  //TableCalendar eventLoader function
  List<EventItem> _getEvents(DateTime day) {
    DateTime date = DateTime(day.year, day.month, day.day);
    return Database.eventMap[date] ?? [];
  }

  ListView _eventListview() {
    List<EventItem> eventList =
        Database.eventMap[DateTime(now.year, now.month, now.day)] ?? [];

    return ListView.builder(
      itemCount: eventList.length,
      shrinkWrap: true,
      itemBuilder: (_, i) => EventCard(
        eventList[i],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    //initially fetch all events and load to Database.eventMap
    if (isInitialized) return;
    Database.fetchCalendarEvents(firstDate, lastDay).then((value) {
      if (mounted) {
        isInitialized = true;
        setState(() {});
      }
    });
    if (!Database.subscribedToMsg) {
      Database.subscribeToEventUpdates();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          //backgroundColor: Theme.of(context).colorScheme.background,
          title: const Text('Calendar'),
          actions: [
            IconButton(
                onPressed: () {
                  Database.fetchCalendarEvents(firstDate, lastDay)
                      .then((val) => setState(() {}));
                },
                icon: Icon(Icons.refresh)),
            IconButton(
                onPressed: _onExpand,
                icon: Icon(
                    isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down))
          ],
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TableCalendar(
                eventLoader: _getEvents,
                locale: "en_US",
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    color: Theme.of(context).focusColor,
                    fontSize: 22,
                  ),
                ),
                // affects numbers in calendar ex 1 2 3 4
                calendarStyle: CalendarStyle(
                  defaultTextStyle: TextStyle(
                    color: Theme.of(context).focusColor,
                    fontSize: 17,
                  ),
                  // affects days of week in calendar ex mon, tuesday, wed
                  weekendTextStyle: TextStyle(
                    color: Theme.of(context).focusColor,
                  ),
                ),
                // affect weekend of week in calendar ex sat, sun
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    color: Theme.of(context).focusColor,
                  ),
                  weekendStyle: TextStyle(
                    color: Theme.of(context).focusColor,
                  ),
                ),
                availableGestures: AvailableGestures.all,
                selectedDayPredicate: (day) => isSameDay(day, now),
                focusedDay: now,
                firstDay: firstDate,
                lastDay: lastDay,
                onDaySelected: _onDaySelected,
                //onPageChanged: _onPageChanged,
                calendarFormat:
                    isExpanded ? CalendarFormat.month : CalendarFormat.twoWeeks,
              ),
              const SizedBox(height: 15),
              Text(
                'Events',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
              const SizedBox(height: 15),

              //Display Event list if not emtpy, otherwise display "No event" text
              _getEvents(now).isEmpty
                  ? Expanded(
                      child: Text(
                      "No Events for today",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.inversePrimary),
                    ))
                  : Expanded(child: _eventListview())
            ],
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface);
  }
}
