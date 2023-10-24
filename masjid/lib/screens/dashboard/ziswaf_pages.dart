import 'package:flutter/material.dart';

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
        child: const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
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
                CustomViewZiswaf(
                  title: 'Zakat',
                  description:
                      "Zakat adalah sejumlah harta yang wajib dikeluarkan oleh umat Muslim untuk diberikan kepada golongan yang berhak menerima, seperti fakir miskin dan semacamnya, sesuai dengan yang ditetapkan oleh syariah",
                ),
                CustomViewZiswaf(
                  title: "Infaq",
                  description:
                      "Infaq sesungguhnya diambil dari kata anfaqa-yunfiqu yang berarti membiayai atau membelanjakan.",
                ),
                CustomViewZiswaf(
                  title: 'Shodaqoh',
                  description:
                      "SEDEKAH (shadaqah/shodaqoh) adalah pemberian sesuatu kepada fakir miskin atau yang berhak menerimanya, di luar kewajiban zakat dan zakat fitrah sesuai dengan kemampuan pemberi.",
                ),
                CustomViewZiswaf(
                  title: "Wakaf",
                  description:
                      "Wakaf adalah Sedekah Jariyah, yakni menyedekahkan harta kita untuk kepentingan ummat. Harta Wakaf tidak boleh berkurang nilainya, tidak boleh dijual dan tidak boleh diwariskan. Karena wakaf pada hakikatnya adalah menyerahkan kepemilikan harta manusia menjadi milik Allah atas nama ummat.",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomViewZiswaf extends StatelessWidget {
  final String title;
  final String description;

  const CustomViewZiswaf({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
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
          margin: const EdgeInsets.only(top: 16.0),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 139, 206, 158),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Transform.scale(
                scale: 0.8,
                child: const Image(
                  image: AssetImage("assets/images/masjid1.png"),
                ),
              ),
              Container(
                width: 1,
                height: 145,
                decoration: BoxDecoration(
                  color: const Color(0xff000000),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.zero,
                  border: Border.all(color: const Color(0x4d9e9e9e), width: 1),
                ),
              ),
              Container(
                width: 200,
                height: 100,
                decoration: const BoxDecoration(
                  shape: BoxShape.rectangle,
                ),
                child: Stack(
                  alignment: Alignment.topLeft,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(135, 0, 0, 0),
                      child: Image(
                        image: const AssetImage("assets/images/moon3.png"),
                        height: MediaQuery.of(context).size.height * 0.13,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.scaleDown,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(3, 20, 0, 0),
                      child: Text(
                        title,
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.clip,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontStyle: FontStyle.normal,
                          fontSize: 14,
                          color: Color(0xff000000),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(3, 35, 0, 0),
                      child: Text(
                        description,
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.clip,
                        softWrap: true,
                        style: const TextStyle(
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
    );
  }
}
