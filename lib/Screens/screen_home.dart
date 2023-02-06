import 'dart:convert';
import 'package:chat_gpt/constand.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late bool isLoading;
  final TextEditingController _textController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _message = [];
  @override
  void initState() {
    super.initState();
    isLoading = false;
  }

  Future<String> generateResponse(String query) async {
    const apiKey = apiSecretkey;
    var url = Uri.https("api.openai.com", "/v1/completions");

    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $apiKey",
    };

    final body = jsonEncode({
      "model": "text-davinci-003",
      "prompt": query,
      "temperature": 0,
      "max_tokens": 2000,
      "top_p": 1,
      "frequency_penalty": 0.0,
      "presence_penalty": 0.0
    });
    final response = await http.post(url, headers: headers, body: body);
    Map<String, dynamic> newreponse = jsonDecode(response.body);
    return newreponse["choices"][0]["text"];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Center(child: Text("Chat GPT")),
        ),
        backgroundColor: const Color.fromARGB(255, 50, 53, 53),
        body: Column(
          children: [
            Expanded(child: _buildList()),
            Visibility(
              visible: isLoading,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(
                  color: Colors.amber,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  _buildInput(),
                  _buildSubmit(),
                ],
              ),
            ),
            // _buildList(),
          ],
        ),
      ),
    );
  }

  Expanded _buildInput() {
    return Expanded(
        child: TextField(
      textCapitalization: TextCapitalization.sentences,
      style: const TextStyle(color: Colors.white),
      controller: _textController,
      decoration: const InputDecoration(
          fillColor: Color.fromARGB(255, 96, 96, 96),
          filled: true,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none),
    ));
  }

  Widget _buildSubmit() {
    return Visibility(
        child: Container(
      color: Colors.amber,
      child: IconButton(
        onPressed: () {
          setState(() {
            _message.add(ChatMessage(
                text: _textController.text,
                chatMessageType: ChatMessageType.user));
            isLoading = true;
          });
          var input = _textController.text;
          _textController.clear();
          Future.delayed(const Duration(milliseconds: 50))
              .then((value) => _scrollDown());

          generateResponse(input).then((value) {
            setState(() {
              isLoading = false;
              _message.add(ChatMessage(
                  text: value, chatMessageType: ChatMessageType.bot));
            });
          });
          _textController.clear();
          Future.delayed(const Duration(milliseconds: 50))
              .then((value) => _scrollDown());
        },
        icon: const Icon(Icons.send_rounded),
      ),
    ));
  }

  void _scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  ListView _buildList() {
    return ListView.builder(
        itemCount: _message.length,
        controller: _scrollController,
        itemBuilder: (context, index) {
          var message = _message[index];
          return ChatMessagesWidgeet(
            text: message.text,
            chatMessageType: message.chatMessageType,
          );
        });
  }
}

class ChatMessagesWidgeet extends StatelessWidget {
  final String text;
  final ChatMessageType chatMessageType;
  ChatMessagesWidgeet(
      {super.key, required this.text, required this.chatMessageType}) {}

  // const ChatMessagesWidgeet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      color: chatMessageType == ChatMessageType.bot
          ? const Color.fromARGB(255, 21, 103, 78)
          : const Color.fromARGB(255, 17, 98, 98),
      child: Row(
        children: [
          chatMessageType == ChatMessageType.bot
              ? Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: CircleAvatar(
                    backgroundColor: Colors.blueGrey,
                    child: Image.asset(
                      "assets/cartoon-robot-free.jpg",
                      // color: Color.fromARGB(255, 154, 16, 16),
                      scale: 1.5,
                    ),
                  ),
                )
              : Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: const CircleAvatar(child: Icon(Icons.person)),
                ),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8))),
                child: Text(
                  text,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: Colors.white),
                ),
              )
            ],
          ))
        ],
      ),
    );
  }
}
