enum MyTradeStatus { shipped, pending, completed }

class MyTradeModel {
  final String tradeId;
  final String title;
  final String item1Image;
  final String item2Image;
  final String traderName;
  final String? traderAvatar;
  final String? date;
  final MyTradeStatus status;

  MyTradeModel({
    required this.tradeId,
    required this.title,
    required this.item1Image,
    required this.item2Image,
    required this.traderName,
    this.traderAvatar,
    this.date,
    required this.status,
  });
}
