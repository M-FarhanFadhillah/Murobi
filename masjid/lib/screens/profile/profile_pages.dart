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
                  height: 245,
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
                            onPressed: () {},
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
                  height: 75,
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
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            FaIcon(FontAwesomeIcons.language),
                            Text(
                              'Bahasa Indonesia',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.normal,
                                fontSize: 16,
                                color: Color.fromARGB(255, 18, 35, 187),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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

  const ProfileLabel({super.key, 
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
