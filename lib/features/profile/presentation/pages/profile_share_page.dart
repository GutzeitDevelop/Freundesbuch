// Profile Share Page
// 
// QR code generation and sharing functionality
// Version 0.6.0

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/widgets/standard_app_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/user_profile.dart';
import '../providers/profile_provider.dart';

/// Page for sharing user profile via QR code
class ProfileSharePage extends ConsumerStatefulWidget {
  const ProfileSharePage({super.key});

  @override
  ConsumerState<ProfileSharePage> createState() => _ProfileSharePageState();
}

class _ProfileSharePageState extends ConsumerState<ProfileSharePage> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _shareLink;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Delay generation to ensure context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateShareLink();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  void _generateShareLink() {
    try {
      // Generate a unique share link/code
      final profileAsync = ref.read(profileProvider);
      
      profileAsync.when(
        data: (profile) {
          if (profile != null) {
            // Create profile data JSON
            final profileData = {
              'id': profile.id,
              'name': profile.name,
              'nickname': profile.nickname,
              'bio': profile.motto,  // Using motto as bio
              'email': profile.email,
              'phone': profile.phone,
              'location': profile.homeLocation,  // Using homeLocation
              'interests': [profile.hobbies, profile.likes].where((e) => e != null).toList(),  // Combine hobbies and likes
              'photoPath': profile.photoPath != null ? 'has_photo' : null,
              'timestamp': DateTime.now().toIso8601String(),
            };
            
            // Encode as base64 for QR code
            final jsonString = jsonEncode(profileData);
            setState(() {
              _shareLink = 'myfriendsapp://profile/${base64Encode(utf8.encode(jsonString))}';
            });
          }
        },
        loading: () {
          // Profile still loading
          debugPrint('Profile still loading...');
        },
        error: (error, stack) {
          debugPrint('Error loading profile: $error');
        },
      );
    } catch (e) {
      debugPrint('Error generating share link: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    debugPrint('ProfileSharePage: Building widget');
    
    try {
      final l10n = AppLocalizations.of(context)!;
      final profileAsync = ref.watch(profileProvider);
      
      debugPrint('ProfileSharePage: Profile state - ${profileAsync.toString()}');
      
      return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 48),
        child: Column(
          children: [
            StandardAppBar(
              title: 'Profil teilen',
            ),
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(icon: Icon(Icons.qr_code), text: 'QR Code'),
                Tab(icon: Icon(Icons.share), text: 'Andere'),
              ],
            ),
          ],
        ),
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Fehler: $error'),
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
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/profile'),
                    child: const Text('Profil erstellen'),
                  ),
                ],
              ),
            );
          }
          
          return TabBarView(
            controller: _tabController,
            children: [
              // QR Code Tab
              _buildQRCodeTab(profile),
              // Other sharing methods tab
              _buildOtherSharingTab(profile),
            ],
          );
        },
      ),
    );
    } catch (e, stack) {
      debugPrint('ProfileSharePage Error: $e');
      debugPrint('Stack: $stack');
      return Scaffold(
        appBar: StandardAppBar(title: 'Fehler'),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Fehler beim Laden der Seite: $e'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Zurück'),
              ),
            ],
          ),
        ),
      );
    }
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
              embeddedImage: profile.photoPath != null 
                  ? AssetImage(profile.photoPath!)
                  : null,
              embeddedImageStyle: const QrEmbeddedImageStyle(
                size: Size(60, 60),
              ),
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
                onPressed: () => _shareProfile(),
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
          onTap: () => _shareProfile(),
          isAvailable: true,
        ),
        _buildSharingOption(
          icon: Icons.email,
          title: 'E-Mail',
          subtitle: 'Als E-Mail versenden',
          onTap: () => _shareViaEmail(),
          isAvailable: true,
        ),
        _buildSharingOption(
          icon: Icons.sms,
          title: 'SMS',
          subtitle: 'Als SMS versenden',
          onTap: () => _shareViaSMS(),
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
              backgroundImage: profile.photoPath != null
                  ? AssetImage(profile.photoPath!)
                  : null,
              child: profile.photoPath == null
                  ? Text(
                      profile.name.isNotEmpty 
                          ? profile.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(fontSize: 24),
                    )
                  : null,
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
                        Text(
                          profile.homeLocation!,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
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
  
  void _shareProfile() {
    if (_shareLink != null) {
      final profileAsync = ref.read(profileProvider);
      profileAsync.whenData((profile) {
        Share.share(
          'Füge mich als Freund hinzu in MyFriends!\n\n'
          'Name: ${profile?.name ?? "Unbekannt"}\n'
          '${profile?.nickname != null ? 'Nickname: "${profile!.nickname}"\n' : ''}'
          'Link: $_shareLink',
          subject: 'MyFriends Profil',
        );
      });
    }
  }
  
  void _shareViaNFC() {
    SnackbarUtils.showInfo(context, 'NFC-Sharing kommt bald!');
  }
  
  void _shareViaBluetooth() {
    SnackbarUtils.showInfo(context, 'Bluetooth-Sharing kommt bald!');
  }
  
  void _shareViaEmail() {
    final profileAsync = ref.read(profileProvider);
    profileAsync.whenData((profile) {
      final emailBody = 'Hallo!\n\n'
          'Ich möchte mein MyFriends-Profil mit dir teilen.\n\n'
          'Name: ${profile?.name ?? "Unbekannt"}\n'
          '${profile?.nickname != null ? 'Nickname: "${profile!.nickname}"\n' : ''}'
          '${profile?.motto != null ? '\nÜber mich:\n${profile!.motto}\n' : ''}'
          '\nLink zum Hinzufügen: $_shareLink\n\n'
          'Lade dir die MyFriends App herunter und scanne den QR-Code oder nutze den Link!';
      
      Share.share(emailBody, subject: 'MyFriends Profil von ${profile?.name}');
    });
  }
  
  void _shareViaSMS() {
    final profileAsync = ref.read(profileProvider);
    profileAsync.whenData((profile) {
      Share.share(
        'Hi! Füge mich in MyFriends hinzu: ${profile?.name ?? "Unbekannt"}\n$_shareLink',
      );
    });
  }
}