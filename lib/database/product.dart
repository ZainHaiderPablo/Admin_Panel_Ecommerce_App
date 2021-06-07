

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

class ProductService {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String ref = 'Products' ;

  void uploadProduct(Map<String, dynamic> data){
    var id = Uuid();
    String productId = id.v1();
    data["id"] = productId;
    _firestore.collection(ref).doc(productId).set(data);
  }



}