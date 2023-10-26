import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';

class QurbanPages extends StatelessWidget {
  const QurbanPages({super.key});
  Future<PostgreSQLResult> fetchDataAndConvertData() async {
    final connection = PostgreSQLConnection("localhost", 5432, "postgres",
        username: "postgres", password: "13Mei2002495321");

    await connection.open();

    final results = await connection.query("SELECT * FROM waktu_sholats");

    await connection.close();

    return results;
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
          padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  "Qurban",
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
                FutureBuilder<PostgreSQLResult>(
                  future: fetchDataAndConvertData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // Display a loading indicator while data is being fetched.
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      // Display an error message if an error occurred.
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData) {
                      // Connection was successful but no data retrieved.
                      return Text('No data available.');
                    } else {
                      // Data retrieval was successful. Display the JSON data.
                      final jsonData = snapshot.data!.map((row) => row.asMap()).toList();
                      return Text(
                        'JSON Data: ${jsonData.toString()}',
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontWeight: FontWeight.normal,
                          fontStyle: FontStyle.normal,
                          fontSize: 16,
                          color: Color(0xff000000),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
