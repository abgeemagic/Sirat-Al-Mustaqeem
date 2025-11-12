import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:molvi/Pages/settings.dart';
import 'package:molvi/Ai/ai_service.dart';

class ChatMessage {
  final String message;
  final bool isUser;
  final DateTime timestamp;
  ChatMessage({
    required this.message,
    required this.isUser,
    required this.timestamp,
  });
}

class Aipage extends StatefulWidget {
  const Aipage({super.key});
  @override
  State<Aipage> createState() => _AipageState();
}

class _AipageState extends State<Aipage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isServerRunning = false;
  bool _isCheckingServer = false;
  @override
  void initState() {
    super.initState();
    FontSettings.addListener(_onFontSettingsChanged);
    _checkServerStatus();
    _messages.add(ChatMessage(
      message:
          "السلام علیکم! Welcome to Molvi AI Assistant powered by Gemini. I'm here to help you with questions about Islam, Quran, Hadith, and Islamic teachings based on authentic sources. How can I assist you today?",
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    FontSettings.removeListener(_onFontSettingsChanged);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onFontSettingsChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _checkServerStatus() async {
    if (!mounted) return;
    setState(() {
      _isCheckingServer = true;
    });
    final isRunning = await AIService.isServerRunning();
    if (!mounted) return;
    setState(() {
      _isServerRunning = isRunning;
      _isCheckingServer = false;
    });
  }

  Future<void> _startServer() async {
    setState(() {
      _isCheckingServer = true;
    });
    final success = await AIService.startServer();
    setState(() {
      _isServerRunning = success;
      _isCheckingServer = false;
    });
    if (success) {
      _messages.add(ChatMessage(
        message:
            "✅ AI Server started successfully! You can now get real-time responses from Gemini AI.",
        isUser: false,
        timestamp: DateTime.now(),
      ));
    } else {
      _messages.add(ChatMessage(
        message:
            "❌ Failed to start AI Server. Make sure Node.js is installed and try again.",
        isUser: false,
        timestamp: DateTime.now(),
      ));
    }
    _scrollToBottom();
  }

  Future<void> _stopServer() async {
    final success = await AIService.stopServer();
    setState(() {
      _isServerRunning = !success;
    });
    if (success) {
      _messages.add(ChatMessage(
        message: "🔴 AI Server stopped. You'll now receive offline responses.",
        isUser: false,
        timestamp: DateTime.now(),
      ));
    }
    _scrollToBottom();
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    final userMessage = _messageController.text.trim();
    _messageController.clear();
    setState(() {
      _messages.add(ChatMessage(
        message: userMessage,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });
    _scrollToBottom();
    try {
      final aiResponse = await AIService.sendMessage(
        userMessage,
        userContext: "Islamic guidance and teaching from Quran and Hadith",
      );
      setState(() {
        _messages.add(ChatMessage(
          message: aiResponse,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          message:
              "I apologize, but I'm having trouble connecting to the AI service right now. Please check your internet connection and try again.",
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
      _messages.add(ChatMessage(
        message:
            "Chat cleared. السلام علیکم! I'm your Molvi AI Assistant powered by Gemini. How can I help you with your Islamic questions?",
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Text("Coming Soon!"),
    )
        // appBar: AppBar(
        //   title: Text(
        //     'Molvi AI - Powered by Gemini',
        //     style: GoogleFonts.inter(
        //       fontSize: FontSettings.englishFontSize * 1.2,
        //       fontWeight: FontWeight.bold,
        //     ),
        //   ),
        //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        //   elevation: 2,
        //   actions: [
        //     // Cloud/Local toggle
        //     IconButton(
        //       onPressed: () {
        //         setState(() {
        //           AIService.setUseCloudFunction(!AIService.isUsingCloudFunction);
        //         });
        //         _checkServerStatus();
        //         _messages.add(ChatMessage(
        //           message: AIService.isUsingCloudFunction
        //               ? "🌐 Switched to Cloud Function - No manual server startup needed!"
        //               : "🏠 Switched to Local Server - You may need to start the server manually.",
        //           isUser: false,
        //           timestamp: DateTime.now(),
        //         ));
        //         _scrollToBottom();
        //       },
        //       icon: Icon(
        //         AIService.isUsingCloudFunction ? Icons.cloud : Icons.computer,
        //         color:
        //             AIService.isUsingCloudFunction ? Colors.blue : Colors.orange,
        //       ),
        //       tooltip: AIService.isUsingCloudFunction
        //           ? 'Using Cloud Function (Tap to switch to Local)'
        //           : 'Using Local Server (Tap to switch to Cloud)',
        //     ),
        //     Container(
        //       margin: const EdgeInsets.only(right: 8),
        //       child: _isCheckingServer
        //           ? const SizedBox(
        //               width: 20,
        //               height: 20,
        //               child: CircularProgressIndicator(strokeWidth: 2),
        //             )
        //           : IconButton(
        //               onPressed: _checkServerStatus,
        //               icon: Icon(
        //                 _isServerRunning ? Icons.cloud_done : Icons.cloud_off,
        //                 color: _isServerRunning ? Colors.green : Colors.red,
        //               ),
        //               tooltip: _isServerRunning
        //                   ? 'AI Server Running (Tap to refresh)'
        //                   : 'AI Server Offline (Tap to refresh)',
        //             ),
        //     ),
        //     // Only show start/stop for local server
        //     if (!AIService.isUsingCloudFunction)
        //       IconButton(
        //         onPressed: _isCheckingServer
        //             ? null
        //             : (_isServerRunning ? _stopServer : _startServer),
        //         icon: Icon(_isServerRunning ? Icons.stop : Icons.play_arrow),
        //         tooltip: _isServerRunning ? 'Stop AI Server' : 'Start AI Server',
        //       ),
        //     IconButton(
        //       onPressed: _clearChat,
        //       icon: const Icon(Icons.clear_all),
        //       tooltip: 'Clear chat',
        //     ),
        //   ],
        // ),
        // body: Column(
        //   children: [
        //     Container(
        //       width: double.infinity,
        //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        //       color: _isServerRunning
        //           ? Colors.green.withOpacity(0.1)
        //           : (AIService.isUsingCloudFunction
        //               ? Colors.blue.withOpacity(0.1)
        //               : Colors.orange.withOpacity(0.1)),
        //       child: Row(
        //         children: [
        //           Icon(
        //             AIService.isUsingCloudFunction
        //                 ? Icons.cloud
        //                 : (_isServerRunning ? Icons.cloud_done : Icons.cloud_off),
        //             size: 16,
        //             color: AIService.isUsingCloudFunction
        //                 ? Colors.blue
        //                 : (_isServerRunning ? Colors.green : Colors.orange),
        //           ),
        //           const SizedBox(width: 8),
        //           Expanded(
        //             child: Text(
        //               AIService.isUsingCloudFunction
        //                   ? 'Using Cloud Function - Always available across networks'
        //                   : (_isServerRunning
        //                       ? 'Local Server Online - Same network only'
        //                       : 'Local Server Offline - Using fallback responses'),
        //               style: GoogleFonts.inter(
        //                 fontSize: FontSettings.englishFontSize * 0.8,
        //                 color: AIService.isUsingCloudFunction
        //                     ? Colors.blue
        //                     : (_isServerRunning ? Colors.green : Colors.orange),
        //                 fontWeight: FontWeight.w500,
        //               ),
        //             ),
        //           ),
        //         ],
        //       ),
        //     ),
        //     Expanded(
        //       child: Container(
        //         decoration: BoxDecoration(
        //           gradient: LinearGradient(
        //             begin: Alignment.topCenter,
        //             end: Alignment.bottomCenter,
        //             colors: [
        //               Theme.of(context)
        //                   .colorScheme
        //                   .primaryContainer
        //                   .withValues(alpha: 0.1),
        //               Theme.of(context).colorScheme.surface,
        //             ],
        //           ),
        //         ),
        //         child: ListView.builder(
        //           controller: _scrollController,
        //           padding: const EdgeInsets.all(16),
        //           itemCount: _messages.length + (_isLoading ? 1 : 0),
        //           itemBuilder: (context, index) {
        //             if (index == _messages.length && _isLoading) {
        //               return _buildLoadingMessage();
        //             }
        //             final message = _messages[index];
        //             return _buildMessageBubble(message);
        //           },
        //         ),
        //       ),
        //     ),
        //     _buildMessageInput(),
        //   ],
        // ),
        );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(
                Icons.auto_awesome,
                size: 16,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: message.isUser
                      ? const Radius.circular(16)
                      : const Radius.circular(4),
                  bottomRight: message.isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.message,
                    style: _isArabicText(message.message)
                        ? GoogleFonts.amiriQuran(
                            fontSize: FontSettings.arabicFontSize * 1.0,
                            color: message.isUser
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                            height: 1.6,
                          )
                        : GoogleFonts.inter(
                            fontSize: FontSettings.englishFontSize * 1.0,
                            color: message.isUser
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                            height: 1.4,
                          ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: GoogleFonts.inter(
                      fontSize: FontSettings.englishFontSize * 0.7,
                      color: message.isUser
                          ? Theme.of(context)
                              .colorScheme
                              .onPrimary
                              .withValues(alpha: 0.7)
                          : Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant
                              .withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: Icon(
                Icons.person,
                size: 16,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Icon(
              Icons.auto_awesome,
              size: 16,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'AI is thinking...',
                  style: GoogleFonts.inter(
                    fontSize: FontSettings.englishFontSize * 0.9,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _messageController,
                  style: GoogleFonts.inter(
                    fontSize: FontSettings.englishFontSize * 1.0,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ask about Islam, Quran, Hadith...',
                    hintStyle: GoogleFonts.inter(
                      fontSize: FontSettings.englishFontSize * 0.9,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant
                          .withValues(alpha: 0.6),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _isLoading ? null : _sendMessage,
                icon: Icon(
                  Icons.send,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                tooltip: 'Send message',
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isArabicText(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }
}
