import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gallery_app/screen/upload_screen.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({Key? key}) : super(key: key);

  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gallery App'),
    actions: [
    IconButton(onPressed: (){
    Navigator.push(context, MaterialPageRoute(builder: (context) => UploadScreen()));
    },
    icon: Icon(Icons.add),
    )
    ],
    ),
    body: Container(
      padding:  const EdgeInsets.all(8),
      child: StreamBuilder<QuerySnapshot>(
        stream: _firebaseFirestore.collection("images").snapshots(),
      builder: (context, snapshot){
          return snapshot.hasError ? Center(child: Text("There is some problem loding your images"),) :
              snapshot.hasData ?
                  GridView.count(crossAxisCount: 2,mainAxisSpacing: 16,crossAxisSpacing: 16, childAspectRatio: 1,
                    children: snapshot.data!.docs.map((e) => Image.network(e.get("url"))).toList(),
                  ) : Container();
    },
    ),
    ),

    );
  }
}
