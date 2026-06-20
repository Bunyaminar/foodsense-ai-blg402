import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;
  ChatMessage({required this.text, required this.isUser, required this.time});
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  static const String _apiKey = 'GROQ_API_KEY_PLACEHOLDER';
  static const String _systemPrompt = 'Sen FoodsenseAI adli bir beslenme ve diyetisyen yapay zeka asistanisin. Turkce cevap ver. Kullanicinin sordugu beslenme, diyet, E-kodlari, besin degerleri, kilo yonetimi, spor beslenmesi gibi konularda detayli ve pratik cevaplar ver. Spesifik beslenme planlari, yemek onerileri ve gunluk kalori/protein/karbonhidrat miktarlari oner. Emoji kullan. Cevaplarin kisa ve anlasilir olsun.';

  @override
  void initState() {
    super.initState();
    _messages.add(ChatMessage(
      text: 'Merhaba! Ben FoodsenseAI Beslenme Danismaninizim.\n\nSize su konularda yardimci olabilirim:\n- Urun icerikleri ve E-kodlari\n- Diyet onerileri\n- Besin degerleri\n- Saglikli alternatifler\n\nNasil yardimci olabilirim?',
      isUser: false, time: DateTime.now()));
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true, time: DateTime.now()));
      _isLoading = true;
      _messageController.clear();
    });
    _scrollToBottom();
    try {
      final response = await http.post(
        Uri.parse('https://foodsense-ai-blg402-production.up.railway.app/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': text}),
      );
      String reply;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        reply = data['response'] ?? 'Uzgunum, bir hata olustu.';
      } else {
        reply = 'Hata: ' + response.statusCode.toString() + ' - ' + response.body.substring(0, 100);
      }
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(text: reply, isUser: false, time: DateTime.now()));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: 'Exception: ' + e.toString(),
            isUser: false, time: DateTime.now()));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1B1B1B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(Icons.psychology_rounded, color: primary, size: 20),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Beslenme Danismani',
              style: GoogleFonts.poppins(
                color: Theme.of(context).textTheme.bodyLarge?.color ?? const Color(0xFF1B1B1B), fontSize: 14,
                fontWeight: FontWeight.bold)),
            Row(children: [
              Container(width: 6, height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF2E7D32), shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Text('Groq Llama 3.3 ile calisiyor',
                style: GoogleFonts.poppins(color: Colors.grey, fontSize: 11)),
            ]),
          ]),
        ]),
      ),
      body: Column(children: [
        Container(
          height: 44, color: Colors.white,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: ['Seker miktari', 'Protein ihtiyaci', 'Keto diyet',
              'Vegan beslenme', 'E kodlari nedir',
            ].map((q) => GestureDetector(
              onTap: () { _messageController.text = q; _sendMessage(); },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: primary.withValues(alpha: 0.2))),
                child: Center(child: Text(q,
                  style: GoogleFonts.poppins(color: primary, fontSize: 12,
                    fontWeight: FontWeight.w500))),
              ),
            )).toList(),
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length + (_isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _messages.length) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(children: [
                    Container(width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle),
                      child: Icon(Icons.psychology_rounded, color: primary, size: 18)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white, borderRadius: BorderRadius.circular(16)),
                      child: Row(mainAxisSize: MainAxisSize.min,
                        children: List.generate(3, (i) => Container(
                          margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                          width: 8, height: 8,
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.5),
                            shape: BoxShape.circle))))),
                  ]));
              }
              final msg = _messages[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: msg.isUser
                    ? MainAxisAlignment.end : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (!msg.isUser) ...[
                      Container(width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle),
                        child: Icon(Icons.psychology_rounded, color: primary, size: 18)),
                      const SizedBox(width: 8),
                    ],
                    Flexible(child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: msg.isUser ? primary : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(msg.isUser ? 16 : 4),
                          bottomRight: Radius.circular(msg.isUser ? 4 : 16)),
                        boxShadow: [BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)]),
                      child: Text(msg.text,
                        style: GoogleFonts.poppins(
                          color: msg.isUser ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color ?? const Color(0xFF1B1B1B),
                          fontSize: 13, height: 1.5)))),
                    if (msg.isUser) const SizedBox(width: 8),
                  ]));
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10, offset: const Offset(0, -4))]),
          child: SafeArea(child: Row(children: [
            Expanded(child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(24)),
              child: TextField(
                controller: _messageController,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: 'Mesajinizi yazin...',
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.grey.shade400, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10))),
            )),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: primary, shape: BoxShape.circle),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 20))),
          ])),
        ),
      ]),
    );
  }
}
