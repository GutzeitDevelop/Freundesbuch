// Beer Button Widget
// 
// Floating action button for sending "Let's drink a beer" invitation
// Version 0.4.0

import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Beer button for inviting friends to drink
class BeerButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isEnabled;
  
  const BeerButton({
    super.key,
    required this.onPressed,
    this.isEnabled = true,
  });
  
  @override
  State<BeerButton> createState() => _BeerButtonState();
}

class _BeerButtonState extends State<BeerButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  bool _isPressed = false;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _handleTapDown(_) {
    setState(() {
      _isPressed = true;
    });
    _animationController.forward();
  }
  
  void _handleTapUp(_) {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
    
    if (widget.isEnabled) {
      widget.onPressed();
      
      // Fun animation after press
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
    }
  }
  
  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.rotate(
            angle: math.sin(_rotationAnimation.value * math.pi * 2) * 0.1,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.isEnabled
                        ? [
                            const Color(0xFFFFA726), // Orange
                            const Color(0xFFFF9800), // Darker orange
                          ]
                        : [
                            Colors.grey.shade400,
                            Colors.grey.shade500,
                          ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.isEnabled
                          ? const Color(0xFFFF9800).withOpacity(0.4)
                          : Colors.grey.withOpacity(0.3),
                      blurRadius: _isPressed ? 8 : 12,
                      offset: Offset(0, _isPressed ? 2 : 4),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Pulsing background effect when enabled
                    if (widget.isEnabled)
                      AnimatedContainer(
                        duration: const Duration(seconds: 2),
                        width: _isPressed ? 90 : 85,
                        height: _isPressed ? 90 : 85,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFFFA726).withOpacity(0.2),
                        ),
                      ),
                    
                    // Beer icon or emoji
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '🍺',
                          style: TextStyle(fontSize: 32),
                        ),
                        if (!widget.isEnabled)
                          const Icon(
                            Icons.lock_outline,
                            color: Colors.white,
                            size: 16,
                          ),
                      ],
                    ),
                    
                    // Ripple effect indicator
                    if (_isPressed && widget.isEnabled)
                      ...List.generate(3, (index) {
                        return AnimatedContainer(
                          duration: Duration(milliseconds: 600 + (index * 200)),
                          width: 80 + (index * 20).toDouble(),
                          height: 80 + (index * 20).toDouble(),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFFFA726)
                                  .withOpacity(0.3 - (index * 0.1)),
                              width: 2,
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Alternative compact beer button
class CompactBeerButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isEnabled;
  
  const CompactBeerButton({
    super.key,
    required this.onPressed,
    this.isEnabled = true,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return FloatingActionButton.extended(
      onPressed: isEnabled ? onPressed : null,
      backgroundColor: isEnabled
          ? const Color(0xFFFFA726)
          : theme.colorScheme.surfaceContainerHighest,
      icon: const Text('🍺', style: TextStyle(fontSize: 24)),
      label: Text(
        'Bier-Zeit!',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isEnabled ? Colors.white : theme.colorScheme.onSurfaceVariant,
        ),
      ),
      elevation: isEnabled ? 6 : 2,
    );
  }
}