import 'dart:convert';
import 'dart:ui';
import 'dart:io';

import 'package:ai_chatbot/model/Bubble.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Bubble> chat = [];
  TextEditingController query = new TextEditingController();
  TextEditingController hostAddressController = new TextEditingController();
  String hostAddress = "";
  bool isWaiting = false;

  void initState(){
    super.initState();
    Bubble intro = new Bubble('Hi I am your AI Assistant,\nHow can I help you?', false);
    chat.add(intro);
    hostAddress = "";
    if(Platform.isAndroid) WebView.platform =SurfaceAndroidWebView();
  }

 Future<dynamic> getBotResponse(String message) async {
    String port = ":5005";
    String host = hostAddress+port;

    var res = await http.post(
     Uri.http(host, '/webhooks/rest/webhook'),
     headers: <String, String>{
       'Content-Type': 'application/json; charset=UTF-8',
     },
     body: jsonEncode(<String, String>{
       'sender': 'aadesh',
       'message': message
     }),
   );
    if(res.statusCode == 200){
      return json.decode(res.body);;
    }
    return null;
 }

  Widget chatBubble(String txt, bool isUser){
    bool isLink = txt.contains('http://', 0) || txt.contains('https://', 0);
    Widget content;
    if(isLink){
      content = Container(
        height: 400,
        width: MediaQuery.of(context).size.width*0.8,
        margin: EdgeInsets.only(top: 5, bottom: 5),
        padding: EdgeInsets.only(left: 15, right: 15, top: 8, bottom: 8),
        decoration: BoxDecoration(
            color: isUser ? Color.fromRGBO(25, 34, 58, 1) : Color.fromRGBO(223, 226, 241, 1),
            borderRadius: BorderRadius.all(Radius.circular(10))
        ),

        child: PageView.builder(
          itemCount: 5,
          itemBuilder: (context, index){
            return ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              child: WebView(
                gestureNavigationEnabled: true,
                javascriptMode: JavascriptMode.unrestricted,
                initialUrl: txt,
                gestureRecognizers: [
                  Factory(()=> VerticalDragGestureRecognizer()),
                ].toSet(),
              )
            );
          }
        ),
      );
    }
    else{
      content = Container(
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width*0.7
          ),
          margin: EdgeInsets.only(top: 5, bottom: 5),
          padding: EdgeInsets.only(left: 15, right: 15, top: 8, bottom: 8),
          decoration: BoxDecoration(
              color: isUser ? Color.fromRGBO(25, 34, 58, 1) : Color.fromRGBO(223, 226, 241, 1),
              borderRadius: BorderRadius.all(Radius.circular(10))
          ),
          child: Text(
            txt,
            textAlign: TextAlign.left,
            style: TextStyle(color: isUser ? Colors.white: Color.fromRGBO(25, 34, 58, 1), fontSize: 20),
          )
      );
    }
    return Row(
      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isUser) ClipRRect( borderRadius: BorderRadius.all(Radius.circular(50)), child: Image.asset('images/logo.jpg', width: 40)),
        content,
        if(isUser) Padding( padding: EdgeInsets.only(left: 5), child: ClipRRect(borderRadius: BorderRadius.all(Radius.circular(50)), child: Image.asset('images/user.png',width: 40))),
      ],
    );
  }

  Widget chatUI(){
    List<Widget> col = [];

    for(int i=0; i<chat.length; i++){
      col.add(chatBubble(chat[i].message, chat[i].isUser));
    }
    if(isWaiting){
      col.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset('images/logo.jpg', width: 40),
            Image.asset('images/typing.gif', width: 120)
        ],)
      );
    }
    return Column(
        children: col
    );
  }

  void addResponseToChat(var data){
      Bubble b = new Bubble(data[0]["text"], false);
      setState(() {
        chat.add(b);
      });
  }

  void sendReq() async{
    String question = query.text.toLowerCase();
    Bubble b;
    b = new Bubble(query.text, true);
    setState(() {
      chat.add(b);
    });

    if(question.contains('search')){
      question = question.replaceAll("search", "");
      question = question.replaceAll(" ", "+");

      b = new Bubble("https://google.com/search?q="+question, false);
      setState(() {
        chat.add(b);
      });
    }
    else if(question.contains('youtube') || question.contains('video') || question.contains('play')){
      question = question.replaceAll("youtube", " ");
      question = question.replaceAll("video", " ");
      question = question.replaceAll("play", " ");

      question = question.replaceAll(" ", "+");
      b = new Bubble("https://www.youtube.com/results?search_query="+question, false);
      setState(() {
        chat.add(b);
      });
    }
    else{
      if(question.isNotEmpty){
        query.text = "";
        setState(() {
          isWaiting = true;
        });
        var data = await getBotResponse(question);
        setState(() {
          isWaiting = false;
        });
        if(data != null || data.length != 0) {
          addResponseToChat(data);
        }
        else{
          b = new Bubble("https://google.com/search?q="+question, false);
          setState(() {
            chat.add(b);
          });
        }
      }
    }
    query.text = "";
  }

  void setHostAddress(){
    if(hostAddressController.text != ""){
      setState(() {
         hostAddress = hostAddressController.text;
      });
    }
  }

  Widget startBot(){
    return Container(
      constraints: BoxConstraints(
          minHeight: 1100
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          SingleChildScrollView(
            reverse: true,
            child: Column(children: [
              SizedBox(height: 50),
              Container(
                  padding: EdgeInsets.all(10),
                  width: double.infinity,
                  // color: Colors.red,
                  child: chatUI()),
              SizedBox(height: 80),
            ],),
          ),
          Container(
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                      sigmaX: 10, sigmaY: 10
                  ),
                  child: Container(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    constraints: BoxConstraints(
                        maxHeight: 90
                    ),
                    decoration: BoxDecoration(
                        color: Color.fromRGBO(200, 200, 200, 0.4)
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 10,
                          child: Padding(
                            padding: EdgeInsets.all(15),
                            child: TextField(
                                controller: query,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                                  hintText: 'What\'s on your mind',
                                  hintStyle: TextStyle(color: Color.fromRGBO(55,55,55,0.6) , fontSize: 25),

                                ),
                                style: TextStyle(color: Colors.black, fontSize: 20)
                            ),
                          ),
                        ),
                        Expanded(
                            flex: 2,
                            child: Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                    color: Color.fromRGBO(26, 91, 252, 1)
                                ),
                                child: IconButton(onPressed: sendReq, icon: Icon(Icons.send),color: Colors.white, iconSize: 30,)
                            )
                        )
                      ],
                    ),
                  ),
                ),
              )
          )
        ],),
    );
  }

  Widget getHostAddress(){
    return Container(
      padding: EdgeInsets.all(15),
      child: SingleChildScrollView(
        child: Column(children: [
          ClipRRect( borderRadius: BorderRadius.all(Radius.circular(10000)) ,child: Image.asset('images/animLogo.gif', width: 500,)),
          SizedBox(height: 40,),
          Text("Welcome to\nAI Assistant",  textAlign: TextAlign.center ,style: TextStyle(fontSize: 50, fontWeight: FontWeight.w600),),
          Text("\n\nDebug mode\nEnter Local Host Address", textAlign: TextAlign.center ,style: TextStyle(fontSize: 20),),
          SizedBox(height: 10,),
          TextField(
              controller: hostAddressController,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                hintText: '192.168.1.1',
                hintStyle: TextStyle(color: Color.fromRGBO(55,55,55,0.6) , fontSize: 25),
              ),
              style: TextStyle(color: Colors.black, fontSize: 20)
          ),
          SizedBox(height: 10,),
          InkWell(
            onTap: setHostAddress,
            child: Container(
              padding: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: Color.fromRGBO(26, 91, 252, 1),
              ),
              child: Text("Save", style: TextStyle(color: Colors.white, fontSize: 30),),
            ),
          )
        ],),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(254, 252, 254, 1),
      body: hostAddress == "" ? getHostAddress() : startBot(),
    );
  }
}