import 'package:flutter/material.dart';

class EventDetailsScreen extends StatelessWidget {
  final String title;
  final String date;
  final String description;
  final String imageUrl;
  final String author;

  const EventDetailsScreen({
    super.key,
    required this.title,
    required this.date,
    required this.description,
    required this.imageUrl,
    required this.author,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.network(
                imageUrl,
                height: 250.0,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              author,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16.0),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8.0),
            Text(
              date,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16.0),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              "Nakakaputanginaaaa",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            
          ],
        ),
      ),
    );
  }
}