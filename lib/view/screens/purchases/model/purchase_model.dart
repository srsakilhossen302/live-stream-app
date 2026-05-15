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
  
  final String? estimatedDelivery;
  final String? location;
  final double? itemPrice;
  final double? shippingPrice;
  final double? taxes;
  final double? processingFee;
  final double? buyerContribution;
  final double? totalPaid;
  final int trackingStep; // 1=Order Placed, 2=Processing, 3=Shipped, 4=Out for Delivery, 5=Delivered

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
    this.estimatedDelivery,
    this.location,
    this.itemPrice,
    this.shippingPrice,
    this.taxes,
    this.processingFee,
    this.buyerContribution,
    this.totalPaid,
    this.trackingStep = 1,
  });
}
