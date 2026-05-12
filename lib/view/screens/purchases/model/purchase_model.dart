import 'package:flutter/material.dart';

enum OrderStatus { inTransit, delivered, processing, cancelled }

class PurchaseModel {
  final String id;
  final String title;
  final String curator;
  final String date;
  final String price;
  final String carrier;
  final String image;
  final String trackingId;
  final OrderStatus status;

  PurchaseModel({
    required this.id,
    required this.title,
    required this.curator,
    required this.date,
    required this.price,
    required this.carrier,
    required this.image,
    required this.trackingId,
    required this.status,
  });
}
