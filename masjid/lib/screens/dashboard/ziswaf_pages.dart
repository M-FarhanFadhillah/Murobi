import 'package:flutter/material.dart';
import 'package:masjid/flutter_flow/flutter_flow_theme.dart';
import 'package:masjid/widget/_build.dart';

class ZiswafPages extends StatelessWidget {
  const ZiswafPages({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: decorationBuilder(
        context,
        Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              textBuilder('ZISWAF', FontWeight.bold, 20, Color(0xff000000)),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      boxBuilder(
                        context,
                        'Zakat',
                        "Zakat berarti bersih, suci, subur, dan berkembang, terdapat zakat fitrah dan mal (harta) yang wajib dilaksanakan dan dapat diwakilkan.",
                      ),
                      boxBuilder(
                        context,
                        "Infaq",
                        "Infaq adalah pemberian harta yang dikeluarkan untuk kepentingan umum, seperti pembangunan masjid, panti asuhan, dan sebagainya.",
                      ),
                      boxBuilder(
                        context,
                        'Shodaqoh',
                        "Harta yang disedehkan akan digunakan untuk mensejerahterakan masyarakat yang membutuhkan.",
                      ),
                      boxBuilder(
                        context,
                        "Wakaf",
                        "Mewakafkan harta kepada Allah yang akan dikelola masjid untuk kepentingan Umat (Tempat Ibadah, Pendidikan, Kesehatan, Sosial, Ekonomi, dll).",
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget boxBuilder(BuildContext context, String title, String description) {
  return WillPopScope(
    onWillPop: () async {
      // param = "";
      return true;
    },
    child: GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/zakatPage', arguments: title);
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 180,
        margin: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 15),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              blurRadius: 6,
              color: Color(0x4B1A1F24),
              offset: Offset(0, 2),
            )
          ],
          gradient: LinearGradient(
            colors: [Color(0xFF00968A), Color(0xFFF2A384)],
            stops: [0, 1],
            begin: AlignmentDirectional(0.94, -1),
            end: AlignmentDirectional(-0.94, 1),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Positioned(
              right: 10,
              child: Image(
                image: AssetImage("assets/images/moon3.png"),
                height: 100,
                width: 100,
                fit: BoxFit.scaleDown,
              ),
            ),
            Positioned(
              top: 20,
              left: 20,
              child: Container(
                width: MediaQuery.of(context).size.width - 100,
                height: 180,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: FlutterFlowTheme.of(context).displaySmall.override(
                            fontFamily: 'Lexend',
                            color: Color.fromRGBO(30, 30, 30, 1.0),
                          ),
                    ),
                    Text(
                      description,
                      softWrap: true,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Lexend',
                          color: Color.fromRGBO(30, 30, 30, 1.0)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
