// Friend list tile widget
// 
// Displays a friend entry in a list

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/friend.dart';
import '../../../../core/services/photo_service.dart';

/// Widget for displaying a friend in a list
class FriendListTile extends StatefulWidget {
  final Friend friend;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  
  const FriendListTile({
    super.key,
    required this.friend,
    this.onTap,
    this.onFavoriteToggle,
  });
  
  @override
  State<FriendListTile> createState() => _FriendListTileState();
}

class _FriendListTileState extends State<FriendListTile> {
  String? _resolvedPhotoPath;
  
  @override
  void initState() {
    super.initState();
    _resolvePhotoPath();
  }
  
  @override
  void didUpdateWidget(FriendListTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.friend.photoPath != widget.friend.photoPath) {
      _resolvePhotoPath();
    }
  }
  
  Future<void> _resolvePhotoPath() async {
    if (widget.friend.photoPath != null) {
      final resolvedPath = await PhotoService.resolvePhotoPath(widget.friend.photoPath);
      if (mounted) {
        setState(() {
          _resolvedPhotoPath = resolvedPath;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMd(Localizations.localeOf(context).languageCode);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          backgroundImage: _resolvedPhotoPath != null && _resolvedPhotoPath!.isNotEmpty
              ? FileImage(File(_resolvedPhotoPath!)) as ImageProvider
              : null,
          child: _resolvedPhotoPath == null || _resolvedPhotoPath!.isEmpty
              ? Text(
                  widget.friend.name.isNotEmpty ? widget.friend.name[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                )
              : null,
        ),
        title: Text(
          widget.friend.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.friend.nickname != null)
              Text(
                '"${widget.friend.nickname}"',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            if (widget.friend.firstMetLocation != null)
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      widget.friend.firstMetLocation!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  dateFormat.format(widget.friend.firstMetDate),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            widget.friend.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: widget.friend.isFavorite ? Colors.red : null,
          ),
          onPressed: widget.onFavoriteToggle,
        ),
        onTap: widget.onTap,
      ),
    );
  }
}