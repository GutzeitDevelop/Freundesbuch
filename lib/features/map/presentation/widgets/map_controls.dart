// Map Controls Widget
// 
// Search bar and zoom controls for the map
// Version 0.4.0

import 'package:flutter/material.dart';

/// Search bar for address search on the map
class MapSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  
  const MapSearchBar({
    super.key,
    required this.onSearch,
  });
  
  @override
  State<MapSearchBar> createState() => _MapSearchBarState();
}

class _MapSearchBarState extends State<MapSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isExpanded = false;
  
  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
  
  void _handleSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      widget.onSearch(query);
      _focusNode.unfocus();
      setState(() {
        _isExpanded = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
          ),
          child: _isExpanded
              ? Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        setState(() {
                          _isExpanded = false;
                          _searchController.clear();
                        });
                      },
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _focusNode,
                        decoration: const InputDecoration(
                          hintText: 'Adresse suchen...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 8),
                        ),
                        onSubmitted: (_) => _handleSearch(),
                        autofocus: true,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _handleSearch,
                    ),
                  ],
                )
              : InkWell(
                  onTap: () {
                    setState(() {
                      _isExpanded = true;
                    });
                  },
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Adresse suchen',
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

/// Zoom controls for the map
class MapZoomControls extends StatelessWidget {
  final double currentZoom;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  
  const MapZoomControls({
    super.key,
    required this.currentZoom,
    required this.onZoomIn,
    required this.onZoomOut,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Zoom in button
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: currentZoom < 18 ? onZoomIn : null,
              tooltip: 'Vergrößern',
            ),
            Container(
              height: 1,
              width: 24,
              color: theme.dividerColor,
            ),
            // Zoom out button
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: currentZoom > 3 ? onZoomOut : null,
              tooltip: 'Verkleinern',
            ),
          ],
        ),
      ),
    );
  }
}

/// Map type selector (normal/satellite)
class MapTypeSelector extends StatelessWidget {
  final String currentType;
  final Function(String) onTypeChanged;
  
  const MapTypeSelector({
    super.key,
    required this.currentType,
    required this.onTypeChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _MapTypeOption(
              icon: Icons.map,
              label: 'Karte',
              isSelected: currentType == 'normal',
              onTap: () => onTypeChanged('normal'),
            ),
            const SizedBox(width: 4),
            _MapTypeOption(
              icon: Icons.satellite,
              label: 'Satellit',
              isSelected: currentType == 'satellite',
              onTap: () => onTypeChanged('satellite'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual map type option
class _MapTypeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _MapTypeOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurfaceVariant,
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}