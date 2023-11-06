import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class KeuanganPages extends StatefulWidget {
  const KeuanganPages({super.key});

  @override
  _KeuanganPagesState createState() => _KeuanganPagesState();
}

class _KeuanganPagesState extends State<KeuanganPages> {
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
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                const Text(
                  "Laporan Keuangan",
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
                    width: MediaQuery.of(context).size.width,
                    height: 250,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(show: true),
                        borderData: FlBorderData(show: true),
                        minX: 0,
                        maxX: 7,
                        minY: 0,
                        maxY: 6,
                        lineBarsData: [
                          LineChartBarData(
                            spots: [
                              FlSpot(0, 3),
                              FlSpot(1, 1),
                              FlSpot(2, 4),
                              FlSpot(3, 2),
                              FlSpot(4, 5),
                              FlSpot(5, 2),
                              FlSpot(6, 6),
                            ],
                            isCurved: true,
                            color: Colors.blue,
                            dotData: FlDotData(show: true),
                            belowBarData: BarAreaData(show: true),
                          ),
                        ],
                      ),
                    )),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 2.5,
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
                          'History Laporan Keuangan',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
