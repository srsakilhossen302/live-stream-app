import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MessageDetailsController extends GetxController {
  final messages = <Map<String, dynamic>>[
    {
      "isDate": true,
      "message": "YESTERDAY",
    },
    {
      "isMe": false,
      "message": "Hey! I just saw your bid win. I'll get the pack ready for shipping first thing tomorrow morning.",
      "time": "10:42 PM",
    },
    {
      "isMe": true,
      "message": "Perfect, thanks! Please ensure it's packed in a hard sleeve. It's for my personal vault.",
      "time": "10:45 PM",
      "isRead": true,
    },
    {
      "isDate": true,
      "message": "TODAY",
    },
    {
      "isMe": false,
      "message": "Just dropped it off! Tracking should update in a few hours. I used a double-layered bubble mailer plus the hard sleeve as requested.",
      "time": "11:15 AM",
    },
    {
      "isMe": true,
      "message": "That's awesome. Truly appreciate the extra care with the packaging. I'll keep an eye out!",
      "time": "11:20 AM",
      "isRead": true,
    },
  ].obs;

  final chatInputController = TextEditingController();
  final scrollController = ScrollController();

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    messages.add({
      "isMe": true,
      "message": text.trim(),
      "time": "Now",
      "isRead": false,
    });
    chatInputController.clear();
    _scrollToBottom();

    // Auto response demo
    Future.delayed(const Duration(seconds: 1), () {
      messages.add({
        "isMe": false,
        "message": "Got it! Let me know if there's anything else you need. Enjoy your cards! 🎴✨",
        "time": "Now",
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void onClose() {
    chatInputController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
