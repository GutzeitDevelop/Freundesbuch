// Profile Share Page - Fixed Version
// 
// QR code generation and sharing functionality
// Version 0.6.2

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/widgets/standard_app_bar.dart';
import '../../domain/entities/user_profile.dart';
import '../providers/profile_provider.dart';

/// Page for sharing user profile via QR code
class ProfileShareFixed extends ConsumerStatefulWidget {
  const ProfileShareFixed({super.key});

  @override
  ConsumerState<ProfileShareFixed> createState() => _ProfileShareFixedState();
}

class _ProfileShareFixedState extends ConsumerState<ProfileShareFixed> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _shareLink;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  void _generateShareLink(UserProfile profile) {
    try {
      // Create profile data JSON
      final profileData = {
        'id': profile.id,
        'name': profile.name,
        'nickname': profile.nickname,
        'bio': profile.motto,
        'email': profile.email,
        'phone': profile.phone,
        'location': profile.homeLocation,
        'interests': [profile.hobbies, profile.likes].where((e) => e != null).toList(),
        'photoPath': profile.photoPath != null ? 'has_photo' : null,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      // Encode as base64 for QR code
      final jsonString = jsonEncode(profileData);
      _shareLink = 'myfriendsapp://profile/${base64Encode(utf8.encode(jsonString))}';
    } catch (e) {
      debugPrint('Error generating share link: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);
    
    return Scaffold(
      appBar: StandardAppBar(
        title: 'Profil teilen',
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Fehler: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.refresh(profileProvider);
                },
                child: const Text('Erneut versuchen'),
              ),
            ],
          ),
        ),
        data: (profile) {
          if (profile == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.person_off,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Kein Profil vorhanden',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Erstelle zuerst ein Profil, um es teilen zu können',
                    style: TextStyle(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/profile');
                    },
                    icon: const Icon(Icons.person_add),
                    label: const Text('Profil erstellen'),
                  ),
                ],
              ),
            );
          }
          
          // Generate share link if not already done
          if (_shareLink == null) {
            _generateShareLink(profile);
          }
          
          return Column(
            children: [
              // Tab Bar
              Container(
                color: Theme.of(context).appBarTheme.backgroundColor,
                child: TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(icon: Icon(Icons.qr_code), text: 'QR Code'),
                    Tab(icon: Icon(Icons.share), text: 'Andere'),
                  ],
                ),
              ),
              
              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // QR Code Tab
                    _buildQRCodeTab(profile),
                    // Other sharing methods tab
                    _buildOtherSharingTab(profile),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildQRCodeTab(UserProfile profile) {
    if (_shareLink == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Profile preview
          _buildProfilePreview(profile),
          const SizedBox(height: 32),
          
          // QR Code
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: QrImageView(
              data: _shareLink!,
              version: QrVersions.auto,
              size: 280,
              backgroundColor: Colors.white,
              errorCorrectionLevel: QrErrorCorrectLevel.M,
            ),
          ),
          const SizedBox(height: 24),
          
          // Instructions
          Text(
            'Lass deinen neuen Freund diesen QR-Code scannen',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Copy link button
              OutlinedButton.icon(
                onPressed: () => _copyLink(),
                icon: const Icon(Icons.copy),
                label: const Text('Link kopieren'),
              ),
              
              // Share button
              ElevatedButton.icon(
                onPressed: () => _shareProfile(profile),
                icon: const Icon(Icons.share),
                label: const Text('Teilen'),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildOtherSharingTab(UserProfile profile) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Profile preview
        _buildProfilePreview(profile),
        const SizedBox(height: 24),
        
        // Sharing options
        _buildSharingOption(
          icon: Icons.nfc,
          title: 'NFC',
          subtitle: 'Halte dein Handy an ein anderes',
          onTap: () => _shareViaNFC(),
          isAvailable: false, // Coming soon
        ),
        _buildSharingOption(
          icon: Icons.bluetooth,
          title: 'Bluetooth',
          subtitle: 'Teile über Bluetooth',
          onTap: () => _shareViaBluetooth(),
          isAvailable: false, // Coming soon
        ),
        _buildSharingOption(
          icon: Icons.share,
          title: 'Teilen über...',
          subtitle: 'WhatsApp, Telegram, etc.',
          onTap: () => _shareProfile(profile),
          isAvailable: true,
        ),
        _buildSharingOption(
          icon: Icons.email,
          title: 'E-Mail',
          subtitle: 'Als E-Mail versenden',
          onTap: () => _shareViaEmail(profile),
          isAvailable: true,
        ),
        _buildSharingOption(
          icon: Icons.sms,
          title: 'SMS',
          subtitle: 'Als SMS versenden',
          onTap: () => _shareViaSMS(profile),
          isAvailable: true,
        ),
        _buildSharingOption(
          icon: Icons.link,
          title: 'Link',
          subtitle: 'Link zum Profil kopieren',
          onTap: () => _copyLink(),
          isAvailable: true,
        ),
      ],
    );
  }
  
  Widget _buildProfilePreview(UserProfile profile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Profile photo
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                profile.name.isNotEmpty 
                    ? profile.name[0].toUpperCase()
                    : '?',
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(width: 16),
            
            // Profile info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (profile.nickname != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '"${profile.nickname}"',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  if (profile.homeLocation != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            profile.homeLocation!,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSharingOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isAvailable,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: isAvailable ? AppColors.primary : AppColors.divider,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isAvailable ? null : AppColors.textSecondary,
          ),
        ),
        subtitle: Text(
          isAvailable ? subtitle : 'Kommt bald',
          style: TextStyle(
            color: isAvailable ? null : AppColors.divider,
          ),
        ),
        trailing: isAvailable
            ? const Icon(Icons.chevron_right)
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Bald',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.warning,
                  ),
                ),
              ),
        onTap: isAvailable ? onTap : null,
      ),
    );
  }
  
  void _copyLink() {
    if (_shareLink != null) {
      Clipboard.setData(ClipboardData(text: _shareLink!));
      SnackbarUtils.showSuccess(context, 'Link kopiert!');
    }
  }
  
  void _shareProfile(UserProfile profile) {
    if (_shareLink != null) {
      Share.share(
        'Füge mich als Freund hinzu in MyFriends!\n\n'
        'Name: ${profile.name}\n'
        '${profile.nickname != null ? 'Nickname: "${profile.nickname}"\n' : ''}'
        'Link: $_shareLink',
        subject: 'MyFriends Profil',
      );
    }
  }
  
  void _shareViaNFC() {
    SnackbarUtils.showInfo(context, 'NFC-Sharing kommt bald!');
  }
  
  void _shareViaBluetooth() {
    SnackbarUtils.showInfo(context, 'Bluetooth-Sharing kommt bald!');
  }
  
  void _shareViaEmail(UserProfile profile) {
    final emailBody = 'Hallo!\n\n'
        'Ich möchte mein MyFriends-Profil mit dir teilen.\n\n'
        'Name: ${profile.name}\n'
        '${profile.nickname != null ? 'Nickname: "${profile.nickname}"\n' : ''}'
        '${profile.motto != null ? '\nÜber mich:\n${profile.motto}\n' : ''}'
        '\nLink zum Hinzufügen: $_shareLink\n\n'
        'Lade dir die MyFriends App herunter und scanne den QR-Code oder nutze den Link!';
    
    Share.share(emailBody, subject: 'MyFriends Profil von ${profile.name}');
  }
  
  void _shareViaSMS(UserProfile profile) {
    Share.share(
      'Hi! Füge mich in MyFriends hinzu: ${profile.name}\n$_shareLink',
    );
  }
}