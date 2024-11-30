// ignore_for_file: file_names, library_private_types_in_public_api

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TouchableOpacity extends StatefulWidget {
  final Widget child;
  final Function()? onTap;
  final bool? disabled;

  const TouchableOpacity(
      {super.key, required this.child, this.onTap, this.disabled = false});

  @override
  _TouchableOpacityState createState() => _TouchableOpacityState();
}

class _TouchableOpacityState extends State<TouchableOpacity> {
  bool isDown = false;

  @override
  void initState() {
    super.initState();
    setState(() => isDown = false);
  }

  @override
  Widget build(BuildContext context) {
    bool disabled = widget.disabled!;

    return GestureDetector(
      onTapDown: (_) {
        if (disabled) {
          return;
        }
        setState(() => isDown = true);
      },
      onTapUp: (_) {
        if (disabled) {
          return;
        }
        Future.delayed(const Duration(milliseconds: 50), () {
          if (context.mounted) {
            setState(() => isDown = false);
          }
        });
      },
      onTapCancel: disabled ? () {} : () => setState(() => isDown = false),
      onTap: disabled ? () {} : widget.onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 100),
        opacity: isDown ? 0.25 : 1,
        child: widget.child,
      ),
    );
  }
}
