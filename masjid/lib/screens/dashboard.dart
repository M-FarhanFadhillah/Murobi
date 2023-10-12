import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:ui';
// import 'package:google_fonts/google_fonts.dart';
import 'package:masjid/utils.dart';

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 390,
          height: 844,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-0.27, -0.96),
              end: Alignment(0.27, 0.96),
              colors: [Color(0xFFABFAAB), Color(0xFFA3C8FF), Color(0xFF89E689)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: -1,
                top: 534,
                child: Container(
                  width: 390,
                  height: 326,
                  decoration: ShapeDecoration(
                    color: Color(0xA0F3F3F3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(23),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 338,
                top: -450,
                child: Container(
                  width: 44,
                  height: 44,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: OvalBorder(),
                            shadows: [
                              BoxShadow(
                                color: Color(0x26000000),
                                blurRadius: 14,
                                offset: Offset(2, 4),
                                spreadRadius: 0,
                              )
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 10,
                        top: 9,
                        child: Container(
                          width: 24,
                          height: 24,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 4,
                                top: 2,
                                child: Container(
                                  height: 19.22,
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        left: 2.80,
                                        top: 0,
                                        child: Opacity(
                                          opacity: 0.40,
                                          child: Container(
                                            width: 9.56,
                                            height: 9.56,
                                            decoration: ShapeDecoration(
                                              shape: OvalBorder(
                                                side: BorderSide(
                                                  width: 1.50,
                                                  strokeAlign: BorderSide
                                                      .strokeAlignCenter,
                                                  color: Color(0xFFACB3BD),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 26,
                top: -456,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Masjid As-Syifa\n',
                        style: TextStyle(
                          color: Color(0xFF2E3E5C),
                          fontSize: 22,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          height: 0.07,
                          letterSpacing: 0.50,
                        ),
                      ),
                      TextSpan(
                        text: 'Kecamatan Rajabasa',
                        style: TextStyle(
                          color: Color(0xFF2E3E5C),
                          fontSize: 10,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          height: 0.17,
                          letterSpacing: 0.50,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 7,
                top: -448,
                child: Container(
                  width: 15.08,
                  height: 18,
                  child: Stack(children: []),
                ),
              ),
              Positioned(
                left: 32,
                top: -231,
                child: Container(
                  width: 323,
                  height: 71,
                  decoration: ShapeDecoration(
                    color: Color(0xFF99B6D3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 53,
                top: -222,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: ShapeDecoration(
                    color: Color(0xFFE6E6E6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              Positioned(
                left: 113,
                top: -222,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: ShapeDecoration(
                    color: Color(0xFFE6E6E6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              Positioned(
                left: 173,
                top: -222,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: ShapeDecoration(
                    color: Color(0xFFE6E6E6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              Positioned(
                left: 233,
                top: -222,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: ShapeDecoration(
                    color: Color(0xFFE6E6E6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              Positioned(
                left: 293,
                top: -222,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: ShapeDecoration(
                    color: Color(0xFFE6E6E6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              Positioned(
                left: 61,
                top: -182,
                child: Text(
                  '12:15 ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF2E3E5C),
                    fontSize: 10,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    height: 0.24,
                    letterSpacing: 0.50,
                  ),
                ),
              ),
              Positioned(
                left: 181,
                top: -182,
                child: Text(
                  '12:15 ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF2E3E5C),
                    fontSize: 10,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    height: 0.24,
                    letterSpacing: 0.50,
                  ),
                ),
              ),
              Positioned(
                left: 241,
                top: -182,
                child: Text(
                  '12:15 ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF2E3E5C),
                    fontSize: 10,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    height: 0.24,
                    letterSpacing: 0.50,
                  ),
                ),
              ),
              Positioned(
                left: 301,
                top: -182,
                child: Text(
                  '12:15 ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF2E3E5C),
                    fontSize: 10,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    height: 0.24,
                    letterSpacing: 0.50,
                  ),
                ),
              ),
              Positioned(
                left: 121,
                top: -182,
                child: Text(
                  '12:15 ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF2E3E5C),
                    fontSize: 10,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    height: 0.24,
                    letterSpacing: 0.50,
                  ),
                ),
              ),
              Positioned(
                left: 32,
                top: -131,
                child: Container(
                  width: 323,
                  height: 183,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 32,
                top: -370,
                child: Container(
                  width: 323,
                  height: 133,
                  decoration: ShapeDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(0.00, -1.00),
                      end: Alignment(0, 1),
                      colors: [Color(0xFF668DB3), Color(0xE575A5D4)],
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 189,
                top: -281,
                child: Container(
                  width: 162,
                  height: 30,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 24.85,
                        top: 3,
                        child: Container(
                          width: 137.15,
                          height: 26,
                          decoration: ShapeDecoration(
                            color: Color(0xFF008074),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 1.99,
                        top: 0,
                        child: SizedBox(
                          width: 116.28,
                          height: 20,
                          child: Text(
                            'Masjid As-syifa',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              height: 0.24,
                              letterSpacing: 0.50,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        top: 8,
                        child: SizedBox(
                          width: 116.28,
                          height: 20,
                          child: Text(
                            'Rajabasa, Bandar Lampung',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 5,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              height: 0.96,
                              letterSpacing: 0.50,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 133.18,
                        top: 0,
                        child: Container(
                          width: 26.83,
                          height: 30,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(),
                          child: Stack(
                            children: [
                              Positioned(
                                left: 6.71,
                                top: 11.88,
                                child: Container(
                                  width: 13.42,
                                  height: 7.50,
                                  child: Stack(children: []),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 142,
                top: -323,
                child: Text(
                  '27 agustus 2023',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Color(0xFF2E3E5C),
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    height: 0.17,
                    letterSpacing: 0.50,
                  ),
                ),
              ),
              Positioned(
                left: 144,
                top: -347,
                child: Text(
                  '12:15:40 ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF2E3E5C),
                    fontSize: 24,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w900,
                    height: 0.04,
                    letterSpacing: 0.50,
                  ),
                ),
              ),
              Positioned(
                left: 355,
                top: -370,
                child: Transform(
                  transform: Matrix4.identity()
                    ..translate(0.0, 0.0)
                    ..rotateZ(3.14),
                  child: Container(
                    width: 60,
                    height: 63,
                    decoration: ShapeDecoration(
                      image: DecorationImage(
                        image:
                            NetworkImage("https://via.placeholder.com/60x63"),
                        fit: BoxFit.cover,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 32,
                top: -370,
                child: Container(
                  width: 60,
                  height: 61,
                  decoration: ShapeDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://via.placeholder.com/60x61"),
                      fit: BoxFit.cover,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: -10,
                top: -314,
                child: Container(
                  width: 172,
                  height: 80,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://via.placeholder.com/172x80"),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 313,
                top: -306,
                child: Container(
                  width: 38,
                  height: 25,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://via.placeholder.com/38x25"),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 35,
                top: 110,
                child: Container(
                  width: 323,
                  height: 133,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          width: 323,
                          height: 133,
                          decoration: ShapeDecoration(
                            gradient: LinearGradient(
                              begin: Alignment(0.00, -1.00),
                              end: Alignment(0, 1),
                              colors: [Color(0xFF668DB3), Color(0xE575A5D4)],
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 181.85,
                        top: 92,
                        child: Container(
                          width: 137.15,
                          height: 26,
                          decoration: ShapeDecoration(
                            color: Color(0xFF008074),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 158.99,
                        top: 89,
                        child: SizedBox(
                          width: 116.28,
                          height: 20,
                          child: Text(
                            'Masjid As-syifa',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              height: 0.24,
                              letterSpacing: 0.50,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 157,
                        top: 97,
                        child: SizedBox(
                          width: 116.28,
                          height: 20,
                          child: Text(
                            'Rajabasa, Bandar Lampung',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 5,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              height: 0.96,
                              letterSpacing: 0.50,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 290.18,
                        top: 89,
                        child: Container(
                          width: 26.83,
                          height: 30,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(),
                          child: Stack(
                            children: [
                              Positioned(
                                left: 6.71,
                                top: 11.88,
                                child: Container(
                                  width: 13.42,
                                  height: 7.50,
                                  child: Stack(children: []),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 112,
                        top: 23,
                        child: Text(
                          '12:15:40 ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF2E3E5C),
                            fontSize: 24,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w900,
                            height: 0.04,
                            letterSpacing: 0.50,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 323,
                        top: 0,
                        child: Transform(
                          transform: Matrix4.identity()
                            ..translate(0.0, 0.0)
                            ..rotateZ(3.14),
                          child: Container(
                            width: 60,
                            height: 63,
                            decoration: ShapeDecoration(
                              image: DecorationImage(
                                image: NetworkImage(
                                    "https://via.placeholder.com/60x63"),
                                fit: BoxFit.cover,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          width: 60,
                          height: 61,
                          decoration: ShapeDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                  "https://via.placeholder.com/60x61"),
                              fit: BoxFit.cover,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(17),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 6,
                        top: 53,
                        child: Container(
                          width: 81,
                          height: 80,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                  "https://via.placeholder.com/81x80"),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 144,
                top: 151,
                child: Text(
                  '27 agustus 2023',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Color(0xFF2E3E5C),
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    height: 0.17,
                    letterSpacing: 0.50,
                  ),
                ),
              ),
              Positioned(
                left: 178,
                top: 509,
                child: Container(
                  width: 34.19,
                  height: 8,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          width: 8.39,
                          height: 8,
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: OvalBorder(),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 13,
                        top: 0,
                        child: Container(
                          width: 8.39,
                          height: 8,
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: OvalBorder(),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 25.81,
                        top: 0,
                        child: Container(
                          width: 8.39,
                          height: 8,
                          decoration: ShapeDecoration(
                            color: Color(0xFF336DA6),
                            shape: OvalBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 806,
                child: Container(
                  width: 1,
                  height: 4,
                  decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
                ),
              ),
              Positioned(
                left: 44,
                top: 796,
                child: Container(width: 48, height: 48),
              ),
              Positioned(
                left: 35,
                top: 253,
                child: Container(
                  width: 323,
                  height: 75,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          width: 323,
                          height: 75,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                top: 0,
                                child: Container(
                                  width: 323,
                                  height: 75,
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        left: 0,
                                        top: 0,
                                        child: Container(
                                          width: 323,
                                          height: 71,
                                          decoration: ShapeDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment(0.00, -1.00),
                                              end: Alignment(0, 1),
                                              colors: [
                                                Color(0xFF688FB5),
                                                Color(0xFF79A9D1)
                                              ],
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        left: 26,
                                        top: 41,
                                        child: Container(
                                          width: 273,
                                          height: 34,
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 0,
                                                top: 0,
                                                child: Text(
                                                  '04:35',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Color(0xFF2E3E5C),
                                                    fontSize: 10,
                                                    fontFamily: 'Poppins',
                                                    fontWeight: FontWeight.w400,
                                                    height: 0.24,
                                                    letterSpacing: 0.50,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left: 2,
                                                top: 10,
                                                child: SizedBox(
                                                  width: 26,
                                                  child: Text(
                                                    'Subuh',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Color(0xFF2E3E5C),
                                                      fontSize: 7,
                                                      fontFamily: 'Poppins',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      height: 0.49,
                                                      letterSpacing: 0.50,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left: 61,
                                                top: 10,
                                                child: SizedBox(
                                                  width: 27,
                                                  child: Text(
                                                    'Dzuhur',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Color(0xFF2E3E5C),
                                                      fontSize: 7,
                                                      fontFamily: 'Poppins',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      height: 0.49,
                                                      letterSpacing: 0.50,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left: 121,
                                                top: 10,
                                                child: SizedBox(
                                                  width: 27,
                                                  child: Text(
                                                    'Ashar',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Color(0xFF2E3E5C),
                                                      fontSize: 7,
                                                      fontFamily: 'Poppins',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      height: 0.49,
                                                      letterSpacing: 0.50,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left: 179,
                                                top: 10,
                                                child: SizedBox(
                                                  width: 34,
                                                  child: Text(
                                                    'Maghrib',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Color(0xFF2E3E5C),
                                                      fontSize: 7,
                                                      fontFamily: 'Poppins',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      height: 0.49,
                                                      letterSpacing: 0.50,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left: 239,
                                                top: 10,
                                                child: SizedBox(
                                                  width: 34,
                                                  child: Text(
                                                    'Isya’',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Color(0xFF2E3E5C),
                                                      fontSize: 7,
                                                      fontFamily: 'Poppins',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      height: 0.49,
                                                      letterSpacing: 0.50,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left: 123,
                                                top: 0,
                                                child: Text(
                                                  '15:15',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Color(0xFF2E3E5C),
                                                    fontSize: 10,
                                                    fontFamily: 'Poppins',
                                                    fontWeight: FontWeight.w400,
                                                    height: 0.24,
                                                    letterSpacing: 0.50,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left: 184,
                                                top: 0,
                                                child: Text(
                                                  '18:19',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Color(0xFF2E3E5C),
                                                    fontSize: 10,
                                                    fontFamily: 'Poppins',
                                                    fontWeight: FontWeight.w400,
                                                    height: 0.24,
                                                    letterSpacing: 0.50,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left: 243,
                                                top: 0,
                                                child: Text(
                                                  '19:07',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Color(0xFF2E3E5C),
                                                    fontSize: 10,
                                                    fontFamily: 'Poppins',
                                                    fontWeight: FontWeight.w400,
                                                    height: 0.24,
                                                    letterSpacing: 0.50,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left: 63,
                                                top: 0,
                                                child: Text(
                                                  '12:15 ',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Color(0xFF2E3E5C),
                                                    fontSize: 10,
                                                    fontFamily: 'Poppins',
                                                    fontWeight: FontWeight.w400,
                                                    height: 0.24,
                                                    letterSpacing: 0.50,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 139,
                                top: 3,
                                child: Container(
                                  width: 44,
                                  height: 42,
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        left: 0,
                                        top: 0,
                                        child: Container(
                                          width: 44,
                                          height: 42,
                                          decoration: ShapeDecoration(
                                            color: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(11),
                                            ),
                                            shadows: [
                                              BoxShadow(
                                                color: Color(0x0C000000),
                                                blurRadius: 10,
                                                offset: Offset(0, 0),
                                                spreadRadius: 0,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        left: 2,
                                        top: 2,
                                        child: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: ShapeDecoration(
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                  "https://via.placeholder.com/40x40"),
                                              fit: BoxFit.cover,
                                            ),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 201,
                                top: 5,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: ShapeDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(
                                          "https://via.placeholder.com/40x40"),
                                      fit: BoxFit.cover,
                                    ),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 261,
                                top: 5,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        left: 0,
                                        top: 0,
                                        child: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: ShapeDecoration(
                                            color: Colors.white,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            shadows: [
                                              BoxShadow(
                                                color: Color(0x0C000000),
                                                blurRadius: 10,
                                                offset: Offset(0, 0),
                                                spreadRadius: 0,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        left: -29,
                                        top: 0,
                                        child: Container(
                                          width: 98.91,
                                          height: 42.76,
                                          decoration: ShapeDecoration(
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                  "https://via.placeholder.com/99x43"),
                                              fit: BoxFit.fill,
                                            ),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 81,
                        top: 5,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: ShapeDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                  "https://via.placeholder.com/40x40"),
                              fit: BoxFit.cover,
                            ),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 21,
                        top: 5,
                        child: Container(
                          width: 40,
                          height: 40,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                top: 0,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: ShapeDecoration(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    shadows: [
                                      BoxShadow(
                                        color: Color(0x0C000000),
                                        blurRadius: 10,
                                        offset: Offset(0, 0),
                                        spreadRadius: 0,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: -67,
                                top: -18,
                                child: Container(
                                  width: 173,
                                  height: 79,
                                  decoration: ShapeDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(
                                          "https://via.placeholder.com/173x79"),
                                      fit: BoxFit.cover,
                                    ),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 7,
                top: 793,
                child: Container(
                  width: 375,
                  height: 56,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          width: 375,
                          height: 56,
                          decoration: ShapeDecoration(
                            color: Color(0xFFFAFCFF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                            shadows: [
                              BoxShadow(
                                color: Color(0x14000000),
                                blurRadius: 14,
                                offset: Offset(2, -4),
                                spreadRadius: 0,
                              )
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 18,
                        top: 6,
                        child: Container(
                          width: 340,
                          height: 39.35,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 86,
                                top: 0,
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        left: 4,
                                        top: 2,
                                        child: Container(
                                          height: 19.22,
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 2.80,
                                                top: 0,
                                                child: Opacity(
                                                  opacity: 0.40,
                                                  child: Container(
                                                    width: 9.56,
                                                    height: 9.56,
                                                    decoration: ShapeDecoration(
                                                      shape: OvalBorder(
                                                        side: BorderSide(
                                                          width: 1.50,
                                                          strokeAlign: BorderSide
                                                              .strokeAlignCenter,
                                                          color:
                                                              Color(0xFFACB3BD),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 235,
                                top: 0,
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        left: 2.78,
                                        top: 2.28,
                                        child: Container(
                                          width: 19.14,
                                          height: 19.20,
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 15.30,
                                                top: 0,
                                                child: Container(
                                                  width: 3.84,
                                                  height: 3.84,
                                                  decoration: ShapeDecoration(
                                                    shape: OvalBorder(
                                                      side: BorderSide(
                                                        width: 1.50,
                                                        strokeAlign: BorderSide
                                                            .strokeAlignCenter,
                                                        color:
                                                            Color(0xFFACB3BD),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 310,
                                top: 0,
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        left: 2,
                                        top: 2,
                                        child: Container(
                                          width: 19.22,
                                          height: 19.22,
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 0,
                                                top: 0,
                                                child: Container(
                                                  width: 19.22,
                                                  height: 19.22,
                                                  decoration: ShapeDecoration(
                                                    shape: OvalBorder(
                                                      side: BorderSide(
                                                        width: 1.50,
                                                        strokeAlign: BorderSide
                                                            .strokeAlignCenter,
                                                        color:
                                                            Color(0xFFACB3BD),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 161,
                                top: 0,
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              height: 20,
                                              child: Stack(children: []),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 305,
                                top: 27,
                                child: SizedBox(
                                  width: 35,
                                  height: 12.35,
                                  child: Text(
                                    'Qurban',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 7,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w400,
                                      height: 0,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 229,
                                top: 27,
                                child: SizedBox(
                                  width: 37,
                                  height: 12,
                                  child: Text(
                                    'Keuangan',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 7,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w400,
                                      height: 0,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 155,
                                top: 27,
                                child: SizedBox(
                                  width: 35,
                                  height: 12.35,
                                  child: Text(
                                    'Ibadah',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 7,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w400,
                                      height: 0,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 74,
                                top: 27,
                                child: SizedBox(
                                  width: 42,
                                  height: 12.35,
                                  child: Text(
                                    'Edukasi',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 7,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w400,
                                      height: 0,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 0,
                                top: 27,
                                child: SizedBox(
                                  width: 35,
                                  height: 12.35,
                                  child: Text(
                                    'Beranda',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 7,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w400,
                                      height: 0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 374,
                top: 342,
                child: Container(
                  width: 345,
                  height: 160,
                  decoration: ShapeDecoration(
                    image: DecorationImage(
                      image:
                          NetworkImage("https://via.placeholder.com/345x160"),
                      fit: BoxFit.fill,
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              Positioned(
                left: 6,
                top: 42,
                child: Container(
                  width: 376,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 272,
                        top: 0,
                        child: Container(
                          width: 104,
                          height: 44,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                top: 2,
                                child: Container(width: 58, height: 41),
                              ),
                              Positioned(
                                left: 60,
                                top: 0,
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        left: 0,
                                        top: 0,
                                        child: Container(
                                          width: 44,
                                          height: 44,
                                          decoration: ShapeDecoration(
                                            color: Color(0xFFF1F6FB),
                                            shape: OvalBorder(),
                                            shadows: [
                                              BoxShadow(
                                                color: Color(0x26000000),
                                                blurRadius: 14,
                                                offset: Offset(2, 4),
                                                spreadRadius: 0,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        left: 10,
                                        top: 9,
                                        child: Container(
                                          width: 24,
                                          height: 24,
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 4,
                                                top: 2,
                                                child: Container(
                                                  height: 19.22,
                                                  child: Stack(
                                                    children: [
                                                      Positioned(
                                                        left: 2.80,
                                                        top: 0,
                                                        child: Opacity(
                                                          opacity: 0.40,
                                                          child: Container(
                                                            width: 9.56,
                                                            height: 9.56,
                                                            decoration:
                                                                ShapeDecoration(
                                                              shape: OvalBorder(
                                                                side:
                                                                    BorderSide(
                                                                  width: 1.50,
                                                                  strokeAlign:
                                                                      BorderSide
                                                                          .strokeAlignCenter,
                                                                  color: Color(
                                                                      0xFFD9D9D9),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          width: 204,
                          height: 46,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 19,
                                top: 0,
                                child: SizedBox(
                                  width: 185,
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Masjid As-Syifa\n',
                                          style: TextStyle(
                                            color: Color(0xFF2E3E5C),
                                            fontSize: 22,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w700,
                                            height: 0.07,
                                            letterSpacing: 0.50,
                                          ),
                                        ),
                                        TextSpan(
                                          text: 'Kecamatan Rajabasa',
                                          style: TextStyle(
                                            color: Color(0xFF2E3E5C),
                                            fontSize: 10,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w400,
                                            height: 0.17,
                                            letterSpacing: 0.50,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 0,
                                top: 8,
                                child: Container(
                                  width: 15.08,
                                  height: 18,
                                  child: Stack(children: []),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: -307,
                top: 342,
                child: Container(
                  width: 323,
                  height: 220.10,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          width: 323,
                          height: 160,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                top: 0,
                                child: Container(
                                  width: 323,
                                  height: 160,
                                  decoration: ShapeDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(
                                          "https://via.placeholder.com/323x160"),
                                      fit: BoxFit.fill,
                                    ),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 165.13,
                                top: 118.52,
                                child: Container(
                                  width: 67.51,
                                  height: 18.77,
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        left: 0,
                                        top: 0,
                                        child: Container(
                                          width: 61.28,
                                          height: 18.77,
                                          decoration: ShapeDecoration(
                                            color: Color(0xFFEDDA7A),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            shadows: [
                                              BoxShadow(
                                                color: Color(0x3F000000),
                                                blurRadius: 4,
                                                offset: Offset(0, 4),
                                                spreadRadius: 0,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        left: 5.19,
                                        top: 1.98,
                                        child: SizedBox(
                                          width: 62.32,
                                          height: 13.83,
                                          child: Text(
                                            'klik disini',
                                            style: TextStyle(
                                              color: Color(0xFF8F1515),
                                              fontSize: 10,
                                              fontFamily: 'Cherry Bomb One',
                                              fontWeight: FontWeight.w400,
                                              height: 0,
                                              letterSpacing: 0.50,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 108.01,
                                top: 89.88,
                                child: Transform(
                                  transform: Matrix4.identity()
                                    ..translate(0.0, 0.0)
                                    ..rotateZ(-0.23),
                                  child: Container(
                                    width: 114.98,
                                    height: 52.50,
                                    decoration: ShapeDecoration(
                                      image: DecorationImage(
                                        image: NetworkImage(
                                            "https://via.placeholder.com/115x52"),
                                        fit: BoxFit.fill,
                                      ),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 176.69,
                        top: 131.75,
                        child: Transform(
                          transform: Matrix4.identity()
                            ..translate(0.0, 0.0)
                            ..rotateZ(-0.45),
                          child: Container(
                            width: 108.03,
                            height: 98,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(
                                    "https://via.placeholder.com/108x98"),
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 7,
                top: 575,
                child: Container(
                  width: 375,
                  height: 198,
                  decoration: ShapeDecoration(
                    image: DecorationImage(
                      image:
                          NetworkImage("https://via.placeholder.com/375x198"),
                      fit: BoxFit.fill,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 9,
                top: 550,
                child: SizedBox(
                  width: 137,
                  height: 22,
                  child: Text(
                    'Kegiatan Masjid',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontFamily: 'PoetsenOne',
                      fontWeight: FontWeight.w400,
                      height: 0,
                      letterSpacing: 0.50,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 296,
                top: 547,
                child: Container(
                  width: 90,
                  height: 28,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 64,
                        top: 0,
                        child: Container(
                          width: 26,
                          height: 25,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Container(
                                  height: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7.58, vertical: 6.25),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Transform(
                                        transform: Matrix4.identity()
                                          ..translate(0.0, 0.0)
                                          ..rotateZ(-1.57),
                                        child: Container(
                                          width: 12.50,
                                          height: 10.83,
                                          child: Stack(children: []),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        top: 6,
                        child: SizedBox(
                          width: 78,
                          height: 22,
                          child: Text(
                            'Lihat lainnya ',
                            style: TextStyle(
                              color: Color(0xFF004890),
                              fontSize: 10,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                              height: 0,
                              letterSpacing: 0.50,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 35,
                top: 342,
                child: Container(
                  width: 323,
                  height: 160,
                  decoration: ShapeDecoration(
                    image: DecorationImage(
                      image:
                          NetworkImage("https://via.placeholder.com/323x160"),
                      fit: BoxFit.fill,
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              Positioned(
                left: 122,
                top: 342,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'الرَّحْمَٰنِ الرَّحِيمِ ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontFamily: 'Amiri',
                          fontWeight: FontWeight.w700,
                          height: 0,
                        ),
                      ),
                      TextSpan(
                        text: '﴿ ٣﴾',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontFamily: 'Amiri',
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                          height: 0,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
