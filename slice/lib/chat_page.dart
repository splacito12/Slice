import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:slice/widgets/video_bubble.dart';
import 'package:slice/services/media_service.dart';
import 'package:slice/services/message_service.dart';

class ChatPage extends StatefulWidget {
  final String convoId;
  final String currUserId;
  final String currUserName;
  final String? chatPartnerId;
  final String? chatPartnerUsername;
  final bool isGroupChat;
  final String? groupName;
  final List<String>? chatMembers;

  final MediaService? mediaService;
  final MessageService? messageService;
  final FirebaseFirestore? firestore;

  const ChatPage({
    super.key,
    required this.convoId,
    required this.currUserId,
    required this.currUserName,
    this.chatPartnerId,
    this.chatPartnerUsername,
    this.isGroupChat = false,
    this.groupName,
    this.chatMembers,
    this.mediaService,
    this.messageService,
    this.firestore,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textEditingController = TextEditingController();

  late MediaService _mediaService;
  late MessageService _messageService;
  late FirebaseFirestore _firebaseFirestore;

  @override
  void initState() {
    super.initState();
    _mediaService = widget.mediaService ?? MediaService();
    _messageService = widget.messageService ?? MessageService();
    _firebaseFirestore = widget.firestore ?? FirebaseFirestore.instance;
  }

  // ------------------------------
  //       LEAVE GROUP
  // ------------------------------
  Future<void> _leaveGroup() async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Leave Group"),
        content: const Text("Are you sure you want to leave this group?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Leave", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection("chats")
          .doc(widget.convoId)
          .update({
        "members": FieldValue.arrayRemove([widget.currUserId])
      });

      if (mounted) Navigator.pop(context);
    }
  }

  // ------------------------------
  //       SEND MESSAGE
  // ------------------------------
  Future<void> _sendMessage({
    String? text,
    File? file,
    String? mediaType,
  }) async {
    if ((text == null || text.trim().isEmpty) && file == null) return;

    String mediaUrl = "";
    if (file != null && mediaType != null) {
      mediaUrl = await _mediaService.uploadMedia(
        file: file,
        convoId: widget.convoId,
      );
    }

    await _messageService.messageSend(
      convoId: widget.convoId,
      senderId: widget.currUserId,
      senderName: widget.currUserName,
      text: text ?? "",
      mediaType: mediaType,
      mediaUrl: mediaUrl,
    );

    _textEditingController.clear();

    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(
          _scrollController.position.maxScrollExtent,
        );
      }
    });
  }

  Future<void> _pickMedia(bool isImage) async {
    File? file = await _mediaService.pickMedia(isImage);
    if (file == null) return;

    await _sendMessage(file: file, mediaType: isImage ? "image" : "video");
  }

  @override
  Widget build(BuildContext context) {
    final messageRef = _firebaseFirestore
        .collection("chats")
        .doc(widget.convoId)
        .collection("messages")
        .orderBy("timestamp", descending: false);

    final title = widget.isGroupChat
        ? (widget.groupName ?? "Group Chat")
        : (widget.chatPartnerUsername ?? "Chat");

    return Scaffold(
      backgroundColor: const Color(0xFFE9FADD),

      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: Text(title, style: const TextStyle(color: Colors.white)),

        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),

        actions: [
          if (widget.isGroupChat)
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              tooltip: "Leave Group",
              onPressed: _leaveGroup,
            ),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: messageRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final msg = docs[index].data() as Map<String, dynamic>;
                    final isMe = msg["senderId"] == widget.currUserId;

                    // Group name above messages
                    Widget senderLabel = const SizedBox.shrink();
                    if (widget.isGroupChat && !isMe) {
                      senderLabel = Padding(
                        padding: const EdgeInsets.only(left: 8, bottom: 3),
                        child: Text(
                          msg["senderName"] ?? "Unknown",
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      );
                    }

                    // BUBBLES
                    Widget bubble;

                    if (msg["mediaType"] == null ||
                        msg["mediaType"] == "") {
                      bubble = BubbleSpecialOne(
                        isSender: isMe,
                        text: msg["text"] ?? "",
                        color: isMe
                            ? const Color(0xFFD0F6C1)
                            : const Color(0xFFFFD8DF),
                      );
                    } else if (msg["mediaType"] == "image") {
                      bubble = BubbleNormalImage(
                        id: msg["senderId"],
                        image: Image.network(msg["mediaUrl"]),
                        color: Colors.transparent,
                      );
                    } else if (msg["mediaType"] == "video") {
                      bubble = VideoBubble(
                        videoUrl: msg["mediaUrl"],
                        isSender: isMe,
                      );
                    } else {
                      bubble = const SizedBox.shrink();
                    }

                    return Column(
                      crossAxisAlignment: isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        senderLabel,
                        bubble,
                      ],
                    );
                  },
                );
              },
            ),
          ),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: MessageBar(
              onSend: (text) => _sendMessage(text: text),
              messageBarHintText: "Type a message...",
              actions: [
                IconButton(
                  icon: const Icon(Icons.image, color: Colors.grey),
                  onPressed: () => _pickMedia(true),
                ),
                IconButton(
                  icon: const Icon(Icons.video_library, color: Colors.grey),
                  onPressed: () => _pickMedia(false),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
