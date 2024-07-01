import 'package:flutter/material.dart';

Widget CARD_DESTAQUES(String text, String imagePath) {
  return Stack(
    children: [
      Container(
        width: 347,
        height: 240,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          color: Colors.black.withOpacity(0.25),
          backgroundBlendMode: BlendMode.multiply,
        ),
      ),
      Positioned(
        top: 174,
        left: 0,
        child: Container(
          width: 195,
          height: 48,
          decoration: ShapeDecoration(
            color: Colors.black.withOpacity(0.66),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 12,
                top: 8,
                child: Container(
                  width: 7,
                  height: 32,
                  decoration: BoxDecoration(color: Color(0xFF15659F)),
                ),
              ),
              Positioned(
                left: 26,
                top: 22,
                child: SizedBox(
                  width: 185,
                  height: 22,
                  child: Text(
                    text,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontFamily: 'Ubuntu',
                      fontWeight: FontWeight.w700,
                      height: 0.07,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    ],
  );
}
