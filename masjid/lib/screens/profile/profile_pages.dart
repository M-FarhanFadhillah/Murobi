import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:masjid/flutter_flow/flutter_flow_theme.dart';
import 'package:masjid/flutter_flow/flutter_flow_widgets.dart';

class ProfilePages extends StatefulWidget {
  const ProfilePages({super.key});

  @override
  _ProfilePagesState createState() => _ProfilePagesState();
}

class _ProfilePagesState extends State<ProfilePages> {
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
            padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: SingleChildScrollView(
              child: Column(children: [
                Text(
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
                    color: Color.fromARGB(255, 130, 190, 190),
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3), // Shadow color
                        blurRadius: 5, // Spread radius
                        offset: Offset(0,
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
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: Image(
                            image: AssetImage(
                                "assets/prototype/images/facebook-1.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.all(0),
                          padding: EdgeInsets.all(0),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
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
                            child: Icon(
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
                    color: Color.fromARGB(255, 130, 190, 190),
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3), // Shadow color
                        blurRadius: 5, // Spread radius
                        offset: Offset(0,
                            5), // Offset in the vertical direction (creates a bottom shadow)
                      ),
                    ],
                  ),
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(24, 0, 24, 0),
                    children: [
                      ProfileLabel(label: 'Nama', text: 'Fadhil'),
                      ProfileLabel(label: 'Email', text: 'root@root.com'),
                      ProfileLabel(
                          label: 'Nomor Handphone', text: '08123456789'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
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
                                    title: Text('Change Password'),
                                    content: Column(
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
                                        child: Text('Save'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Cancel'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            options: FFButtonOptions(
                              width: 60,
                              height: 30,
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 0.0),
                              iconPadding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 0.0),
                              color: Color.fromARGB(255, 0, 128, 116),
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
                  height: 90,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 130, 190, 190),
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3), // Shadow color
                        blurRadius: 5, // Spread radius
                        offset: Offset(0,
                            5), // Offset in the vertical direction (creates a bottom shadow)
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 16.0, left: 24),
                        child: Text(
                          'Bahasa',
                          style: const TextStyle(
                            color: Color.fromARGB(255, 82, 82, 92),
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 8.0, left: 24, right: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            FaIcon(FontAwesomeIcons.language),
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return SimpleDialog(
                                      title: Text('Pilih Bahasa'),
                                      children: <Widget>[
                                        SimpleDialogOption(
                                          onPressed: () {
                                            // Logika untuk mengatur bahasa ke Bahasa Indonesia
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('Bahasa Indonesia'),
                                        ),
                                        SimpleDialogOption(
                                          onPressed: () {
                                            // Logika untuk mengatur bahasa ke Bahasa Inggris
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('English'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Text(
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
                    color: Color.fromARGB(255, 130, 190, 190),
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3), // Warna bayangan
                        blurRadius: 5, // Radius bayangan
                        offset: Offset(0,
                            5), // Pergeseran bayangan (membuat bayangan bawah)
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24, 16, 24, 16),
                    child: Column(children: [
                      Row(
                        children: [
                          FaIcon(FontAwesomeIcons.flag),
                          Container(
                            margin: EdgeInsets.only(left: 16.0),
                            child: Text(
                              'Laporkan Masalah',
                              style: const TextStyle(
                                color: Color.fromARGB(255, 82, 82, 92),
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Spacer(),
                          GestureDetector(
                            onTap: () {},
                            child: Icon(
                              Icons.arrow_forward_ios,
                              color: Color.fromARGB(255, 82, 82, 92),
                              size: 20,
                            )
                          )
                        ],
                      ),
                      Spacer(),
                      Row(
                        children: [
                          FaIcon(FontAwesomeIcons.signOutAlt),
                          Container(
                            margin: EdgeInsets.only(left: 16.0),
                            child: Text(
                              'Keluar',
                              style: const TextStyle(
                                color: Color.fromARGB(255, 82, 82, 92),
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Spacer(),
                          GestureDetector(
                            onTap: () {},
                            child: Icon(
                              Icons.arrow_forward_ios,
                              color: Color.fromARGB(255, 82, 82, 92),
                              size: 20,
                            )
                          )
                        ],
                      ),
                    ]),
                  ),
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

  ProfileLabel({
    required this.label,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: 16.0),
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
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Divider(color: Colors.black),
      ],
    );
  }
}
