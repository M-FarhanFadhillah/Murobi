import 'package:flutter/material.dart';
import 'package:masjid/flutter_flow/flutter_flow_theme.dart';
import 'package:masjid/flutter_flow/flutter_flow_widgets.dart';

class DetailZiswafPages extends StatefulWidget {
  const DetailZiswafPages({super.key});

  @override
  _DetailZiswafPagesState createState() => _DetailZiswafPagesState();
}

class _DetailZiswafPagesState extends State<DetailZiswafPages> {
  @override
  Widget build(BuildContext context) {
    late final String title =
        ModalRoute.of(context)?.settings.arguments as String;
    late final String userName = 'Ahmad';
    late final String totalZakat = '2.000.000';
    late final String totalZakatBulanN = '100.000';

    List<Map<String, dynamic>> dataFromDatabase = [
      {'kolom1': 'Data 1.1', 'kolom2': 'Data 1.2', 'kolom3': 'Data 1.3'},
      {'kolom1': 'Data 2.1', 'kolom2': 'Data 2.2', 'kolom3': 'Data 2.3'},
      // ... Tambahkan data lainnya sesuai kebutuhan Anda
    ];

    DataTable buildDataTable(List<Map<String, dynamic>> data) {
      List<DataRow> rows = [];

      for (var item in data) {
        rows.add(DataRow(cells: [
          DataCell(Text(item['kolom1'].toString())),
          DataCell(Text(item['kolom2'].toString())),
          DataCell(Text(item['kolom3'].toString())),
        ]));
      }

      return DataTable(
        columns: [
          DataColumn(label: Text('Kolom 1')),
          DataColumn(label: Text('Kolom 2')),
          DataColumn(label: Text('Kolom 3')),
        ],
        rows: rows,
      );
    }

    return Scaffold(
      body: SafeArea(
          child: Container(
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
                          Text(
                            title,
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
                          Container(
                            margin: EdgeInsets.only(top: 16, bottom: 16),
                            width: MediaQuery.of(context).size.width,
                            height: 100,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 139, 206, 158),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Row(
                              children: [
                                Transform.scale(
                                  scale: 0.8,
                                  child: const Image(
                                    image:
                                        AssetImage("assets/images/masjid1.png"),
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(userName),
                                    Text(
                                        'Total Zakat Anda\t:\nRp. $totalZakat'),
                                    Text(
                                        'Total Zakat Bulan Ini\t:\nRp. $totalZakatBulanN')
                                  ],
                                )
                              ],
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height / 3 +
                                100 +
                                44,
                            margin: EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 139, 206, 158),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(top: 10),
                                  child: Text(
                                    'History $title Anda',
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.clip,
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 10),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      child: buildDataTable(dataFromDatabase),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          FFButtonWidget(
                              text: 'Ayo Ber$title',
                              onPressed: () {},
                              options: FFButtonOptions(
                                width: double.infinity,
                                height: 44.0,
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 0.0),
                                iconPadding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 0.0),
                                color: Color(0xFF4B39EF),
                                textStyle: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .override(
                                      fontFamily: 'Plus Jakarta Sans',
                                      color: Colors.white,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                elevation: 3.0,
                                borderSide: BorderSide(
                                  color: Colors.transparent,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                              ))
                        ]),
                  )))),
    );
  }
}
