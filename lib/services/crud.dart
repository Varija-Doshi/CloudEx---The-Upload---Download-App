import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class CrudMethods {
  var user = FirebaseAuth.instance.currentUser ;
  bool isLoggedin() {
    if (user != null) {
      return true;
    } else
      return false;
  }

  Future<void> addData(String username, data) async {
    print("username passed to addData " + username);
    var collectionRef = FirebaseFirestore.instance.collection(username);
    collectionRef.add(data).then((_) {
      print("File added in Cloud firestore");
    }).catchError((e) {
      print("error in addData $e");
    });
  }

  getData(String username) async {
     await Firebase.initializeApp();
    return FirebaseFirestore.instance.collection(username).snapshots();
  }

  deleteData(username, docId) {
   FirebaseFirestore.instance
        .collection(username)
        .doc(docId)
        .delete()
        .catchError((e) {
      print(e);
    });
  }
}
