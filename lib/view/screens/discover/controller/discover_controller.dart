import 'package:get/get.dart';

class DiscoverController extends GetxController {
  var selectedFilter = 0.obs;
  final filters = ["All", "Live Shows", "Trade Market"];

  // Dummy Data Lists for API integration later
  final liveShows = [
    {
      "title": "Rare Pokémon Card Auction",
      "host": "Hosted by NeoCollects",
      "viewers": "1.2K",
      "image": "https://images.unsplash.com/photo-1614850523296-d8c1af93d400?q=80&w=1000&auto=format&fit=crop",
    },
    {
      "title": "Vintage Tech & Mod Gear",
      "host": "Hosted by RetroFuture",
      "viewers": "854",
      "image": "https://images.unsplash.com/photo-1550745165-9bc0b252726f?q=80&w=1000&auto=format&fit=crop",
    },
  ].obs;

  final featuredLiveItems = [
    {
      "category": "ROLEX",
      "title": "Submariner Date",
      "price": "\$12,450",
      "image": "https://images.unsplash.com/photo-1523170335258-f5ed11844a49?q=80&w=400",
      "badge": "PROMOTED",
    },
    {
      "category": "POKÉMON",
      "title": "Charizard 1st Ed",
      "price": "\$8,200",
      "image": "https://images.unsplash.com/photo-1613771404721-1f92d799e49f?q=80&w=400",
      "badge": "FEATURED",
    },
  ].obs;

  final featuredTrades = [
    {
      "title": "Jordan 1 Retro High '85",
      "price": "Starting Est. \$1,200",
      "image": "https://images.unsplash.com/photo-1552346154-21d32810aba3?q=80&w=1000&auto=format&fit=crop",
    },
    {
      "title": "Rolex Submariner Date",
      "price": "Starting Est. \$14,500",
      "image": "https://images.unsplash.com/photo-1523170335258-f5ed11844a49?q=80&w=1000&auto=format&fit=crop",
    },
  ].obs;

  final tradeMarketItems = [
    {
      "title": "Vintage Pokémon Card Pack",
      "value": "\$200",
      "lookingFor": "Equal value cards",
      "tag": "NEAR MINT",
      "image": "https://images.unsplash.com/photo-1613771404721-1f92d799e49f?q=80&w=500&auto=format&fit=crop",
    },
    {
      "title": "Rare SB Dunks 'Purple'",
      "value": "\$850",
      "lookingFor": "Yeezy 350 + Cash",
      "tag": "NEW",
      "image": "https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?q=80&w=500&auto=format&fit=crop",
    },
  ].obs;

  final topSellers = [
    {
      "rank": "01",
      "name": "EliteVault",
      "rating": "99% Positive",
      "image": "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=200",
    },
    {
      "rank": "02",
      "name": "SoleConnect",
      "rating": "98% Positive",
      "image": "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200",
    },
  ].obs;

  final trendingTags = ["#jordan1", "#charizard-psa10", "#rolex-daytona", "#grail-sneakers", "#luxury-trading"].obs;

  void changeFilter(int index) {
    selectedFilter.value = index;
  }
}
