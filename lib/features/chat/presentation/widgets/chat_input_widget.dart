// Chat Input Widget
// 
// Input area for sending messages with attachments
// Version 0.5.1

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../domain/entities/message.dart';

/// Chat input widget for composing and sending messages
class ChatInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final String conversationId;
  final Message? replyToMessage;
  final Function(String) onSend;
  final Function(bool) onTyping;
  final VoidCallback? onCancelReply;
  
  const ChatInputWidget({
    super.key,
    required this.controller,
    required this.conversationId,
    this.replyToMessage,
    required this.onSend,
    required this.onTyping,
    this.onCancelReply,
  });
  
  @override
  State<ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends State<ChatInputWidget> {
  final ImagePicker _picker = ImagePicker();
  bool _isRecording = false;
  bool _hasText = false;
  
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }
  
  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }
  
  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
      widget.onTyping(hasText);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Attachment button
              IconButton(
                icon: Icon(
                  Icons.add_circle_outline,
                  color: AppColors.primary,
                ),
                onPressed: _showAttachmentOptions,
              ),
              
              // Text input
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(
                    minHeight: 40,
                    maxHeight: 120,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.divider,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: TextField(
                            controller: widget.controller,
                            maxLines: null,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              hintText: 'Nachricht schreiben...',
                              hintStyle: TextStyle(
                                color: AppColors.textSecondary,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                      ),
                      // Emoji button
                      IconButton(
                        icon: Icon(
                          Icons.emoji_emotions_outlined,
                          color: AppColors.textSecondary,
                          size: 22,
                        ),
                        onPressed: _showEmojiPicker,
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Send or voice button
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _hasText
                      ? IconButton(
                          key: const ValueKey('send'),
                          icon: Icon(
                            Icons.send_rounded,
                            color: AppColors.primary,
                          ),
                          onPressed: _sendMessage,
                        )
                      : IconButton(
                          key: const ValueKey('voice'),
                          icon: Icon(
                            _isRecording ? Icons.stop : Icons.mic,
                            color: _isRecording 
                                ? AppColors.error 
                                : AppColors.primary,
                          ),
                          onPressed: _toggleVoiceRecording,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _sendMessage() {
    final text = widget.controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSend(text);
    }
  }
  
  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Attachment options
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _AttachmentOption(
                      icon: Icons.camera_alt,
                      label: 'Kamera',
                      color: Colors.blue,
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                    _AttachmentOption(
                      icon: Icons.photo,
                      label: 'Galerie',
                      color: Colors.purple,
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                    _AttachmentOption(
                      icon: Icons.location_on,
                      label: 'Standort',
                      color: Colors.green,
                      onTap: () {
                        Navigator.pop(context);
                        _shareLocation();
                      },
                    ),
                    _AttachmentOption(
                      icon: Icons.person,
                      label: 'Kontakt',
                      color: Colors.orange,
                      onTap: () {
                        Navigator.pop(context);
                        _shareContact();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  void _showEmojiPicker() {
    // TODO: Implement emoji picker
    SnackbarUtils.showInfo(context, 'Emoji-Auswahl kommt bald!');
  }
  
  void _toggleVoiceRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });
    
    if (_isRecording) {
      // TODO: Start recording
      SnackbarUtils.showInfo(context, 'Sprachaufnahme startet...');
    } else {
      // TODO: Stop recording and send
      SnackbarUtils.showInfo(context, 'Sprachaufnahme beendet');
    }
  }
  
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        // TODO: Send image message
        SnackbarUtils.showSuccess(context, 'Bild ausgewählt: ${image.name}');
      }
    } catch (e) {
      SnackbarUtils.showError(context, 'Fehler: $e');
    }
  }
  
  Future<void> _shareLocation() async {
    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          SnackbarUtils.showError(context, 'Standortberechtigung verweigert');
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        SnackbarUtils.showError(
          context,
          'Standortberechtigung dauerhaft verweigert. Bitte in den Einstellungen aktivieren.',
        );
        return;
      }
      
      // Get current location
      final position = await Geolocator.getCurrentPosition();
      
      // TODO: Send location message
      SnackbarUtils.showSuccess(
        context,
        'Standort: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
      );
    } catch (e) {
      SnackbarUtils.showError(context, 'Fehler beim Abrufen des Standorts: $e');
    }
  }
  
  void _shareContact() {
    // TODO: Implement contact sharing
    SnackbarUtils.showInfo(context, 'Kontakt-Teilen kommt bald!');
  }
}

/// Individual attachment option widget
class _AttachmentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  
  const _AttachmentOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}