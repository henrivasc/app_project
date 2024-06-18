import 'package:flutter/material.dart';

class MyButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String buttonText;

  const MyButton({super.key, required this.onPressed, required this.buttonText});

  @override
  _MyButtonState createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
      },
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(25),
          margin: const EdgeInsets.symmetric(horizontal: 25),
          decoration: BoxDecoration(
            color: _isHovered ? Color.fromARGB(255, 2, 10, 255) : Colors.blue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              widget.buttonText,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
