import 'package:flutter/material.dart';
import 'event_details_screen.dart';
import '../../../../../models/event_model.dart';

class EventSearch extends SearchDelegate<Event?> {
  final List<Event> events;

  EventSearch(this.events);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = events.where((event) {
      final titleLower = event.title.toLowerCase();
      final descriptionLower = event.description.toLowerCase();
      final searchLower = query.toLowerCase();

      return titleLower.contains(searchLower) || 
             descriptionLower.contains(searchLower);
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final event = suggestions[index];
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              event.imageUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(event.title),
          subtitle: Text(event.description),
          onTap: () {
            close(context, event);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventDetailsScreen(
                  title: event.title,
                  date: event.date,
                  description: event.description,
                  imageUrl: event.imageUrl,
                  author: event.author,
                ),
              ),
            );
          },
        );
      },
    );
  }
}