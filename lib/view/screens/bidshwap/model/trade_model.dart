class TradeModel {
  final String userName;
  final String userAvatar;
  final String userRating;
  final String tradesCount;
  final String offeredItemName;
  final String offeredItemValue;
  final String offeredItemImage;
  final String lookingForItemName;
  final String lookingForItemValue;
  final Map<String, dynamic>? rawProduct;

  TradeModel({
    required this.userName,
    required this.userAvatar,
    required this.userRating,
    required this.tradesCount,
    required this.offeredItemName,
    required this.offeredItemValue,
    required this.offeredItemImage,
    required this.lookingForItemName,
    required this.lookingForItemValue,
    this.rawProduct,
  });
}
