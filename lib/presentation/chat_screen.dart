import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../controller/chat_controller.dart';
import '../models/message_models.dart';
import 'widgets/message_item.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  ChatController chatController = ChatController();
  late io.Socket socket;

  Color purple = const Color(0xff6c5ce7);
  Color black = const Color(0xff191919);
  TextEditingController msgInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initSocket();
  }

  initSocket() {
    socket = io.io(
      'http://localhost:4000',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket.connect();
    socket.onConnect((_) => debugPrint('Connection established'));
    socket.onDisconnect((_) => debugPrint('Connection Disconnection'));
    socket.onConnectError((err) => debugPrint('$err'));
    socket.onError((err) => debugPrint('$err'));

    setUpSocketListener();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: black,
      body: SizedBox(
        child: Column(
          children: [
            Expanded(
              child: Obx(
                () => Container(
                  margin: const EdgeInsets.all(10),
                  child: Text(
                    'Connected user ${chatController.connectedUser}',
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 9,
              child: Obx(
                () => ListView.builder(
                  itemCount: chatController.chatMessages.length,
                  itemBuilder: (context, index) {
                    final currentItem = chatController.chatMessages[index];
                    return MessageItem(
                      message: currentItem.message,
                      sentByMe: currentItem.sentByMe == socket.id,
                    );
                  },
                ),
              ),
            ),
            Expanded(
              child: SizedBox(
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  cursorColor: purple,
                  controller: msgInputController,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: IconButton(
                        onPressed: () {
                          sendMessage(msgInputController.text);
                        },
                        icon: const Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void sendMessage(String text) {
    var messageJson = {
      "message": text,
      "sentByMe": socket.id,
    };
    socket.emit('message', messageJson);
    chatController.chatMessages.add(Message.fromJson(messageJson));
  }

  void setUpSocketListener() {
    socket.on('message-receive', (data) {
      debugPrint('message receive $data');
      chatController.chatMessages.add(Message.fromJson(data));
    });

    socket.on('connected-user', (data) {
      debugPrint('message receive $data');
      chatController.connectedUser.value = data;
    });
  }
}
