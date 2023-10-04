import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff6555FE),
        centerTitle: true,
        title: Text(
          'Announcements',
          style: TextStyle(
            fontFamily: 'karla',
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('announcements')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            if (!snapshot.hasData) {
              return Center(
                child:
                    CircularProgressIndicator(color: Colors.deepPurpleAccent),
              );
            }

            final announcementList = snapshot.data!.docs;

            return ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              itemCount: announcementList.length,
              itemBuilder: (context, index) {
                final announcements =
                    announcementList[index].data() as Map<String, dynamic>;
                final newsId = announcementList[index].id;
                final newsContent = announcements['announcement'] as String;

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: Color(0xffFFF9F0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            '$newsContent',
                            textAlign: TextAlign.justify,
                            style: TextStyle(fontSize: 16, fontFamily: 'karla'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
