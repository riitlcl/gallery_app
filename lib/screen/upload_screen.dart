
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gallery_app/screen/gallery_screen.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({Key? key}) : super(key: key);

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {

  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  List<UploadTask> uploadedTasks = [];
 List<File> selectedFiles = [];

  uploadFileToStorage(File file) {
    UploadTask task= _firebaseStorage.ref().child("images/${DateTime.now().toString()}").putFile(file);

    return task;
  }
  saveImageUrlToFirebase(UploadTask task) {
    task.snapshotEvents.listen((snapShot) { 
      if(snapShot.state == TaskState.success){
        snapShot.ref.getDownloadURL().then((imageUrl) => writeImageUrlToFireStore(imageUrl));
      }
      
    });
  }
  writeImageUrlToFireStore(String imageUrl) {
    _firebaseFirestore.collection("image").add({"url":imageUrl}).whenComplete(() => print("$imageUrl is saved in Firestore"));
  }
 Future selectFileToUpload() async{
   try{
     FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true, type: FileType.image);
     
     if(result!=null){
       
       selectedFiles.clear();
       result.files.forEach((selectedFile) { 
         File file = File(selectedFile.path as String);
         selectedFiles.add(file);
       });
       
       selectedFiles.forEach((file) { 
         final UploadTask task = uploadFileToStorage(file);

         saveImageUrlToFirebase(task);

         setState(() {
           uploadedTasks.add(task);
         });
       });
       
     }else
       {
         print("User has cancelled!");
       }
   }catch(e){
     
   }
 }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gallery App'),
        actions: [
          IconButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => GalleryScreen()));
    }, icon: Icon(Icons.photo),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed:  (){
            selectFileToUpload();
          },
        child: Icon(Icons.add),
      ),
  body: uploadedTasks.length==0 ? Center(child:Text("Please add pic") )  :
      ListView.separated(itemBuilder: (context, index) {
        return StreamBuilder<TaskSnapshot>(builder: (context, snapShot){
            return snapShot.connectionState == ConnectionState.waiting
                ? CircularProgressIndicator()
                :
                snapShot.hasError
                ? Text("There is some error in uploading file")
                : snapShot.hasData ?
            ListTile(
              title:Text("${snapShot.data!.bytesTransferred}/${snapShot.data!.totalBytes} ${snapShot.data!.state == TaskState.success ? "Completed" : snapShot.data!.state == TaskState.running ? "In progress" : "Error" }"),
            ) : Container();

        },
          stream: uploadedTasks[index].snapshotEvents,

        );
      },
        separatorBuilder: (context, index) => Divider(),
        itemCount: uploadedTasks.length,
      ),
    );
  }
}





