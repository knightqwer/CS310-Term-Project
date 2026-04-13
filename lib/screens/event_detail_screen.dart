import 'package:flutter/material.dart';

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[400], // matching that darker background from the sketch
      appBar: AppBar(
        backgroundColor: Colors.transparent, // making the bar invisible to blend in
        elevation: 0, // removing the shadow line
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context), // just going back to the last page
        ),
        title: const Text(
          'Event Details',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView( // making it scrollable so it doesn't break on small screens
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.grey[300], // this is that lighter grey card in the middle
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container( // that little green upcoming tag at the top
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Upcoming',
                    style: TextStyle(color: Colors.green, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 16),
                const Text( // main header for the event
                  'Study Session',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                _buildInfoRow(Icons.calendar_today, 'Date & Time', 'Apr 12, 2026 | 14:00'), // showing the time
                _buildInfoRow(Icons.location_on, 'Location', 'Information Center, Room 204'), // showing the place
                _buildInfoRow(Icons.person, 'Organizer', 'Name Surname'), // who made it
                _buildInfoRow(Icons.groups, 'Attendees', '8/20 registered'), // checking the count
                const SizedBox(height: 24),
                const Text( // section title for the description
                  'About this Event',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text( // this is the bio text the user wrote
                  'This text includes whatever the organizer wrote in the bio part. '
                      '"Come join us for this event" - "I need some help prepping for an exam" '
                      '- "I want some company/meet new people"',
                  style: TextStyle(color: Colors.black87, height: 1.4),
                ),
                const SizedBox(height: 24),
                const Text( // header for the tags list
                  'Associated Tags',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Wrap( // using wrap so tags flow to the next line if they are too long
                  spacing: 8,
                  children: [
                    _buildTag('Social'),
                    _buildTag('Other'),
                    _buildTag('Study'),
                    _buildTag('Sports'),
                  ],
                ),
                const SizedBox(height: 40),
                Row( // putting the register button and chat next to each other
                  children: [
                    Expanded( // making the button stretch to fill the space
                      child: ElevatedButton(
                        onPressed: () {}, // doing nothing for now since it is just ui
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Register', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container( // wrapping the icon in a box to style it
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.chat_bubble_outline, color: Colors.black),
                        onPressed: () {}, // empty button for the chat
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) { // reusable row for the icons and text
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.black54), // the little icon on the left
          const SizedBox(width: 12),
          Column( // stacking the label on top of the actual info
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)), // small grey label
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)), // actual info text
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label) { // reusable widget for those pill shaped tags
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black45),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}