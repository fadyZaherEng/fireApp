import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SmartText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;

  const SmartText(
    this.text, {
    Key? key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if text contains Arabic characters
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    final bool isArabic = arabicRegex.hasMatch(text);

    TextStyle baseStyle;

    if (isArabic) {
      baseStyle = GoogleFonts.almarai();
    } else {
      baseStyle = GoogleFonts.poppins();
    }

    // Merge with provided style
    final finalStyle = style != null ? baseStyle.merge(style) : baseStyle;

    return Text(
      text,
      style: finalStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
    );
  }
}

class SmartTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final TextStyle? style;
  final TextStyle? hintStyle;
  final TextStyle? labelStyle;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int? maxLines;
  final InputDecoration? decoration;

  const SmartTextFormField({
    Key? key,
    this.controller,
    this.hintText,
    this.labelText,
    this.style,
    this.hintStyle,
    this.labelStyle,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.decoration,
  }) : super(key: key);

  TextStyle _getSmartStyle(String? text, TextStyle? baseStyle) {
    if (text == null || text.isEmpty) {
      return GoogleFonts.poppins().merge(baseStyle);
    }

    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    final bool isArabic = arabicRegex.hasMatch(text);

    if (isArabic) {
      return GoogleFonts.almarai().merge(baseStyle);
    } else {
      return GoogleFonts.poppins().merge(baseStyle);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      onSaved: onSaved,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      style: _getSmartStyle(controller?.text, style),
      decoration: decoration?.copyWith(
            hintText: hintText,
            labelText: labelText,
            hintStyle: _getSmartStyle(hintText, hintStyle),
            labelStyle: _getSmartStyle(labelText, labelStyle),
          ) ??
          InputDecoration(
            hintText: hintText,
            labelText: labelText,
            hintStyle: _getSmartStyle(hintText, hintStyle),
            labelStyle: _getSmartStyle(labelText, labelStyle),
          ),
    );
  }
}
