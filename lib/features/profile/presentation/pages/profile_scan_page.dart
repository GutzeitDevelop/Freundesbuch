// Profile Scan Page
// 
// QR code scanner for receiving friend profiles
// Version 0.6.0

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/widgets/standard_app_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../friend/domain/entities/friend.dart';
import '../../../friend/presentation/providers/friends_provider.dart';

/// Page for scanning QR codes to receive friend profiles
class ProfileScanPage extends ConsumerStatefulWidget {
  const ProfileScanPage({super.key});

  @override
  ConsumerState<ProfileScanPage> createState() => _ProfileScanPageState();
}

class _ProfileScanPageState extends ConsumerState<ProfileScanPage> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );
  
  bool _isProcessing = false;
  Map<String, dynamic>? _scannedProfile;
  
  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: StandardAppBar(
        title: 'QR-Code scannen',
        actions: [
          // Toggle flash
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _scannerController.toggleTorch(),
          ),
          // Switch camera
          IconButton(
            icon: const Icon(Icons.camera_rear),
            onPressed: () => _scannerController.switchCamera(),
          ),
        ],
      ),
      body: _scannedProfile != null
          ? _buildProfilePreview()
          : _buildScanner(),
    );
  }
  
  Widget _buildScanner() {
    return Stack(
      children: [
        // Camera view
        MobileScanner(
          controller: _scannerController,
          onDetect: _handleBarcode,
        ),
        
        // Overlay
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
          ),
          child: Stack(
            children: [
              // Scanning area
              Center(
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.primary,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              
              // Cut out center
              Center(
                child: Container(
                  width: 276,
                  height: 276,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: ColorFiltered(
                      colorFilter: const ColorFilter.mode(
                        Colors.transparent,
                        BlendMode.srcOut,
                      ),
                      child: Container(
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Instructions
              Positioned(
                bottom: 100,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Icon(
                      Icons.qr_code_scanner,
                      size: 48,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Richte die Kamera auf den QR-Code',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Der Code wird automatisch erkannt',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              // Processing indicator
              if (_isProcessing)
                Container(
                  color: Colors.black.withOpacity(0.7),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildProfilePreview() {
    if (_scannedProfile == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Success icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              size: 48,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 24),
          
          // Title
          const Text(
            'Profil erkannt!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          
          // Profile card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile header
                  Row(
                    children: [
                      // Photo placeholder
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: Text(
                          _scannedProfile!['name']?[0]?.toUpperCase() ?? '?',
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // Name and nickname
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _scannedProfile!['name'] ?? 'Unbekannt',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_scannedProfile!['nickname'] != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                '"${_scannedProfile!['nickname']}"',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  // Profile details
                  if (_scannedProfile!['bio'] != null) ...[
                    _buildDetailRow(Icons.info_outline, 'Über mich', _scannedProfile!['bio']),
                    const SizedBox(height: 12),
                  ],
                  if (_scannedProfile!['location'] != null) ...[
                    _buildDetailRow(Icons.location_on, 'Ort', _scannedProfile!['location']),
                    const SizedBox(height: 12),
                  ],
                  if (_scannedProfile!['email'] != null) ...[
                    _buildDetailRow(Icons.email, 'E-Mail', _scannedProfile!['email']),
                    const SizedBox(height: 12),
                  ],
                  if (_scannedProfile!['phone'] != null) ...[
                    _buildDetailRow(Icons.phone, 'Telefon', _scannedProfile!['phone']),
                    const SizedBox(height: 12),
                  ],
                  if (_scannedProfile!['interests'] != null && 
                      (_scannedProfile!['interests'] as List).isNotEmpty) ...[
                    _buildDetailRow(
                      Icons.favorite,
                      'Interessen',
                      (_scannedProfile!['interests'] as List).join(', '),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _cancelScan,
                  child: const Text('Abbrechen'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _addFriend,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Als Freund hinzufügen'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  void _handleBarcode(BarcodeCapture capture) {
    if (_isProcessing) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    
    final String? code = barcodes.first.rawValue;
    if (code == null) return;
    
    // Check if it's a MyFriends profile link
    if (code.startsWith('myfriendsapp://profile/')) {
      setState(() {
        _isProcessing = true;
      });
      
      try {
        // Extract and decode the profile data
        final base64Data = code.replaceFirst('myfriendsapp://profile/', '');
        final jsonString = utf8.decode(base64.decode(base64Data));
        final profileData = jsonDecode(jsonString) as Map<String, dynamic>;
        
        // Stop scanning
        _scannerController.stop();
        
        setState(() {
          _scannedProfile = profileData;
          _isProcessing = false;
        });
      } catch (e) {
        SnackbarUtils.showError(context, 'Ungültiger QR-Code');
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
  
  void _cancelScan() {
    setState(() {
      _scannedProfile = null;
    });
    _scannerController.start();
  }
  
  void _addFriend() async {
    if (_scannedProfile == null) return;
    
    try {
      // Create friend from scanned profile
      final friend = Friend(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _scannedProfile!['name'] ?? 'Unbekannt',
        nickname: _scannedProfile!['nickname'],
        email: _scannedProfile!['email'],
        phone: _scannedProfile!['phone'],
        homeLocation: _scannedProfile!['location'],
        notes: _scannedProfile!['bio'],
        customFieldValues: _scannedProfile!['interests'] != null
            ? {'interests': _scannedProfile!['interests']}
            : {},
        isFavorite: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        firstMetLocation: await _getCurrentLocation(),
        firstMetDate: DateTime.now(), // Required field
        templateType: 'modern', // Use modern template for scanned profiles
        friendBookIds: [], // Empty list initially
      );
      
      // Add friend
      await ref.read(friendsProvider.notifier).addFriend(friend);
      
      SnackbarUtils.showSuccess(context, 'Freund hinzugefügt!');
      
      // Navigate to friend detail
      if (mounted) {
        context.go('/friends/${friend.id}');
      }
    } catch (e) {
      SnackbarUtils.showError(context, 'Fehler beim Hinzufügen: $e');
    }
  }
  
  Future<String?> _getCurrentLocation() async {
    // TODO: Get actual current location
    return 'Via QR-Code';
  }
}