import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  String title;
  String desc;
  String vendor;
  String imageUrl;
  double price;
  Timestamp? timestamp;
  ProductModel({
    required this.title,
    required this.desc,
    required this.vendor,
    required this.price,
    required this.imageUrl,
    required this.timestamp,
  });
}

List<ProductModel> templates = [
  ProductModel(
      title: 'Dido cipz zart aurt',
      desc: 'desc',
      vendor: 'Ramadan Kerem',
      price: 4.50,
      imageUrl:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSyUdX6rxNa_ZR1XxeDUsjOjTMsu5Qq2zaRXA&usqp=CAU',
      timestamp: null)
];
