import 'package:flutter/material.dart';
import 'package:masjid/screens/splashscreen.dart';

class ZiswafPages extends StatelessWidget {
  const ZiswafPages({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(170, 245, 179, 1),
              Color.fromRGBO(165, 210, 238, 1)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                const Text(
                  "ZISWAF",
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                    fontFamily: 'poppins',
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.normal,
                    fontSize: 20,
                    color: Color(0xff000000),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SplashScreen(),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(top: 16.0),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 139, 206, 158),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Transform.scale(
                          scale: 0.8,
                          child: Image(
                            image: AssetImage("assets/images/masjid1.png"),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 145,
                          decoration: BoxDecoration(
                            color: Color(0xff000000),
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.zero,
                            border:
                                Border.all(color: Color(0x4d9e9e9e), width: 1),
                          ),
                        ),
                        Container(
                          width: 200,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                          ),
                          child: Stack(
                            alignment: Alignment.topLeft,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(135, 0, 0, 0),
                                child: Image(
                                  image: AssetImage("assets/images/moon3.png"),
                                  height:
                                      MediaQuery.of(context).size.height * 0.13,
                                  width: MediaQuery.of(context).size.width,
                                  fit: BoxFit.scaleDown,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.fromLTRB(3, 20, 0, 0),
                                child: Text(
                                  "ZAKAT",
                                  textAlign: TextAlign.left,
                                  overflow: TextOverflow.clip,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontStyle: FontStyle.normal,
                                    fontSize: 14,
                                    color: Color(0xff000000),
                                  ),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.fromLTRB(3, 35, 0, 0),
                                child: Text(
                                  "Zakat adalah sejumlah harta yang wajib dikeluarkan oleh umat Muslim untuk diberikan kepada golongan yang berhak menerima, seperti fakir miskin dan semacamnya, sesuai dengan yang ditetapkan oleh syariah",
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.clip,
                                  softWrap: true,
                                  style: TextStyle(
                                    fontFamily: 'poppins',
                                    fontSize: 14,
                                    color: Color(0xff000000),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 16.0),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 139, 206, 158),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Transform.scale(
                        scale: 0.8,
                        child: Image(
                          image: AssetImage("assets/images/masjid1.png"),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 145,
                        decoration: BoxDecoration(
                          color: Color(0xff000000),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.zero,
                          border:
                              Border.all(color: Color(0x4d9e9e9e), width: 1),
                        ),
                      ),
                      Container(
                        width: 200,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                        ),
                        child: Stack(
                          alignment: Alignment.topLeft,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(135, 0, 0, 0),
                              child: Image(
                                image: AssetImage("assets/images/moon3.png"),
                                height:
                                    MediaQuery.of(context).size.height * 0.13,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.scaleDown,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.fromLTRB(3, 20, 0, 0),
                              child: Text(
                                "Infaq",
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.clip,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontStyle: FontStyle.normal,
                                  fontSize: 14,
                                  color: Color(0xff000000),
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.fromLTRB(3, 35, 0, 0),
                              child: Text(
                                "Infaq sesungguhnya diambil dari kata anfaqa-yunfiqu yang berarti membiayai atau membelanjakan.",
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.clip,
                                softWrap: true,
                                style: TextStyle(
                                  fontFamily: 'poppins',
                                  fontSize: 14,
                                  color: Color(0xff000000),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 16.0),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 139, 206, 158),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Transform.scale(
                        scale: 0.8,
                        child: Image(
                          image: AssetImage("assets/images/masjid1.png"),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 145,
                        decoration: BoxDecoration(
                          color: Color(0xff000000),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.zero,
                          border:
                              Border.all(color: Color(0x4d9e9e9e), width: 1),
                        ),
                      ),
                      Container(
                        width: 200,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                        ),
                        child: Stack(
                          alignment: Alignment.topLeft,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(135, 0, 0, 0),
                              child: Image(
                                image: AssetImage("assets/images/moon3.png"),
                                height:
                                    MediaQuery.of(context).size.height * 0.13,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.scaleDown,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.fromLTRB(3, 20, 0, 0),
                              child: Text(
                                "Shodaqoh",
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.clip,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontStyle: FontStyle.normal,
                                  fontSize: 14,
                                  color: Color(0xff000000),
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.fromLTRB(3, 35, 0, 0),
                              child: Text(
                                "SEDEKAH (shadaqah/shodaqoh) adalah pemberian sesuatu kepada fakir miskin atau yang berhak menerimanya, di luar kewajiban zakat dan zakat fitrah sesuai dengan kemampuan pemberi.",
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.clip,
                                softWrap: true,
                                style: TextStyle(
                                  fontFamily: 'poppins',
                                  fontSize: 14,
                                  color: Color(0xff000000),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 16.0),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 139, 206, 158),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Transform.scale(
                        scale: 0.8,
                        child: Image(
                          image: AssetImage("assets/images/masjid1.png"),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 145,
                        decoration: BoxDecoration(
                          color: Color(0xff000000),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.zero,
                          border:
                              Border.all(color: Color(0x4d9e9e9e), width: 1),
                        ),
                      ),
                      Container(
                        width: 200,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                        ),
                        child: Stack(
                          alignment: Alignment.topLeft,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(135, 0, 0, 0),
                              child: Image(
                                image: AssetImage("assets/images/moon3.png"),
                                height:
                                    MediaQuery.of(context).size.height * 0.13,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.scaleDown,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.fromLTRB(3, 20, 0, 0),
                              child: Text(
                                "Wakaf",
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.clip,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontStyle: FontStyle.normal,
                                  fontSize: 14,
                                  color: Color(0xff000000),
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.fromLTRB(3, 35, 0, 0),
                              child: Text(
                                "Wakaf adalah Sedekah Jariyah, yakni menyedekahkan harta kita untuk kepentingan ummat. Harta Wakaf tidak boleh berkurang nilainya, tidak boleh dijual dan tidak boleh diwariskan. Karena wakaf pada hakikatnya adalah menyerahkan kepemilikan harta manusia menjadi milik Allah atas nama ummat.",
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.clip,
                                softWrap: true,
                                style: TextStyle(
                                  fontFamily: 'poppins',
                                  fontSize: 14,
                                  color: Color(0xff000000),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
