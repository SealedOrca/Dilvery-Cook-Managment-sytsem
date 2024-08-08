import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class CustomColor {
  static Color backGround = const Color(0xFFE5E5E5).withOpacity(0.10);
  static const Color primaryColor = Color.fromRGBO(12, 115, 246, 1);
  static const Color textColor = Color.fromRGBO(223, 237, 254, 1);
  static const Color primaryButtonColor = Colors.blue;
  static const Color secondaryColor = Colors.blue;
  static const Color backcolor = Color(0xFFF2F1F2);
  static const Color textFieldBorderColor = Color(0xFFE0E6F3);
  static const Color profileTextColor = Color(0xFF9DA8C3);
  static const Color profileTextColorDark = Color(0xFF444444);
}

extension EmptySpace on num {
  SizedBox get height => SizedBox(height: toDouble().h);
  SizedBox get width => SizedBox(width: toDouble().w);
}

AppBar myAppBar({required String title}) {
  return AppBar(
    backgroundColor: CustomColor.primaryColor,
    title: myText(text: title, size: 25, color: CustomColor.textColor),
    centerTitle: true,
    leading: IconButton(
      onPressed: () {
        Get.back();
      },
      icon: const Icon(Icons.arrow_back, color: CustomColor.textColor),
    ),
  );
}

Widget customButton({
  required double width,
  double height = 40,
  double textSize = 14,
  required String text,
  bool border = false,
  var onTap,
  bool borderRadius = false,
  Color textColor = Colors.white,
}) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [
        Color.fromRGBO(118, 175, 248, 1),
        Color.fromRGBO(12, 115, 246, 1),
      ]),
      border: Border.all(
        color: Colors.white.withOpacity(0.2),
        style: BorderStyle.solid,
      ),
      borderRadius: borderRadius == false
          ? BorderRadius.circular(6)
          : BorderRadius.circular(30),
    ),
    child: ClipRRect(
      borderRadius: borderRadius == false
          ? BorderRadius.circular(6)
          : BorderRadius.circular(30),
      child: MaterialButton(
        onPressed: onTap,
        height: height,
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: textSize,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ),
    ),
  );
}

Widget animatedButton({
  required bool isLoading,
  required String text,
  var onTap,
}) {
  return AnimatedSwitcher(
    duration: const Duration(milliseconds: 300),
    child: isLoading
        ? const CircularProgressIndicator(
            color: CustomColor.secondaryColor,
          )
        : customButton(width: double.infinity, text: text, onTap: onTap),
    transitionBuilder: (child, animation) => ScaleTransition(
      scale: animation,
      child: child,
    ),
  );
}

Widget myText({
  required String text,
  Color color = Colors.black,
  double size = 14,
  TextAlign textAlignment = TextAlign.start,
}) {
  return Text(
    text,
    style: TextStyle(color: color, fontSize: size, fontFamily: 'Poppins'),
    textAlign: textAlignment,
  );
}
