import 'dart:async';
import 'package:flutter/material.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:lottie/lottie.dart';
import '../../../../models/event_model.dart';
import '../../../../services/firestore_service.dart';
import 'event_tools/event_details_screen.dart';
import 'event_tools/addevent_screen.dart';
import 'event_tools/searchevent_screen.dart';
import '../../navigation_drawer.dart' as custom;

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  EventsScreenState createState() => EventsScreenState();
}

class EventsScreenState extends State<EventsScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> _refreshEvents() async {
    await Future.delayed(const Duration(seconds: 2));
  }

  void _showAddEventBottomSheet() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
            child: AddEventScreen(),
          ),
        ),
      );
    },
  );
}


  bool isGridView = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const custom.NavigationDrawer(),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('Events'),
        actions: [
          IconButton(
            tooltip: isGridView ? 'List view' : 'Grid view',
            icon: Icon(isGridView ? Icons.view_agenda : Icons.grid_view),
            onPressed: () {
              setState(() {
                isGridView = !isGridView;
              });
            },
          ),
          StreamBuilder<List<Event>>(
            stream: _firestoreService.getEvents(),
            builder: (context, snapshot) {
              return IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  if (snapshot.hasData) {
                    showSearch(
                      context: context,
                      delegate: EventSearch(snapshot.data!),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
      body: CustomRefreshIndicator(
        offsetToArmed: 150.0,
        onRefresh: _refreshEvents,
        autoRebuild: false,
        child: StreamBuilder<List<Event>>(
          stream: _firestoreService.getEvents(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  Center(
                    heightFactor: 10,
                    child: Text('No events found'),
                  ),
                ],
              );
            }

            if (isGridView) {
              return GridView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 0.50,
                ),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final event = snapshot.data![index];
                  return EventCard(
                    title: event.title,
                    date: event.date,
                    description: event.description,
                    imageUrl: event.imageUrl,
                    author: event.author,
                  );
                },
              );
            } else {
              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final event = snapshot.data![index];
                  return EventCard(
                    title: event.title,
                    date: event.date,
                    description: event.description,
                    imageUrl: event.imageUrl,
                    author: event.author,
                  );
                },
              );
            }
          },
        ),
        builder: (
          BuildContext context,
          Widget child,
          IndicatorController controller,
        ) {
          return Stack(
            children: <Widget>[
              AnimatedBuilder(
                animation: controller,
                builder: (BuildContext context, Widget? _) {
                  return SizedBox(
                    height: controller.value * 150.0,
                    child: Stack(
                      children: <Widget>[
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Transform.translate(
                              offset: Offset(0, controller.value * 40.0),
                              child: Lottie.asset(
                                'lib/assets/loading/NfcLoading.json',
                                repeat: controller.isLoading,
                                height: 80.0,
                                width: 80.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              AnimatedBuilder(
                builder: (context, _) {
                  return Transform.translate(
                    offset: Offset(0.0, controller.value * 150.0),
                    child: child,
                  );
                },
                animation: controller,
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventBottomSheet,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// EventCard widget remains the same
class EventCard extends StatelessWidget {
  final String title;
  final String date;
  final String description;
  final String imageUrl;
  final String author;

  const EventCard({
    super.key,
    required this.title,
    required this.date,
    required this.description,
    required this.imageUrl,
    required this.author,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailsScreen(
              title: title,
              date: date,
              description: description,
              imageUrl: imageUrl,
              author: author,
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 4.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12.0)),
              child: Image.network(
                imageUrl,
                height: 180.0,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    date,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Author: $author',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
