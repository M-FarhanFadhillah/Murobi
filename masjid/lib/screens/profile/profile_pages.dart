import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:masjid/flutter_flow/flutter_flow_theme.dart';
import 'package:masjid/flutter_flow/flutter_flow_widgets.dart';
import 'package:postgres/postgres.dart';

class ProfilePages extends StatefulWidget {
  const ProfilePages({super.key});

  @override
  _ProfilePagesState createState() => _ProfilePagesState();
}

class _ProfilePagesState extends State<ProfilePages> {
  final query = "SELECT * FROM waktu_sholats"; // Correct the SQL query

  Future<List<Map<String, Map<String, dynamic>>>?> fetchData() async {
    final connection = await postgresConn.getConnection();
    final results = await connection.mappedResultsQuery(query);
    return results;
  }

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: SingleChildScrollView(
              child: Column(children: [
                const Text(
                  'Profile',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 150,
                  margin: const EdgeInsets.only(top: 16.0),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 130, 190, 190),
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3), // Shadow color
                        blurRadius: 5, // Spread radius
                        offset: const Offset(0,
                            5), // Offset in the vertical direction (creates a bottom shadow)
                      ),
                    ],
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          height: 120,
                          width: 120,
                          clipBehavior: Clip.antiAlias,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: const Image(
                            image: AssetImage(
                                "assets/prototype/images/facebook-1.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.all(0),
                          padding: const EdgeInsets.all(0),
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Color(0xff3a57e8),
                            shape: BoxShape.circle,
                          ),
                          child: GestureDetector(
                            onTap: () async {
                              final result = await FilePicker.platform
                                  .pickFiles(type: FileType.any);
                              if (result != null) {
                                // Handle the selected file or folder here
                                if (result.files.isNotEmpty) {
                                  // If a file was selected, you can access it using result.files.first
                                  print(
                                      "Selected file: ${result.files.first.name}");
                                } else {
                                  // If a folder was selected, you can access the folder path using result.paths.first
                                  print(
                                      "Selected folder: ${result.paths.first}");
                                }
                              }
                            },
                            child: const Icon(
                              Icons.photo_camera,
                              color: Color(0xffffffff),
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.only(top: 16.0),
                  height: 260,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 130, 190, 190),
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3), // Shadow color
                        blurRadius: 5, // Spread radius
                        offset: const Offset(0,
                            5), // Offset in the vertical direction (creates a bottom shadow)
                      ),
                    ],
                  ),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                    children: [
                      const ProfileLabel(label: 'Nama', text: 'Fadhil'),
                      const ProfileLabel(label: 'Email', text: 'root@root.com'),
                      const ProfileLabel(
                          label: 'Nomor Handphone', text: '08123456789'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Ubah Kata Sandi',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Color.fromARGB(255, 0, 72, 144),
                            ),
                          ),
                          // Spacer(),
                          FFButtonWidget(
                            text: 'EDIT',
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Change Password'),
                                    content: const Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        TextField(
                                          obscureText: true,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: 'New Password',
                                          ),
                                        )
                                      ],
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Save'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Cancel'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            options: FFButtonOptions(
                              width: 60,
                              height: 30,
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 0.0),
                              iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 0.0),
                              color: const Color.fromARGB(255, 0, 128, 116),
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
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
                              borderRadius: BorderRadius.circular(7.0),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.only(top: 16.0),
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 130, 190, 190),
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3), // Shadow color
                        blurRadius: 5, // Spread radius
                        offset: const Offset(0,
                            5), // Offset in the vertical direction (creates a bottom shadow)
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 16.0, left: 24),
                        child: const Text(
                          'Bahasa',
                          style: TextStyle(
                            color: Color.fromARGB(255, 82, 82, 92),
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 8.0, left: 24, right: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const FaIcon(FontAwesomeIcons.language),
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return SimpleDialog(
                                      title: const Text('Pilih Bahasa'),
                                      children: <Widget>[
                                        SimpleDialogOption(
                                          onPressed: () {
                                            // Logika untuk mengatur bahasa ke Bahasa Indonesia
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Bahasa Indonesia'),
                                        ),
                                        SimpleDialogOption(
                                          onPressed: () {
                                            // Logika untuk mengatur bahasa ke Bahasa Inggris
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('English'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: const Text(
                                'Bahasa Indonesia',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.normal,
                                  fontSize: 16,
                                  color: Color.fromARGB(255, 18, 35, 187),
                                  decoration: TextDecoration.underline,
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
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.only(top: 16.0),
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 130, 190, 190),
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3), // Warna bayangan
                        blurRadius: 5, // Radius bayangan
                        offset: const Offset(0,
                            5), // Pergeseran bayangan (membuat bayangan bawah)
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                    child: Column(children: [
                      Row(
                        children: [
                          const FaIcon(FontAwesomeIcons.flag),
                          Container(
                            margin: const EdgeInsets.only(left: 16.0),
                            child: const Text(
                              'Laporkan Masalah',
                              style: TextStyle(
                                color: Color.fromARGB(255, 82, 82, 92),
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                              onTap: () {},
                              child: const Icon(
                                Icons.arrow_forward_ios,
                                color: Color.fromARGB(255, 82, 82, 92),
                                size: 20,
                              ))
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const FaIcon(FontAwesomeIcons.signOutAlt),
                          Container(
                            margin: const EdgeInsets.only(left: 16.0),
                            child: const Text(
                              'Keluar',
                              style: TextStyle(
                                color: Color.fromARGB(255, 82, 82, 92),
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                              onTap: () {},
                              child: const Icon(
                                Icons.arrow_forward_ios,
                                color: Color.fromARGB(255, 82, 82, 92),
                                size: 20,
                              ))
                        ],
                      ),
                    ]),
                  ),
                ),
                FutureBuilder(
                  future: fetchData(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Map<String, Map<String, dynamic>>>?>
                          snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator(); // Show a loading indicator while waiting for data
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      if (snapshot.hasData &&
                          snapshot.data != null &&
                          snapshot.data!.isNotEmpty) {
                        // Data has been fetched and is not empty
                        // You can display the data here
                        final data = snapshot.data!;
                        return Column(
                          children: data.map((row) {
                            final rowData = row.values.first;
                            return ListTile(
                              title: Text("Column 1: ${rowData['column1']}"),
                              subtitle: Text("Column 2: ${rowData['column2']}"),
                              // You can display more columns as needed
                            );
                          }).toList(),
                        );
                      } else {
                        // Data is empty
                        return const Text('No data available');
                      }
                    }
                  },
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileLabel extends StatelessWidget {
  final String label;
  final String text;

  const ProfileLabel({
    super.key,
    required this.label,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 16.0),
          child: Text(
            label,
            style: const TextStyle(
              color: Color.fromARGB(255, 82, 82, 92),
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const Divider(color: Colors.black),
      ],
    );
  }
}

class postgresConn {
  static Future<PostgreSQLConnection> getConnection() async {
    final connection = PostgreSQLConnection("localhost", 55736, "postgres",
        username: "postgres", password: "13Mei2002495321");
    await connection.open();
    return connection;
  }
}
