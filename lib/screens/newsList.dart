import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NewsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('news')
          .orderBy('timestamp', descending: true)
          .limit(2) // Limit to the latest two news items
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(color: Colors.deepPurpleAccent),
          );
        }

        final newsList = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          itemCount: newsList.length,
          itemBuilder: (context, index) {
            final news = newsList[index].data() as Map<String, dynamic>;
            final newsId = newsList[index].id;
            final newsContent = news['newsContent'] as String;
            final newsLogoUrl = news['newsLogo'] as String;

            return Card(
              color: Color(0xffFEAF3E),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Image
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Color(0xffFEAF3E),
                        backgroundImage: newsLogoUrl != null
                            ? NetworkImage('$newsLogoUrl')
                                as ImageProvider<Object>
                            : AssetImage('assets/images/news.png'),
                      ),
                      SizedBox(width: 10),
                      // News Text
                      Expanded(
                        child: Text(
                          newsContent,
                          style: TextStyle(fontFamily: 'karla', fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
