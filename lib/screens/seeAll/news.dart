import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NewsListSeeAll extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: 220,
              padding: EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Color(0xff6555FE),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            )),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "News",
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'karla'),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Hi, Find News about Tournaments.",
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontFamily: 'karla'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('news')
                  .orderBy('timestamp', descending: true)
                  // .limit(2) // Limit to the latest two news items
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                        color: Colors.deepPurpleAccent),
                  );
                }

                final newsList = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
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
                                  style: TextStyle(
                                      fontFamily: 'karla', fontSize: 16),
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
            ),
          ],
        ),
      ),
    );
  }
}
