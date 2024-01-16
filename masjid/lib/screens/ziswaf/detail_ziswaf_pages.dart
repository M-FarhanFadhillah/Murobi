import 'package:flutter/material.dart';
import 'package:masjid/flutter_flow/flutter_flow_theme.dart';
import 'package:masjid/flutter_flow/flutter_flow_widgets.dart';
import 'package:masjid/widget/_build.dart';

class DetailZiswafPages extends StatefulWidget {
  const DetailZiswafPages({Key? key}) : super(key: key);

  @override
  _DetailZiswafPagesState createState() => _DetailZiswafPagesState();
}

class _DetailZiswafPagesState extends State<DetailZiswafPages> {
  @override
  Widget build(BuildContext context) {
    late final String title =
        ModalRoute.of(context)?.settings.arguments as String;
    String userDisplayName = "Ahmad";
    List<Map<String, dynamic>> dataFromDatabase = [
      {'kolom1': 'Data 1.1', 'kolom2': 'Data 1.2', 'kolom3': 'Data 1.3'},
      {'kolom1': 'Data 2.1', 'kolom2': 'Data 2.2', 'kolom3': 'Data 2.3'},
      {'kolom1': 'Data 3.1', 'kolom2': 'Data 3.2', 'kolom3': 'Data 3.3'},
      {'kolom1': 'Data 4.1', 'kolom2': 'Data 4.2', 'kolom3': 'Data 4.3'},
      {'kolom1': 'Data 5.1', 'kolom2': 'Data 5.2', 'kolom3': 'Data 5.3'},
      {'kolom1': 'Data 6.1', 'kolom2': 'Data 6.2', 'kolom3': 'Data 6.3'},
      {'kolom1': 'Data 7.1', 'kolom2': 'Data 7.2', 'kolom3': 'Data 7.3'},
      {'kolom1': 'Data 8.1', 'kolom2': 'Data 8.2', 'kolom3': 'Data 8.3'},
      // ... Tambahkan data lainnya sesuai kebutuhan Anda
    ];

    DataTable buildDataTable(List<Map<String, dynamic>> data) {
      final List<DataColumn> columns = [];
      final List<DataRow> rows = [];

      // Assuming all rows have the same keys, use the keys from the first row
      final keys = data.isNotEmpty ? data.first.keys.toList() : [];

      // Create DataColumn for each key
      columns.addAll(keys.map((key) => DataColumn(label: Text(key))));

      // Create DataRow for each item in data
      rows.addAll(data.map((item) {
        return DataRow(
          cells: keys
              .map(
                (key) => DataCell(Text(item[key].toString())),
              )
              .toList(),
        );
      }));

      return DataTable(columns: columns, rows: rows);
    }

    return Scaffold(
      body: SafeArea(
        child: decorationBuilder(
          context,
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.clip,
                  style: const TextStyle(
                    fontFamily: 'poppins',
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.normal,
                    fontSize: 20,
                    color: Color(0xff000000),
                  ),
                ),
                const SizedBox(height: 06),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 180,
                  margin: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 15),
                  decoration: BoxDecoration(
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 6,
                        color: Color(0x4B1A1F24),
                        offset: Offset(0, 2),
                      )
                    ],
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00968A), Color(0xFFF2A384)],
                      stops: [0, 1],
                      begin: AlignmentDirectional(0.94, -1),
                      end: AlignmentDirectional(-0.94, 1),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(16, 16, 16, 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Card(
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              color: FlutterFlowTheme.of(context).primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(2),
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  child: Image.asset(
                                    'assets/images/avatar.png',
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Text(
                                        'Welcome,',
                                        style: FlutterFlowTheme.of(context)
                                            .headlineSmall,
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            4, 0, 0, 0),
                                        child: Text(
                                          userDisplayName,
                                          style: FlutterFlowTheme.of(context)
                                              .headlineSmall
                                              .override(
                                                fontFamily: 'Lexend',
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'Your account Details are below...',
                                    style:
                                        FlutterFlowTheme.of(context).bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(20, 12, 0, 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text(
                              'Total $title',
                              style: FlutterFlowTheme.of(context).bodyMedium,
                            ),
                            SizedBox(width: 100),
                            Text(
                              '$title Bulan ini',
                              style: FlutterFlowTheme.of(context).bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text(
                              '\$25,202',
                              style: FlutterFlowTheme.of(context)
                                  .displaySmall
                                  .override(
                                    fontFamily: 'Lexend',
                                    fontSize: 32,
                                  ),
                            ),
                            SizedBox(width: 50),
                            Text(
                              '\$25,202',
                              style: FlutterFlowTheme.of(context)
                                  .displaySmall
                                  .override(
                                    fontFamily: 'Lexend',
                                    fontSize: 32,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  child: Column(
                    children: List.generate(
                      3, // Change this to the number of cards you want
                      (index) => generateCard(
                        'Go Far Rewards',
                        'Income',
                        '\$50.00',
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                FFButtonWidget(
                    text: 'Ayo Ber$title',
                    onPressed: () {},
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 44.0,
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 0.0, 0.0, 0.0),
                      iconPadding: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 0.0, 0.0, 0.0),
                      color: const Color(0xFF4B39EF),
                      textStyle:
                          FlutterFlowTheme.of(context).titleSmall.override(
                                fontFamily: 'Plus Jakarta Sans',
                                color: Colors.white,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500,
                              ),
                      elevation: 3.0,
                      borderSide: const BorderSide(
                        color: Colors.transparent,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(12.0),
                    )),
                const SizedBox(height: 16)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget generateCard(String title, String subtitle, String amount) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 12.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 70.0,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primaryBackground,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 0.0, 0.0),
              child: Card(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                color: Color(0x6639D2C0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40.0),
                ),
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.monetization_on_rounded,
                    color: FlutterFlowTheme.of(context).tertiary,
                    size: 24.0,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 0.0, 0.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: FlutterFlowTheme.of(context).headlineSmall,
                    ),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                      child: Text(
                        subtitle,
                        style: FlutterFlowTheme.of(context).bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amount,
                    textAlign: TextAlign.end,
                    style: FlutterFlowTheme.of(context).titleSmall.override(
                          fontFamily: 'Lexend',
                          color: FlutterFlowTheme.of(context).tertiary,
                        ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                    child: Text(
                      'Hello World',
                      textAlign: TextAlign.end,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Lexend',
                            fontSize: 12.0,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
