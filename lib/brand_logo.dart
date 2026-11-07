import 'package:flutter/material.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 32});
  final double size;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(size / 4),
    child: Image.asset('assets/branding/logo.png', width: size, height: size,
      semanticLabel: 'Load and Ride logo', fit: BoxFit.cover),
  );
}
